extends GutTest

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
	rules.clear_filled_lines = false
	rules.top_out_effect = BlocksDuringRules.TopOutEffect.CLEAR
	rules.filled_line_clear_delay = 2
	rules.filled_line_clear_max = 3
	rules.filled_line_clear_min = 4
	rules.filled_line_clear_order = BlocksDuringRules.FilledLineClearOrder.RANDOM
	rules.fill_lines = "0"
	rules.line_clear_type = BlocksDuringRules.LineClearType.FLOAT_FALL
	rules.pickup_type = BlocksDuringRules.PickupType.FLOAT_REGEN
	rules.shuffle_filled_lines = BlocksDuringRules.ShuffleLinesType.SLICE
	rules.shuffle_inserted_lines = BlocksDuringRules.ShuffleLinesType.SLICE
	
	assert_eq(rules.to_json_array(),
			["no_clear_filled_lines", "top_out_effect clear", "filled_line_clear_delay 2", "filled_line_clear_max 3",
			"filled_line_clear_min 4", "filled_line_clear_order random", "fill_lines 0", "line_clear_type float_fall",
			"pickup_type float_regen", "shuffle_filled_lines slice", "shuffle_inserted_lines slice",
			])


func test_from_json_empty() -> void:
	rules.from_json_array([])
	assert_eq(rules.top_out_effect, BlocksDuringRules.TopOutEffect.DEFAULT)
	assert_eq(rules.filled_line_clear_delay, 0)
	assert_eq(rules.filled_line_clear_max, 999999)
	assert_eq(rules.filled_line_clear_min, 0)
	assert_eq(rules.filled_line_clear_order, BlocksDuringRules.FilledLineClearOrder.DEFAULT)
	assert_eq(rules.fill_lines, "")
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.DEFAULT)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.DEFAULT)
	assert_eq(rules.shuffle_filled_lines, BlocksDuringRules.ShuffleLinesType.NONE)
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.NONE)


func test_from_json_full() -> void:
	rules.from_json_array(
			["no_clear_filled_lines", "top_out_effect clear", "filled_line_clear_delay 2", "filled_line_clear_max 3",
			"filled_line_clear_min 4", "filled_line_clear_order random", "fill_lines 0", "line_clear_type float_fall",
			"pickup_type float_regen", "shuffle_filled_lines slice", "shuffle_inserted_lines slice",])
	assert_eq(rules.clear_filled_lines, false)
	assert_eq(rules.top_out_effect, BlocksDuringRules.TopOutEffect.CLEAR)
	assert_eq(rules.filled_line_clear_delay, 2)
	assert_eq(rules.filled_line_clear_max, 3)
	assert_eq(rules.filled_line_clear_min, 4)
	assert_eq(rules.filled_line_clear_order, BlocksDuringRules.FilledLineClearOrder.RANDOM)
	assert_eq(rules.fill_lines, "0")
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.FLOAT_FALL)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.FLOAT_REGEN)
	assert_eq(rules.shuffle_filled_lines, BlocksDuringRules.ShuffleLinesType.SLICE)
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.SLICE)


func test_convert_to_json_and_back() -> void:
	rules.top_out_effect = BlocksDuringRules.TopOutEffect.CLEAR
	rules.line_clear_type = BlocksDuringRules.LineClearType.FLOAT_FALL
	rules.pickup_type = BlocksDuringRules.PickupType.FLOAT_REGEN
	rules.shuffle_filled_lines = BlocksDuringRules.ShuffleLinesType.SLICE
	rules.shuffle_inserted_lines = BlocksDuringRules.ShuffleLinesType.SLICE
	_convert_to_json_and_back()
	
	assert_eq(rules.top_out_effect, BlocksDuringRules.TopOutEffect.CLEAR)
	assert_eq(rules.line_clear_type, BlocksDuringRules.LineClearType.FLOAT_FALL)
	assert_eq(rules.pickup_type, BlocksDuringRules.PickupType.FLOAT_REGEN)
	assert_eq(rules.shuffle_filled_lines, BlocksDuringRules.ShuffleLinesType.SLICE)
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.SLICE)


func test_shuffle_inserted_lines() -> void:
	rules.from_json_array(["shuffle_inserted_lines"])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.BAG)
	
	rules.from_json_array(["shuffle_inserted_lines slice"])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.SLICE)
	
	rules.from_json_array(["shuffle_inserted_lines bag"])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.BAG)
	
	rules.from_json_array(["shuffle_inserted_lines none"])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.NONE)
	
	rules.from_json_array([])
	assert_eq(rules.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.NONE)


func test_shuffle_filled_lines() -> void:
	rules.from_json_array(["shuffle_filled_lines"])
	assert_eq(rules.shuffle_filled_lines, BlocksDuringRules.ShuffleLinesType.BAG)
	
	rules.from_json_array(["shuffle_filled_lines slice"])
	assert_eq(rules.shuffle_filled_lines, BlocksDuringRules.ShuffleLinesType.SLICE)
	
	rules.from_json_array(["shuffle_filled_lines bag"])
	assert_eq(rules.shuffle_filled_lines, BlocksDuringRules.ShuffleLinesType.BAG)
	
	rules.from_json_array(["shuffle_filled_lines none"])
	assert_eq(rules.shuffle_filled_lines, BlocksDuringRules.ShuffleLinesType.NONE)
	
	rules.from_json_array([])
	assert_eq(rules.shuffle_filled_lines, BlocksDuringRules.ShuffleLinesType.NONE)


func test_fill_lines() -> void:
	rules.from_json_array(["fill_lines 0"])
	assert_eq(rules.fill_lines, "0")


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = BlocksDuringRules.new()
	rules.from_json_array(json)
