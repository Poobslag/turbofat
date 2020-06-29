extends "res://addons/gut/test.gd"
"""
Unit test demonstrating the save functionality. It's easy to introduce bugs related to saving or loading the
configuration into JSON, since something trivial like renaming a variable or changing its type might change how it's
saved or loaded. That's why unit tests are particularly important for this code.
"""

const TEMP_FILENAME := "test-ground-lucky.save"

var _rank_result: RankResult

func before_each() -> void:
	PlayerSave.player_data_filename = "user://%s" % TEMP_FILENAME
	PlayerData.reset()
	
	_rank_result = RankResult.new()
	_rank_result.seconds = 600.0
	_rank_result.lines = 300
	_rank_result.box_score_per_line = 9.3
	_rank_result.combo_score_per_line = 17.0
	_rank_result.score = 7890


func after_each() -> void:
	var save_dir := Directory.new()
	save_dir.open("user://")
	save_dir.remove(TEMP_FILENAME)


func test_save_and_load() -> void:
	PlayerData.scenario_history.add("scenario-895", _rank_result)
	PlayerSave.save_player_data()
	PlayerData.reset()
	PlayerSave.load_player_data()
	assert_true(PlayerData.scenario_history.has("scenario-895"))
	assert_eq(PlayerData.scenario_history.results("scenario-895")[0].score, 7890)
