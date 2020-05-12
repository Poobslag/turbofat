extends "res://addons/gut/test.gd"
"""
Unit test for money formatting.
"""

"""
The player should never have negative money unless they hack the game or something. But, let's keep the UI pretty.
"""
func test_negative_money() -> void:
	assert_eq(MoneyLabel.format_money(-133), "0")
	assert_eq(MoneyLabel.format_money(-13), "0")
	assert_eq(MoneyLabel.format_money(-1), "0")


func test_between_0_and_9999_money() -> void:
	assert_eq(MoneyLabel.format_money(0), "0")
	assert_eq(MoneyLabel.format_money(1), "1")
	assert_eq(MoneyLabel.format_money(13), "13")
	assert_eq(MoneyLabel.format_money(133), "133")
	assert_eq(MoneyLabel.format_money(1003), "1,003")
	assert_eq(MoneyLabel.format_money(1333), "1,333")
	assert_eq(MoneyLabel.format_money(9999), "9,999")


func test_between_10000_and_9999999_money() -> void:
	assert_eq(MoneyLabel.format_money(10000), "10 k")
	assert_eq(MoneyLabel.format_money(13333), "13 k")
	assert_eq(MoneyLabel.format_money(133333), "133 k")
	assert_eq(MoneyLabel.format_money(1003333), "1,003 k")
	assert_eq(MoneyLabel.format_money(1333333), "1,333 k")
	assert_eq(MoneyLabel.format_money(9999999), "9,999 k")


func test_between_10000000_and_99999999_money() -> void:
	assert_eq(MoneyLabel.format_money(10000000), "10 m")
	assert_eq(MoneyLabel.format_money(13333333), "13 m")
	assert_eq(MoneyLabel.format_money(133333333), "133 m")
	assert_eq(MoneyLabel.format_money(1003333333), "1,003 m")
	assert_eq(MoneyLabel.format_money(1333333333), "1,333 m")
	assert_eq(MoneyLabel.format_money(9999999999), "9,999 m")


func test_between_10000000000_and_99999999999_money() -> void:
	assert_eq(MoneyLabel.format_money(13333333333), "13 b")
	assert_eq(MoneyLabel.format_money(133333333333), "133 b")
	assert_eq(MoneyLabel.format_money(1003333333333), "1,003 b")
	assert_eq(MoneyLabel.format_money(1333333333333), "1,333 b")
	assert_eq(MoneyLabel.format_money(9999999999999), "9,999 b")


func test_over_10000000000000_money() -> void:
	assert_eq(MoneyLabel.format_money(13333333333333), "13 t")
	assert_eq(MoneyLabel.format_money(133333333333333), "133 t")
	assert_eq(MoneyLabel.format_money(1003333333333333), "1,003 t")
	assert_eq(MoneyLabel.format_money(1333333333333333), "1,333 t")
	assert_eq(MoneyLabel.format_money(9999999999999999), "9,999 t")
	assert_eq(MoneyLabel.format_money(1333333333333333333), "9,999 t")
