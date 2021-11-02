extends "res://addons/gut/test.gd"

var timers: LevelTimers

func before_each() -> void:
	timers = LevelTimers.new()


func test_is_default() -> void:
	assert_eq(timers.is_default(), true)
	timers.timers.append({"interval": 12})
	assert_eq(timers.is_default(), false)


func test_to_json_empty() -> void:
	assert_eq(timers.to_json_array(), [])


func test_convert_to_json_and_back() -> void:
	timers.timers.append({"interval": 12})
	_convert_to_json_and_back()
	
	assert_eq_deep(timers.timers, [{"interval": 12}])


func _convert_to_json_and_back() -> void:
	var json := timers.to_json_array()
	timers = LevelTimers.new()
	timers.from_json_array(json)
