extends "res://addons/gut/test.gd"
"""
Tests settings for levels.
"""

var settings: LevelSettings

func before_each() -> void:
	settings = LevelSettings.new()


func test_load_1922_data() -> void:
	var json_text := FileUtils.get_file_as_text("res://assets/test/puzzle/levels/level-1922.json")
	var json_dict: Dictionary = parse_json(json_text)
	settings.from_json_dict("level-1922", json_dict)
	
	assert_eq(settings.speed_ups.size(), 3)
	assert_eq(settings.speed_ups[0].get_meta("speed"), "2")
	assert_eq(settings.speed_ups[1].get_meta("speed"), "3")
	assert_eq(settings.speed_ups[2].get_meta("speed"), "4")
