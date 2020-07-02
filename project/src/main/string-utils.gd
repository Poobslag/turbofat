class_name StringUtils
"""
Utility class for string operations.

Where possible, these functions mimic the style of org.apache.commons.lang3.StringUtils.
"""

# Numeric suffixes used to represent thousands, millions, billions
const NUM_SUFFIXES := ["", " k", " m", " b", " t"]

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
Formats a duration like 63.159 into '1:03'
"""
static func format_duration(seconds: float) -> String:
	return "%01d:%02d" % [int(ceil(seconds)) / 60, int(ceil(seconds)) % 60]


"""
Parses a duration like 1:03.159 into '63.159'
"""
static func parse_duration(s: String) -> float:
	var split: Array = s.split(":")
	return int(split[0]) * 60 + float(split[1])
