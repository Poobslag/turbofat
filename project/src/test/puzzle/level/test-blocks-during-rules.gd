extends "res://addons/gut/test.gd"

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
	rules.shuffle_inserted_lines = BlocksDuringRules.ShuffleInsertedLinesType.SLICE
	assert_eq(rules.to_json_array(),
			["clear_on_top_out", "line_clear_type float_fall", "pickup_type float_regen", "shuffle_inserted_lines slice"])


func test_from_json_empty() -> void:
	rules.from_json_array([])
	assert_eq(rules.clear_on_top_out, false)
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.DEFAULT)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.DEFAULT)
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleInsertedLinesType.NONE)


func test_from_json_full() -> void:
	rules.from_json_array(
			["clear_on_top_out", "line_clear_type float_fall", "pickup_type float_regen", "shuffle_inserted_lines slice"])
	assert_eq(rules.clear_on_top_out, true)
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.FLOAT_FALL)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.FLOAT_REGEN)
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleInsertedLinesType.SLICE)


func test_convert_to_json_and_back() -> void:
	rules.clear_on_top_out = true
	rules.line_clear_type = BlocksDuringRules.LineClearType.FLOAT_FALL
	rules.pickup_type = BlocksDuringRules.PickupType.FLOAT_REGEN
	rules.shuffle_inserted_lines = BlocksDuringRules.ShuffleInsertedLinesType.SLICE
	_convert_to_json_and_back()
	
	assert_eq(rules.clear_on_top_out, true)
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.FLOAT_FALL)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.FLOAT_REGEN)
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleInsertedLinesType.SLICE)


func test_shuffle_inserted_lines() -> void:
	rules.from_json_array(["shuffle_inserted_lines"])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleInsertedLinesType.BAG)
	
	rules.from_json_array(["shuffle_inserted_lines slice"])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleInsertedLinesType.SLICE)
	
	rules.from_json_array(["shuffle_inserted_lines bag"])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleInsertedLinesType.BAG)
	
	rules.from_json_array(["shuffle_inserted_lines none"])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleInsertedLinesType.NONE)
	
	rules.from_json_array([])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleInsertedLinesType.NONE)


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = BlocksDuringRules.new()
	rules.from_json_array(json)
