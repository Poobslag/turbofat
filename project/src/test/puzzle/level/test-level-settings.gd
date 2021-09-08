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


func test_path_from_level_key() -> void:
	assert_eq(LevelSettings.path_from_level_key("boatricia1"),
			"res://assets/main/puzzle/levels/boatricia1.json")
	assert_eq(LevelSettings.path_from_level_key("marsh/goodbye_bones"),
			"res://assets/main/puzzle/levels/marsh/goodbye-bones.json")


func test_level_key_from_path_resources() -> void:
	assert_eq(LevelSettings.level_key_from_path("res://assets/main/puzzle/levels/boatricia1.json"),
			"boatricia1")
	assert_eq(LevelSettings.level_key_from_path("res://assets/main/puzzle/levels/marsh/goodbye_bones.json"),
			"marsh/goodbye_bones")


func test_level_key_from_path_files() -> void:
	assert_eq(LevelSettings.level_key_from_path("d:/level_894.json"),
			"level_894")
	assert_eq(LevelSettings.level_key_from_path("/usr/local/bin/level_894.json"),
			"level_894")
	assert_eq(LevelSettings.level_key_from_path("~/.local/share/godot/level_894.json"),
			"level_894")
