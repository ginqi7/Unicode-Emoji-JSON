require 'json'

version = "latest"

if ARGV.length > 0
  version = ARGV[0]
end

text_content = `curl https://www.unicode.org/Public/emoji/#{version}/emoji-test.txt`
emoji_data = []

# Regular expressions for matching valid data lines:
# ^([0-9A-F\s]+?)   # Capture group 1: Code points (hex characters and spaces, non-greedy match)
# \s*;\s*           # Matches a semicolon with optional whitespace before and after.
# ([\w-]+)          # Capture Group 2: Status (word characters and hyphen)
# \s*#\s*           # Match the hash symbol, with optional leading and trailing spaces.
# (\S+)             # Capture Group 3: Emoji display (one or more non-space characters, representing the emoji itself)
# \s+               # There should be at least one space between the emoji and the version.
# (\S+)             # Capture Group 4: Emoji version
# \s+               # There should be at least one space between the version and the comment.
# (.*)              # Capture Group 5: Comment (Remaining portion of the line)
# $                 # End of line
regex = /^([0-9A-F\s]+?)\s*;\s*([\w-]+)\s*#\s*(\S+)\s+(\S+)\s+(.*)$/

group = ""
subgroup = ""
text_content.each_line do |line|
  stripped_line = line.strip # Trim whitespace from the beginning and end of the line.


  # Skip empty lines
  next if stripped_line.empty?
  if stripped_line.start_with?("# group:")
    group = stripped_line[-1 * "# group:".length .. -1]
    next
  end
  if stripped_line.start_with?("# subgroup:")
    subgroup = stripped_line[-1 * "# subgroup:".length .. -1]
    next
  end


  # Attempt to match data rows
  if (match = stripped_line.match(regex))
    # Extract the matched data
    codes = match[1].strip          # Unicode code points, removing any possible extra spaces.
    status = match[2].strip         # status
    display_char = match[3].strip   # Emoji char
    version = match[4].strip        # version
    comment = match[5].strip        # comment

    emoji_data << {
      code: codes,
      status: status,
      display: display_char,
      version: version,
      comment: comment,
      group: group,
      subgroup: subgroup
    }
  end
end

# Convert the result array to a formatted JSON string and output it.
File.write('./unicode-emoji-data.json', JSON.pretty_generate(emoji_data))
