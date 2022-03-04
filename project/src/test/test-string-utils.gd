extends "res://addons/gut/test.gd"

func test_capitalize() -> void:
	assert_eq(StringUtils.capitalize_words("a"), "A")
	assert_eq(StringUtils.capitalize_words("hot dog"), "Hot Dog")
	assert_eq(StringUtils.capitalize_words("HOT DOG"), "Hot Dog")


func test_comma_sep_negative() -> void:
	assert_eq(StringUtils.comma_sep(-1), "-1")
	assert_eq(StringUtils.comma_sep(-999), "-999")
	assert_eq(StringUtils.comma_sep(-1000), "-1,000")
	assert_eq(StringUtils.comma_sep(-1002034), "-1,002,034")


func test_comma_sep_small() -> void:
	assert_eq(StringUtils.comma_sep(0), "0")
	assert_eq(StringUtils.comma_sep(1), "1")
	assert_eq(StringUtils.comma_sep(13), "13")
	assert_eq(StringUtils.comma_sep(133), "133")
	assert_eq(StringUtils.comma_sep(999), "999")


func test_comma_sep_big() -> void:
	assert_eq(StringUtils.comma_sep(1000), "1,000")
	assert_eq(StringUtils.comma_sep(1001), "1,001")
	assert_eq(StringUtils.comma_sep(999999), "999,999")
	assert_eq(StringUtils.comma_sep(1000000), "1,000,000")
	assert_eq(StringUtils.comma_sep(1001001), "1,001,001")
	assert_eq(StringUtils.comma_sep(999999999), "999,999,999")
	assert_eq(StringUtils.comma_sep(999999999999999999), "999,999,999,999,999,999")


func test_comma_sep_float_negative() -> void:
	assert_eq(StringUtils.comma_sep_float(-1.348, 1), "-1.3")
	assert_eq(StringUtils.comma_sep_float(-1.384, 1), "-1.4")
	assert_eq(StringUtils.comma_sep_float(-999.348, 1), "-999.3")
	assert_eq(StringUtils.comma_sep_float(-1000.348, 1), "-1,000.3")
	assert_eq(StringUtils.comma_sep_float(-1002034.348, 1), "-1,002,034.3")


func test_comma_sep_float_small() -> void:
	assert_eq(StringUtils.comma_sep_float(0.348, 1), "0.3")
	assert_eq(StringUtils.comma_sep_float(1.348, 1), "1.3")
	assert_eq(StringUtils.comma_sep_float(1.384, 1), "1.4")
	assert_eq(StringUtils.comma_sep_float(13.348, 1), "13.3")
	assert_eq(StringUtils.comma_sep_float(133.348, 1), "133.3")
	assert_eq(StringUtils.comma_sep_float(999.348, 1), "999.3")


func test_comma_sep_float_big() -> void:
	assert_eq(StringUtils.comma_sep_float(1000.348, 1), "1,000.3")
	assert_eq(StringUtils.comma_sep_float(1001.348, 1), "1,001.3")
	assert_eq(StringUtils.comma_sep_float(999999.348, 1), "999,999.3")
	assert_eq(StringUtils.comma_sep_float(1000000.348, 1), "1,000,000.3")
	assert_eq(StringUtils.comma_sep_float(1001001.348, 1), "1,001,001.3")
	assert_eq(StringUtils.comma_sep_float(999999999.348, 1), "999,999,999.3")
	
	# comma_sep_float rounds very big numbers. this isn't deliberate, it's just how floats work
	assert_eq(StringUtils.comma_sep_float(999999999999999999.348, 1), "1,000,000,000,000,000,000")


func test_comma_sep_float_round() -> void:
	# rounds to the nearest value
	assert_eq(StringUtils.comma_sep_float(976784.348, 0), "976,784")
	assert_eq(StringUtils.comma_sep_float(976784.348, 1), "976,784.3")
	assert_eq(StringUtils.comma_sep_float(976784.348, 2), "976,784.35")
	
	# decimals don't use commas or anything silly
	assert_eq(StringUtils.comma_sep_float(1.348276625375806, 5), "1.34828")


func test_compact_negative() -> void:
	assert_eq(StringUtils.compact(-1), "-1")
	assert_eq(StringUtils.compact(-999), "-999")
	assert_eq(StringUtils.compact(-1000), "-1,000")
	assert_eq(StringUtils.compact(-1002034), "-1,002 k")


func test_compact_between_0_and_9999() -> void:
	assert_eq(StringUtils.compact(0), "0")
	assert_eq(StringUtils.compact(1), "1")
	assert_eq(StringUtils.compact(13), "13")
	assert_eq(StringUtils.compact(133), "133")
	assert_eq(StringUtils.compact(1003), "1,003")
	assert_eq(StringUtils.compact(1333), "1,333")
	assert_eq(StringUtils.compact(9999), "9,999")


func test_compact_between_10000_and_9999999() -> void:
	assert_eq(StringUtils.compact(10000), "10 k")
	assert_eq(StringUtils.compact(13333), "13 k")
	assert_eq(StringUtils.compact(133333), "133 k")
	assert_eq(StringUtils.compact(1003333), "1,003 k")
	assert_eq(StringUtils.compact(1333333), "1,333 k")
	assert_eq(StringUtils.compact(9999999), "9,999 k")


