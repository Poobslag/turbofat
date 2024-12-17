extends GutTest

var settings: LevelSettings

func before_each() -> void:
	settings = LevelSettings.new()


func load_level(filename: String) -> void:
	var json_text := FileUtils.get_file_as_text("res://assets/test/puzzle/levels/%s.json" % [filename])
	var json_dict: Dictionary = parse_json(json_text)
	settings.from_json_dict("test_5952", json_dict)


func test_load_1922_data() -> void:
	load_level("level-1922")
	
	assert_eq(settings.speed.speed_ups.size(), 3)
	assert_eq(settings.speed.speed_ups[0].get_meta("speed"), "2")
	assert_eq(settings.speed.speed_ups[1].get_meta("speed"), "3")
	assert_eq(settings.speed.speed_ups[2].get_meta("speed"), "4")


func test_load_19c5_data() -> void:
	load_level("level-19c5")
	
	var blocks_start := settings.tiles.blocks_start()
	assert_eq(Vector2(1, 10) in blocks_start.block_tiles, true, "start.block_tiles[(1, 10)]")
	assert_eq(blocks_start.block_tiles.get(Vector2(1, 10)), 1, "start.block_tiles[(1, 10)]")
	assert_eq(blocks_start.block_autotile_coords.get(Vector2(1, 10)), Vector2(14, 1), "start.autotile_coords[(1, 10)]")


func test_load_297a_data() -> void:
	load_level("level-297a")
	
	assert_eq(settings.blocks_during.shuffle_inserted_lines, BlocksDuringRules.ShuffleLinesType.SLICE, \
			"settings.blocks_during.shuffle_inserted_lines")
	
	var phases := settings.triggers.triggers.keys()
	assert_eq(phases, [LevelTrigger.LINE_CLEARED])
	var triggers: Array = settings.triggers.triggers[LevelTrigger.LINE_CLEARED]
	assert_eq(1, triggers.size())
	assert_eq_shallow({
			"phases": [
				"line_cleared y=0-8"
			],
			"effect": "insert_line tiles_key=0",
		},
		triggers[0].to_json_dict())


func test_load_2cb4_data() -> void:
	load_level("level-2cb4")
	
	assert_eq(settings.name, "Extra Cream")
	assert_eq(settings.piece_types.suppress_o_piece, false)


func test_load_4373_data() -> void:
	load_level("level-4373")
	
	assert_eq(settings.timers.get_timer_count(), 2)
	
	assert_eq(settings.timers.get_timer_start(0), 28.2)
	assert_eq(settings.timers.get_timer_interval(0), 7.2)
	
	assert_eq(settings.timers.get_timer_start(1), 10.2)
	assert_eq(settings.timers.get_timer_interval(1), 7.2)


func test_load_49db_data() -> void:
	load_level("level-49db")
	
	assert_eq_deep({
		Vector2(0, 18): 1,
		Vector2(0, 19): 1,
	}, settings.tiles.blocks_start().block_tiles)
	
	assert_eq_deep({
		Vector2(0, 18): Vector2(0, 3),
		Vector2(0, 19): Vector2(0, 5),
	}, settings.tiles.blocks_start().block_autotile_coords)
	
	assert_eq_deep({
		Vector2(1, 18): 3,
		Vector2(1, 19): 5,
	}, settings.tiles.blocks_start().pickups)


func test_load_4c5c_data() -> void:
	load_level("level-4c5c")
	
	assert_eq(0, settings.rank.rank_criteria.thresholds_by_grade.size())


func test_load_59c3_data() -> void:
	load_level("level-59c3")
	
	assert_eq(settings.blocks_during.top_out_effect, BlocksDuringRules.TopOutEffect.CLEAR)


func test_load_5a6b_data() -> void:
	load_level("level-5a6b")
	
	assert_eq(settings.rank.rank_criteria.thresholds_by_grade.get("TOP"), 7560)


func test_load_tiles() -> void:
	load_level("level-tiles")
	
	var blocks_start := settings.tiles.blocks_start()
	assert_eq(Vector2(1, 16) in blocks_start.block_tiles, true, "start.block_tiles[(1, 16)]")
	assert_eq(blocks_start.block_tiles.get(Vector2(1, 16)), 2, "start.block_tiles[(1, 16)]")
	assert_eq(blocks_start.block_autotile_coords.get(Vector2(1, 16)), Vector2(9, 1), "start.autotile_coords[(1, 16)]")
	
	var blocks_0 := settings.tiles.get_tiles("0")
	assert_eq(Vector2(3, 2) in blocks_0.block_tiles, true, "0.block_tiles[(3, 2)]")
	assert_eq(blocks_0.block_tiles.get(Vector2(3, 2)), 2, "0.block_tiles[(3, 2)]")
	assert_eq(blocks_0.block_autotile_coords.get(Vector2(3, 2)), Vector2(6, 3), "0.block_autotile_coords[(3, 2)]")
	assert_eq(Vector2(4, 2) in blocks_0.pickups, true, "0.pickups[(4, 2)]")
	assert_eq(blocks_0.pickups.get(Vector2(4, 2)), 5, "0.pickups[(4, 2)]")


