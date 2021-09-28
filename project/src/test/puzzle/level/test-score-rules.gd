extends "res://addons/gut/test.gd"
"""
Tests rules for scoring points.
"""

var rules: ScoreRules

func before_each() -> void:
	rules = ScoreRules.new()


func test_is_default() -> void:
	assert_eq(rules.is_default(), true)
	rules.cake_points = 0
	assert_eq(rules.is_default(), false)


func test_to_json_empty() -> void:
	assert_eq(rules.to_json_array(), [])


func test_convert_to_json_and_back() -> void:
	rules.cake_points = 20
	rules.snack_points = 0
	rules.cake_pickup_points = 25
	rules.snack_pickup_points = 15
	rules.veg_points = 5
	_convert_to_json_and_back()
	
	assert_eq(rules.cake_points, 20)
	assert_eq(rules.snack_points, 0)
	assert_eq(rules.cake_pickup_points, 25)
	assert_eq(rules.snack_pickup_points, 15)
	assert_eq(rules.veg_points, 5)


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = ScoreRules.new()
	rules.from_json_array(json)