func test_compact_between_10000000_and_99999999() -> void:
	assert_eq(StringUtils.compact(10000000), "10 m")
	assert_eq(StringUtils.compact(13333333), "13 m")
	assert_eq(StringUtils.compact(133333333), "133 m")
	assert_eq(StringUtils.compact(1003333333), "1,003 m")
	assert_eq(StringUtils.compact(1333333333), "1,333 m")
	assert_eq(StringUtils.compact(9999999999), "9,999 m")


func test_compact_between_10000000000_and_99999999999() -> void:
	assert_eq(StringUtils.compact(13333333333), "13 b")
	assert_eq(StringUtils.compact(133333333333), "133 b")
	assert_eq(StringUtils.compact(1003333333333), "1,003 b")
	assert_eq(StringUtils.compact(1333333333333), "1,333 b")
	assert_eq(StringUtils.compact(9999999999999), "9,999 b")


func test_compact_over_10000000000000y() -> void:
	assert_eq(StringUtils.compact(13333333333333), "13 t")
	assert_eq(StringUtils.compact(133333333333333), "133 t")
	assert_eq(StringUtils.compact(1003333333333333), "1,003 t")
	assert_eq(StringUtils.compact(1333333333333333), "1,333 t")
	assert_eq(StringUtils.compact(9999999999999999), "9,999 t")
	assert_eq(StringUtils.compact(1333333333333333333), "9,999 t")


func test_format_money() -> void:
	assert_eq(StringUtils.format_money(-10), "-¥10")
	assert_eq(StringUtils.format_money(0), "¥0")
	assert_eq(StringUtils.format_money(10), "¥10")
	assert_eq(StringUtils.format_money(1000), "¥1,000")
	assert_eq(StringUtils.format_money(1234567), "¥1,234,567")


func test_has_letter() -> void:
	assert_eq(StringUtils.has_letter("roof action"), true)
	assert_eq(StringUtils.has_letter("ROOF ACTION"), true)
	assert_eq(StringUtils.has_letter("123"), false)
	assert_eq(StringUtils.has_letter(""), false)


func test_sanitize_file_root_valid_characters() -> void:
	assert_eq(StringUtils.sanitize_file_root("spoil633"), "spoil633")
	assert_eq(StringUtils.sanitize_file_root("spoil-633"), "spoil-633")
	assert_eq(StringUtils.sanitize_file_root("húsbóndi"), "húsbóndi")


func test_sanitize_file_root_invalid_characters() -> void:
	assert_eq(StringUtils.sanitize_file_root("abc#def"), "abc-def")
	assert_eq(StringUtils.sanitize_file_root("abc%def"), "abc-def")
	assert_eq(StringUtils.sanitize_file_root("abc&def"), "abc-def")
	assert_eq(StringUtils.sanitize_file_root("abc\\def"), "abc-def")
	assert_eq(StringUtils.sanitize_file_root("abc	def"), "abc-def")
	
	# avoid using spaces and underscores, use hyphens instead
	assert_eq(StringUtils.sanitize_file_root("abc def"), "abc-def")
	assert_eq(StringUtils.sanitize_file_root("abc_def"), "abc-def")
	
	# periods are denote file extensions and shouldn't be in the basename
	assert_eq(StringUtils.sanitize_file_root("abc.def"), "abc-def")


func test_sanitize_file_root_consecutive_escape_characters() -> void:
	assert_eq(StringUtils.sanitize_file_root("abc#:%def"), "abc-def")


func test_sanitize_file_root_starts_with_underscore() -> void:
	# don't start or end the filename with a space, period, hyphen or underline
	assert_eq(StringUtils.sanitize_file_root(" spoil633"), "spoil633")
	assert_eq(StringUtils.sanitize_file_root(".spoil633"), "spoil633")
	assert_eq(StringUtils.sanitize_file_root("-spoil633"), "spoil633")
	assert_eq(StringUtils.sanitize_file_root("_spoil633"), "spoil633")
	
	assert_eq(StringUtils.sanitize_file_root("spoil633 "), "spoil633")
	assert_eq(StringUtils.sanitize_file_root("spoil633."), "spoil633")
	assert_eq(StringUtils.sanitize_file_root("spoil633-"), "spoil633")
	assert_eq(StringUtils.sanitize_file_root("spoil633_"), "spoil633")


func test_sanitize_file_root_converts_to_lowercase() -> void:
	assert_eq(StringUtils.sanitize_file_root("SpoIL633"), "spoil633")


func test_sanitize_file_root_too_long() -> void:
	# 31 character limit
	assert_eq(StringUtils.sanitize_file_root("0123456789012345678901234567890123456789"),
			"0123456789012345678901234567890")


func test_substring_between() -> void:
	assert_eq(StringUtils.substring_between("wx[b]yz", "[", "]"), "b")
	assert_eq(StringUtils.substring_between("", "[", "]"), "")
	assert_eq(StringUtils.substring_between("wx[b]yz", "", "]"), "")
	assert_eq(StringUtils.substring_between("wx[b]yz", "[", ""), "")
	assert_eq(StringUtils.substring_between("yabcz", "y", "z"), "abc")
	assert_eq(StringUtils.substring_between("yabczyabcz", "y", "z"), "abc")