func test_path_from_level_key() -> void:
	assert_eq(LevelSettings.path_from_level_key("boatricia1"),
			"res://assets/main/puzzle/levels/boatricia1.json")
	assert_eq(LevelSettings.path_from_level_key("career/its_tee_time"),
			"res://assets/main/puzzle/levels/career/its-tee-time.json")


func test_level_key_from_path_resources() -> void:
	assert_eq(LevelSettings.level_key_from_path("res://assets/main/puzzle/levels/boatricia1.json"),
			"boatricia1")
	assert_eq(LevelSettings.level_key_from_path("res://assets/main/puzzle/levels/career/its-tee-time.json"),
			"career/its_tee_time")


func test_level_key_from_path_files() -> void:
	assert_eq(LevelSettings.level_key_from_path("d:/level_894.json"),
			"level_894")
	assert_eq(LevelSettings.level_key_from_path("/usr/local/bin/level_894.json"),
			"level_894")
	assert_eq(LevelSettings.level_key_from_path("~/.local/share/godot/level_894.json"),
			"level_894")


func test_to_json_version() -> void:
	var json_dict := settings.to_json_dict()
	assert_eq(json_dict.get("version"), Levels.LEVEL_DATA_VERSION)


func test_to_json_basic_properties() -> void:
	settings.name = "name 215"
	settings.description = "description 356"
	settings.difficulty = "FD"
	_convert_to_json_and_back()
	
	assert_eq(settings.name, "name 215")
	assert_eq(settings.description, "description 356")
	assert_eq(settings.difficulty, "FD")


func test_to_json_milestones_and_tiles() -> void:
	settings.finish_condition.set_milestone(Milestone.TIME_OVER, 180)
	settings.success_condition.set_milestone(Milestone.LINES, 100)
	settings.tiles.bunches["start"] = LevelTiles.BlockBunch.new()
	settings.tiles.bunches["start"].set_block(Vector2(1, 2), 3, Vector2(4, 5))
	_convert_to_json_and_back()
	
	assert_eq(settings.finish_condition.type, Milestone.TIME_OVER)
	assert_eq(settings.finish_condition.value, 180)
	assert_eq(settings.success_condition.type, Milestone.LINES)
	assert_eq(settings.success_condition.value, 100)
	assert_eq(settings.tiles.bunches.keys(), ["start"])
	assert_eq(settings.tiles.bunches["start"].block_tiles[Vector2(1, 2)], 3)
	assert_eq(settings.tiles.bunches["start"].block_autotile_coords[Vector2(1, 2)], Vector2(4, 5))


func test_to_json_rules() -> void:
	settings.blocks_during.top_out_effect = BlocksDuringRules.TopOutEffect.CLEAR
	settings.combo_break.pieces = 3
	settings.input_replay.action_timings = {"25 +rotate_cw": true, "33 -rotate_cw": true}
	settings.lose_condition.finish_on_lose = true
	settings.other.after_tutorial = true
	settings.piece_types.start_types = [PieceTypes.piece_j, PieceTypes.piece_l]
	settings.rank.duration = 120
	settings.score.cake_points = 30
	settings.speed.set_start_speed("6")
	settings.timers.timers = [{"interval": 5}]
	settings.triggers.from_json_array(
			[{"phases": ["line_cleared y=0-5"], "effect": "insert_line tiles_key=0"}])
	_convert_to_json_and_back()
	
	assert_eq(settings.blocks_during.top_out_effect, BlocksDuringRules.TopOutEffect.CLEAR)
	assert_eq(settings.combo_break.pieces, 3)
	assert_eq(settings.input_replay.action_timings.keys(), ["25 +rotate_cw", "33 -rotate_cw"])
	assert_eq(settings.lose_condition.finish_on_lose, true)
	assert_eq(settings.other.after_tutorial, true)
	assert_eq(settings.piece_types.start_types, [PieceTypes.piece_j, PieceTypes.piece_l])
	assert_eq(settings.rank.duration, 120)
	assert_eq(settings.score.cake_points, 30)
	assert_eq(settings.speed.get_start_speed(), "6")
	assert_eq_deep(settings.timers.timers, [{"interval": 5}])
	assert_eq(settings.triggers.triggers.keys(), [LevelTrigger.LINE_CLEARED])


func _convert_to_json_and_back() -> void:
	var json_dict := settings.to_json_dict()
	settings = LevelSettings.new()
	settings.from_json_dict("id_873", json_dict)
