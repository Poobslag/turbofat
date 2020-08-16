class_name StringUtils
"""
Utility class for string operations.

Where possible, these functions mimic the style of org.apache.commons.lang3.StringUtils.
"""

# Numeric suffixes used to represent thousands, millions, billions
const NUM_SUFFIXES := ["", " k", " m", " b", " t"]

const MAX_FILE_ROOT_LENGTH := 31

# Characters to omit from the first part of a filename
const BAD_FILE_ROOT_CHARS := {
	" ": true,
	
	"!": true, "\"": true, "#": true, "$": true, "%": true, "&": true,
	"'": true, "(": true, ")": true, "*": true, "+": true, ",": true,
	".": true, "/": true,
	
	":": true, ";": true, "<": true, "=": true, ">": true, "?": true, "@": true,
	
	"[": true, "\\": true, "]": true, "^": true,
	
	"_": true, "`": true, "{": true, "|": true, "}": true, "~": true,
}

"""
Formats a potentially large number into a compact form like '5,982 k'.

The resulting string is always seven or fewer characters, allowing for a compact UI.
"""
static func compact(n: int) -> String:
	var suffix_index := 0
	var i: int = n
	
	# determine suffix, such as ' b' in the number '5,982 b'
	while abs(i) > 9999:
		if suffix_index >= NUM_SUFFIXES.size() - 1:
			i = clamp(i, -9999, 9999)
			break
		suffix_index += 1
		i /= 1000
	
	return "%s%s" % [comma_sep(i), NUM_SUFFIXES[suffix_index]]


"""
Formats a number with commas like '1,234,567'.
"""
static func comma_sep(n: int) -> String:
	var result := ""
	var i: int = abs(n)
	
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	
	return "%s%s%s" % ["-" if n < 0 else "", i, result]


"""
Gets the substring after the first occurrence of a separator.
"""
static func substring_after(s: String, sep: String) -> String:
	return s.substr(s.find(sep) + sep.length())


"""
Gets the substring after the last occurrence of a separator.
"""
static func substring_after_last(s: String, sep: String) -> String:
	return s.substr(s.find_last(sep) + sep.length())


"""
Gets the substring before the last occurrence of a separator.
"""
static func substring_before_last(s: String, sep: String) -> String:
	return s.substr(0, s.find_last(sep))


"""
Formats a duration like 63.159 into '1:03'
"""
static func format_duration(seconds: float) -> String:
	# warning-ignore:integer_division
	return "%01d:%02d" % [int(ceil(seconds)) / 60, int(ceil(seconds)) % 60]


"""
Parses a duration like 1:03.159 into '63.159'
"""
static func parse_duration(s: String) -> float:
	var split: Array = s.split(":")
	return int(split[0]) * 60 + float(split[1])


"""
Sanitizes the 'file root' to avoid creating files with unusual filenames.

The file root is the part of a filename preceding the file extension. To limit bugs and user error we sanitize file
roots to ensure they're short, lower-case, and don't include unusual characters.
"""
static func sanitize_file_root(file_root: String) -> String:
	var result := ""
	var utf8 := file_root.to_lower().to_utf8()
	
	# sanitize characters we don't want in filenames
	for i in range(file_root.length()):
		if utf8[i] < 32 or utf8[i] == 127 or file_root[i] in BAD_FILE_ROOT_CHARS:
			# replace sequences of one or more bad characters with a single hyphen
			if not result.ends_with("-"):
				result += "-"
		else:
			result += file_root[i]
	
	# filenames should be a reasonable length, lowercase, and shouldn't start/end with a hyphen
	result = result.to_lower()
	result = result.lstrip("-")
	result = result.rstrip("-")
	return result.substr(0, MAX_FILE_ROOT_LENGTH)


"""
Returns true if the specified character is a letter (a-z, A-Z)
"""
static func is_letter(character: String) -> bool:
	return character >= "A" and character <= "Z" or character >= "a" and character <= "z"


"""
Capitalizes all the whitespace separated words in a String.
"""
static func capitalize_words(string: String) -> String:
	var result := string[0].to_upper()
	for i in range(1, string.length()):
		if is_letter(string[i]) and is_letter(string[i-1]):
			result += string[i].to_lower()
		else:
			result += string[i].to_upper()
	return result


"""
Removes a substring only if it is at the beginning of a source string, otherwise returns the source string.
"""
static func remove_start(string: String, remove: String) -> String:
	var result := string
	if string.begins_with(remove):
		result = string.substr(remove.length())
	return result


"""
Removes a substring only if it is at the end of a source string, otherwise returns the source string.
"""
static func remove_end(string: String, remove: String) -> String:
	var result := string
	if string.ends_with(remove):
		result = string.substr(0, string.length() - remove.length())
	return result
