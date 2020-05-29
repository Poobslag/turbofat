extends "res://addons/gut/test.gd"
"""
Unit test demonstrating the save functionality. It's easy to introduce bugs related to saving or loading the
configuration into JSON, since something trivial like renaming a variable or changing its type might change how it's
saved or loaded. That's why unit tests are particularly important for this code.
"""

const TEMP_FILENAME := "test-ground-lucky.save"
const TEMP_FILENAME_0517 := "test-ground-lucky-0517.save"

var _rank_result: RankResult
var _rank_calculator := RankCalculator.new()

func before_each() -> void:
	PlayerSave.player_data_filename = "user://%s" % TEMP_FILENAME
	PlayerSave.old_save.player_data_filename_0517 = "user://%s" % TEMP_FILENAME_0517
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
	save_dir.remove(TEMP_FILENAME_0517)


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


func test_backwards_compatible_lost() -> void:
	var dir := Directory.new()
	dir.copy("res://src/demo/turbofat-v0.0517.save", "user://%s" % TEMP_FILENAME_0517)
	
	PlayerSave.load_player_data()
	
	# scenario where the player topped out and lost
	assert_true(PlayerData.scenario_history.has("sprint-normal"))
	var history_sprint: RankResult = PlayerData.scenario_history.get("sprint-normal")[0]
	assert_eq(history_sprint.lost, true)
	assert_eq(history_sprint.top_out_count, 1)


func test_backwards_compatible_won() -> void:
	var dir := Directory.new()
	dir.copy("res://src/demo/turbofat-v0.0517.save", "user://%s" % TEMP_FILENAME_0517)
	
	PlayerSave.load_player_data()
	
	# scenario where the player survived
	assert_true(PlayerData.scenario_history.has("ultra-normal"))
	var history_ultra: RankResult = PlayerData.scenario_history.get("ultra-normal")[0]
	assert_eq(history_ultra.lost, false)
	assert_eq(history_ultra.top_out_count, 0)


func test_backwards_compatible_money() -> void:
	var dir := Directory.new()
	dir.copy("res://src/demo/turbofat-v0.0517.save", "user://%s" % TEMP_FILENAME_0517)
	
	PlayerSave.load_player_data()
	
	# other data
	assert_eq(PlayerData.money, 202)


func test_backwards_compatible_survival() -> void:
	var dir := Directory.new()
	dir.copy("res://src/demo/turbofat-v0.0517.save", "user://%s" % TEMP_FILENAME_0517)
	
	PlayerSave.load_player_data()
	
	# 'survival mode' used to be called 'marathon mode'
	assert_true(PlayerData.scenario_history.has("survival-normal"))
	var history_survival: RankResult = PlayerData.scenario_history.get("survival-normal")[0]
	assert_eq(history_survival.lost, false)
	assert_eq(history_survival.score, 1335)


func test_backwards_compatible_timestamp() -> void:
	var dir := Directory.new()
	dir.copy("res://src/demo/turbofat-v0.0517.save", "user://%s" % TEMP_FILENAME_0517)
	
	PlayerSave.load_player_data()
	
	assert_true(PlayerData.scenario_history.has("ultra-normal"))
	var history_ultra: RankResult = PlayerData.scenario_history.get("ultra-normal")[0]
	
	# save data doesn't include timestamp, so we make one up
	assert_true(history_ultra.timestamp.has("year"))
	assert_true(history_ultra.timestamp.has("month"))
	assert_true(history_ultra.timestamp.has("day"))
	assert_true(history_ultra.timestamp.has("hour"))
	assert_true(history_ultra.timestamp.has("minute"))
	assert_true(history_ultra.timestamp.has("second"))
