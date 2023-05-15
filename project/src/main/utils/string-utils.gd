class_name StringUtils
## Utility class for string operations.
##
## Where possible, these functions mimic the style of org.apache.commons.lang3.StringUtils.

## Characters to omit from the first part of a filename
const BAD_FILE_ROOT_CHARS := {
	" ": true,
	
	"!": true, "\"": true, "#": true, "$": true, "%": true, "&": true,
	"'": true, "(": true, ")": true, "*": true, "+": true, ",": true,
	".": true, "/": true,
	
	":": true, ";": true, "<": true, "=": true, ">": true, "?": true, "@": true,
	
	"[": true, "\\": true, "]": true, "^": true,
	
	"_": true, "`": true, "{": true, "|": true, "}": true, "~": true,
}

## Maximum length of a generated file root. Filenames should be a reasonable length.
const MAX_FILE_ROOT_LENGTH := 31

## Numeric suffixes used to represent thousands, millions, billions
const NUM_SUFFIXES := ["", " k", " m", " b", " t"]

## Capitalizes all the whitespace separated words in a String.
static func capitalize_words(string: String) -> String:
	var result := string[0].to_upper()
	for i in range(1, string.length()):
		if is_letter(string[i]) and is_letter(string[i-1]):
			result += string[i].to_lower()
		else:
			result += string[i].to_upper()
	return result


## Formats a number with commas like '1,234,567'.
static func comma_sep(n: int) -> String:
	var result := ""
	var i: int = abs(n)
	
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	
	return "%s%s%s" % ["-" if n < 0 else "", i, result]


## Formats a float with commas like '1,234,567.89'.
##
## Parameters:
## 	'n': The number to format
##
## 	'precision': The number of decimal places to show. Rounding is used.
static func comma_sep_float(n: float, precision: int) -> String:
	var result := str(snapped(abs(n) - int(abs(n)), pow(0.1, precision))).substr(1)
	var i: int = abs(n)
	
	while i > 999:
		result = ",%03d%s" % [i % 1000, result]
		i /= 1000
	
	return "%s%s%s" % ["-" if n < 0 else "", i, result]


## Formats a potentially large number into a compact form like '5,982 k'.
##
## The resulting string is always seven or fewer characters, allowing for a compact UI.
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


## Returns either the passed in String, or if the String is empty or null, the value of 'default'.
static func default_if_empty(s: String, default: String) -> String:
	return s if s else default


## Returns an english representation of a number suitable for a message.
##
## This is useful for messages like 'You need to beat three more levels' or 'You need 3,125 more points.' We don't want
## to display messages like 'You need three thousand one hundred and twenty-five more points', so we leave larger
## numbers alone.
static func english_number(i: int) -> String:
	if i < 0 or i > 20:
		return comma_sep(i)
	
	return ["zero", "one", "two", "three", "four", "five", \
			"six", "seven", "eight", "nine", "ten", \
			"eleven", "twelve", "thirteen", "fourteen", "fifteen", \
			"sixteen", "seventeen", "eighteen", "nineteen", "twenty"][i];


## Formats a duration like 63.159 into '1:04'
static func format_duration(seconds: float) -> String:
	var seconds_int := int(ceil(abs(seconds)))
	@warning_ignore("integer_division")
	var result := "%01d:%02d" % [seconds_int / 60, seconds_int % 60]
	if seconds < 0:
		result = "-" + result
	return result


## Formats a money amount like 1235 into '¥1,235'
static func format_money(money: int) -> String:
	var result := "¥%s" % comma_sep(money)
	result = result.replace("¥-", "-¥") # format negative numbers as '-¥1,235'
	return result


## Returns true if the specified string contains at least one letter (a-z, A-Z) outside parentheses.
static func has_non_parentheses_letter(string: String) -> bool:
	var ignored_letter := true
	var result := false
	var within_parentheses := false
	for c in string:
		if c == "(":
			within_parentheses = true
		elif c == ")" and within_parentheses:
			within_parentheses = false
		elif is_letter(c) and not within_parentheses:
			ignored_letter = true
			result = true
			break
	if ignored_letter and within_parentheses:
		# close parentheses was missing, such as '(abc'
		result = true
	return result


## Replaces hyphens with underscores in a string.
##
## JSON keys and values use underscores to separate words, for consistency with Python conventions.
static func hyphens_to_underscores(s: String) -> String:
	return s.replace("-", "_")


## Returns true if the specified character is a letter (a-z, A-Z)
static func is_letter(character: String) -> bool:
	return character >= "A" and character <= "Z" or character >= "a" and character <= "z"


## Returns true if the specified character is a digit (0-9)
static func is_digit(character: String) -> bool:
	return character >= "0" and character <= "9"


## Parses a duration like 1:03.159 into '63.159'
static func parse_duration(s: String) -> float:
	var split: Array = s.split(":")
	var result: float = abs(int(split[0])) * 60 + float(split[1])
	if s.begins_with("-"):
		result *= -1
	return result


## Sanitizes the 'file root' to avoid creating files with unusual filenames.
##
## The file root is the part of a filename preceding the file extension. To limit bugs we sanitize file roots to ensure
## they're short, lower-case, and don't include unusual characters.
static func sanitize_file_root(file_root: String) -> String:
	var result := ""
	var utf8 := file_root.to_lower().to_utf8_buffer()
	
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


## Gets the substring after the first occurrence of a separator.
static func substring_after(s: String, sep: String) -> String:
	if sep.is_empty():
		return s
	var pos := s.find(sep)
	return "" if pos == -1 else s.substr(pos + sep.length())


## Gets the substring after the last occurrence of a separator.
static func substring_after_last(s: String, sep: String) -> String:
	if sep.is_empty():
		return s
	var pos := s.rfind(sep)
	return "" if pos == -1 else s.substr(pos + sep.length())


## Gets the substring before the first occurrence of a separator.
static func substring_before(s: String, sep: String) -> String:
	if sep.is_empty():
		return s
	var pos := s.find(sep)
	return s if pos == -1 else s.substr(0, pos)


## Gets the substring before the last occurrence of a separator.
static func substring_before_last(s: String, sep: String) -> String:
	if sep.is_empty():
		return s
	var pos := s.rfind(sep)
	return s if pos == -1 else s.substr(0, pos)


## Gets the String that is nested in between two Strings. Only the first match is returned.
static func substring_between(s: String, open: String, close: String) -> String:
	if s.is_empty() or open.is_empty() or close.is_empty():
		return ""
	
	var result := ""
	var start := s.find(open)
	if start != -1:
		var end := s.find(close, start + open.length())
		if end != -1:
			result = s.substr(start + open.length(), end - start - open.length())
	return result


## Replaces underscores with hyphens in a string.
##
## Filenames use kebab-case.
static func underscores_to_hyphens(s: String) -> String:
	return s.replace("_", "-")


## Wraps 'player' and 'sensei' in hash symbols so their names will be translated.
static func hashwrap_constants(s: String) -> String:
	var result := s
	if s in ["player", "sensei", "narrator"]:
		result = "#%s#" % [s]
	return result
