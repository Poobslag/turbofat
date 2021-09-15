extends "res://addons/gut/test.gd"
"""
Tests settings for levels.
"""

var settings: LevelSettings

func before_each() -> void:
	settings = LevelSettings.new()


func load_level(filename: String) -> void:
	var json_text := FileUtils.get_file_as_text("res://assets/test/puzzle/levels/%s.json" % [filename])
	var json_dict: Dictionary = parse_json(json_text)
	settings.from_json_dict("test_5952", json_dict)


func test_load_1922_data() -> void:
	load_level("level-1922")
	
	assert_eq(settings.speed_ups.size(), 3)
	assert_eq(settings.speed_ups[0].get_meta("speed"), "2")
	assert_eq(settings.speed_ups[1].get_meta("speed"), "3")
	assert_eq(settings.speed_ups[2].get_meta("speed"), "4")


func test_load_19c5_data() -> void:
	load_level("level-19c5")
	
	var blocks_start := settings.tiles.blocks_start()
	assert_eq(Vector2(1, 10) in blocks_start.used_cells, true, "start.used_cells[(1, 10)]")
	assert_eq(blocks_start.tiles.get(Vector2(1, 10)), 1, "start.tiles[(1, 10)]")
	assert_eq(blocks_start.autotile_coords.get(Vector2(1, 10)), Vector2(14, 1), "start.autotile_coords[(1, 10)]")


func test_load_tiles() -> void:
	load_level("level-tiles")
	
	var blocks_start := settings.tiles.blocks_start()
	assert_eq(Vector2(1, 16) in blocks_start.used_cells, true, "start.used_cells[(1, 16)]")
	assert_eq(blocks_start.tiles.get(Vector2(1, 16)), 2, "start.tiles[(1, 16)]")
	assert_eq(blocks_start.autotile_coords.get(Vector2(1, 16)), Vector2(9, 1), "start.autotile_coords[(1, 16)]")
	
	var blocks_0 := settings.tiles.get_tiles("0")
	assert_eq(Vector2(3, 2) in blocks_0.used_cells, true)
	assert_eq(blocks_0.tiles.get(Vector2(3, 2)), 2)
	assert_eq(blocks_0.autotile_coords.get(Vector2(3, 2)), Vector2(6, 3))


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
