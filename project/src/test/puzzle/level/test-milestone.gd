extends "res://addons/gut/test.gd"
"""
Unit test demonstrating goals/milestones for puzzles.
"""

var milestone: Milestone

func before_each() -> void:
	milestone = Milestone.new()


func test_is_default() -> void:
	assert_eq(milestone.is_default(), true)
	
	milestone = Milestone.new()
	milestone.set_meta("speed", "FB")
	assert_eq(milestone.is_default(), false)
	
	milestone = Milestone.new()
	milestone.type = Milestone.LINES
	assert_eq(milestone.is_default(), false)
	
	milestone = Milestone.new()
	milestone.value = 80
	assert_eq(milestone.is_default(), false)


func test_convert_to_json_and_back() -> void:
	milestone.type = Milestone.LINES
	milestone.value = 120
	_convert_to_json_and_back()
	
	assert_eq(milestone.type, Milestone.LINES)
	assert_eq(milestone.value, 120)


func _convert_to_json_and_back() -> void:
	var json := milestone.to_json_dict()
	milestone = Milestone.new()
	milestone.from_json_dict(json)
