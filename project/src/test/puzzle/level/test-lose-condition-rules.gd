extends "res://addons/gut/test.gd"

var rules: LoseConditionRules

func before_each() -> void:
	rules = LoseConditionRules.new()


func test_is_default() -> void:
	assert_eq(rules.is_default(), true)
	rules.finish_on_lose = true
	assert_eq(rules.is_default(), false)


func test_convert_to_json_and_back() -> void:
	rules.finish_on_lose = true
	rules.top_out = 5
	_convert_to_json_and_back()
	
	assert_eq(rules.finish_on_lose, true)
	assert_eq(rules.top_out, 5)


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = LoseConditionRules.new()
	rules.from_json_array(json)
