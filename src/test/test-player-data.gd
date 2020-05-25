extends "res://addons/gut/test.gd"
"""
Unit test demonstrating the save functionality. It's easy to introduce bugs related to saving or loading the
configuration into JSON, since something trivial like renaming a variable or changing its type might change how it's
saved or loaded. That's why unit tests are particularly important for this code.
"""

const TEMP_FILENAME := "test-ground-lucky.save"

var _rank_result: RankResult
var _rank_calculator := RankCalculator.new()

func before_each() -> void:
	PlayerSave.player_data_filename = "user://%s" % TEMP_FILENAME
	PlayerData.scenario_history.clear()
	PlayerData.money = 0
	_rank_result = RankResult.new()
	_rank_result.seconds = 600.0
	_rank_result.lines = 300
	_rank_result.box_score_per_line = 9.3
	_rank_result.combo_score_per_line = 17.0
	_rank_result.score = 7890


func after_each() -> void:
	PlayerData.history_size = 1000
	var save_dir := Directory.new()
	save_dir.open("user://")
	save_dir.remove(TEMP_FILENAME)


func test_one_history_entry() -> void:
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	assert_eq(PlayerData.scenario_history["scenario-895"][0].score, 7890)


func test_two_history_entries() -> void:
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	_rank_result = RankResult.new()
	_rank_result.score = 6780
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	assert_eq(PlayerData.scenario_history["scenario-895"][0].score, 6780)
	assert_eq(PlayerData.scenario_history["scenario-895"][1].score, 7890)


func test_too_many_history_entries() -> void:
	PlayerData.history_size = 3
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	_rank_result = RankResult.new()
	_rank_result.score = 6780
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	assert_eq(PlayerData.scenario_history["scenario-895"].size(), 3)
	assert_eq(PlayerData.scenario_history["scenario-895"][0].score, 6780)


func test_no_scenario_name() -> void:
	PlayerData.add_scenario_history("", _rank_result)
	assert_false(PlayerData.scenario_history.has(""))


func test_save_and_load() -> void:
	PlayerData.add_scenario_history("scenario-895", _rank_result)
	PlayerSave.save_player_data()
	PlayerData.scenario_history.clear()
	PlayerSave.load_player_data()
	assert_true(PlayerData.scenario_history.has("scenario-895"))
	assert_eq(PlayerData.scenario_history["scenario-895"][0].score, 7890)
