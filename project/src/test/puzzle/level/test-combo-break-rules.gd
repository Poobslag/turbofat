extends GutTest

var rules: ComboBreakRules

func before_each() -> void:
	rules = ComboBreakRules.new()


func test_to_json_empty() -> void:
	assert_eq(rules.to_json_array(), [])


func test_convert_to_json_and_back() -> void:
	rules.pieces = 3
	rules.veg_row = true
	_convert_to_json_and_back()
	
	assert_eq(rules.pieces, 3)
	assert_eq(rules.veg_row, true)


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = ComboBreakRules.new()
	rules.from_json_array(json)
