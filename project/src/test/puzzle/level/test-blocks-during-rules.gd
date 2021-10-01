extends "res://addons/gut/test.gd"
"""
Tests rules for blocks/boxes which appear or disappear while the game is going on.
"""

var rules: BlocksDuringRules

func before_each() -> void:
	rules = BlocksDuringRules.new()


func test_is_default() -> void:
	assert_eq(rules.is_default(), true)
	rules.pickup_type = BlocksDuringRules.PickupType.FLOAT_REGEN
	assert_eq(rules.is_default(), false)


func test_to_json_empty() -> void:
	assert_eq(rules.to_json_array(), [])


func test_to_json_full() -> void:
	rules.clear_on_top_out = true
	rules.line_clear_type = BlocksDuringRules.LineClearType.FLOAT_FALL
	rules.pickup_type = BlocksDuringRules.PickupType.FLOAT_REGEN
	rules.random_tiles_start = true
	assert_eq(rules.to_json_array(),
			["clear_on_top_out", "line_clear_type float_fall", "pickup_type float_regen", "random_tiles_start"])


func test_from_json_empty() -> void:
	rules.from_json_array([])
	assert_eq(rules.clear_on_top_out, false)
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.DEFAULT)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.DEFAULT)
	assert_eq(rules.random_tiles_start, false)


func test_from_json_full() -> void:
	rules.from_json_array(
			["clear_on_top_out", "line_clear_type float_fall", "pickup_type float_regen", "random_tiles_start"])
	assert_eq(rules.clear_on_top_out, true)
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.FLOAT_FALL)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.FLOAT_REGEN)
	assert_eq(rules.random_tiles_start, true)


func test_convert_to_json_and_back() -> void:
	rules.clear_on_top_out = true
	rules.line_clear_type = BlocksDuringRules.LineClearType.FLOAT_FALL
	rules.pickup_type = BlocksDuringRules.PickupType.FLOAT_REGEN
	rules.random_tiles_start = true
	_convert_to_json_and_back()
	
	assert_eq(rules.clear_on_top_out, true)
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.FLOAT_FALL)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.FLOAT_REGEN)
	assert_eq(rules.random_tiles_start, true)


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = BlocksDuringRules.new()
	rules.from_json_array(json)
