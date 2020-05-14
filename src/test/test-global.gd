extends "res://addons/gut/test.gd"
"""
Unit test for global functions.
"""

func test_compact_negative() -> void:
	assert_eq(Global.compact(-1), "-1")
	assert_eq(Global.compact(-999), "-999")
	assert_eq(Global.compact(-1000), "-1,000")
	assert_eq(Global.compact(-1002034), "-1,002 k")


func test_compact_between_0_and_9999() -> void:
	assert_eq(Global.compact(0), "0")
	assert_eq(Global.compact(1), "1")
	assert_eq(Global.compact(13), "13")
	assert_eq(Global.compact(133), "133")
	assert_eq(Global.compact(1003), "1,003")
	assert_eq(Global.compact(1333), "1,333")
	assert_eq(Global.compact(9999), "9,999")


func test_compact_between_10000_and_9999999() -> void:
	assert_eq(Global.compact(10000), "10 k")
	assert_eq(Global.compact(13333), "13 k")
	assert_eq(Global.compact(133333), "133 k")
	assert_eq(Global.compact(1003333), "1,003 k")
	assert_eq(Global.compact(1333333), "1,333 k")
	assert_eq(Global.compact(9999999), "9,999 k")


func test_compact_between_10000000_and_99999999() -> void:
	assert_eq(Global.compact(10000000), "10 m")
	assert_eq(Global.compact(13333333), "13 m")
	assert_eq(Global.compact(133333333), "133 m")
	assert_eq(Global.compact(1003333333), "1,003 m")
	assert_eq(Global.compact(1333333333), "1,333 m")
	assert_eq(Global.compact(9999999999), "9,999 m")


func test_compact_between_10000000000_and_99999999999() -> void:
	assert_eq(Global.compact(13333333333), "13 b")
	assert_eq(Global.compact(133333333333), "133 b")
	assert_eq(Global.compact(1003333333333), "1,003 b")
	assert_eq(Global.compact(1333333333333), "1,333 b")
	assert_eq(Global.compact(9999999999999), "9,999 b")


func test_compact_over_10000000000000y() -> void:
	assert_eq(Global.compact(13333333333333), "13 t")
	assert_eq(Global.compact(133333333333333), "133 t")
	assert_eq(Global.compact(1003333333333333), "1,003 t")
	assert_eq(Global.compact(1333333333333333), "1,333 t")
	assert_eq(Global.compact(9999999999999999), "9,999 t")
	assert_eq(Global.compact(1333333333333333333), "9,999 t")


func test_comma_sep_negative() -> void:
	assert_eq(Global.comma_sep(-1), "-1")
	assert_eq(Global.comma_sep(-999), "-999")
	assert_eq(Global.comma_sep(-1000), "-1,000")
	assert_eq(Global.comma_sep(-1002034), "-1,002,034")


func test_comma_sep_small() -> void:
	assert_eq(Global.comma_sep(0), "0")
	assert_eq(Global.comma_sep(1), "1")
	assert_eq(Global.comma_sep(13), "13")
	assert_eq(Global.comma_sep(133), "133")
	assert_eq(Global.comma_sep(999), "999")


func test_comma_sep_big() -> void:
	assert_eq(Global.comma_sep(1000), "1,000")
	assert_eq(Global.comma_sep(1001), "1,001")
	assert_eq(Global.comma_sep(999999), "999,999")
	assert_eq(Global.comma_sep(1000000), "1,000,000")
	assert_eq(Global.comma_sep(1001001), "1,001,001")
	assert_eq(Global.comma_sep(999999999), "999,999,999")
	assert_eq(Global.comma_sep(999999999999999999), "999,999,999,999,999,999")
