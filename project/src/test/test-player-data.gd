extends "res://addons/gut/test.gd"
"""
Unit test demonstrating the save functionality. It's easy to introduce bugs related to saving or loading the
configuration into JSON, since something trivial like renaming a variable or changing its type might change how it's
saved or loaded. That's why unit tests are particularly important for this code.
"""

const TEMP_FILENAME := "test936.save"

var _rank_result: RankResult

func before_each() -> void:
	PlayerSave.current_player_data_filename = "user://%s" % TEMP_FILENAME
	PlayerData.reset()
	
	_rank_result = RankResult.new()
	_rank_result.seconds = 600.0
	_rank_result.lines = 300
	_rank_result.box_score_per_line = 9.3
	_rank_result.combo_score_per_line = 17.0
	_rank_result.score = 7890


func after_each() -> void:
	var dir := Directory.new()
	dir.remove(PlayerSave.rolling_backups.rolling_filename(RollingBackups.CURRENT))
	dir.remove(PlayerSave.rolling_backups.rolling_filename(RollingBackups.THIS_HOUR))
	dir.remove(PlayerSave.rolling_backups.rolling_filename(RollingBackups.PREV_HOUR))
	dir.remove(PlayerSave.rolling_backups.rolling_filename(RollingBackups.THIS_DAY))
	dir.remove(PlayerSave.rolling_backups.rolling_filename(RollingBackups.PREV_DAY))
	dir.remove(PlayerSave.rolling_backups.rolling_filename(RollingBackups.THIS_WEEK))
	dir.remove(PlayerSave.rolling_backups.rolling_filename(RollingBackups.PREV_WEEK))


func test_save_and_load() -> void:
	PlayerData.scenario_history.add("scenario_895", _rank_result)
	PlayerSave.save_player_data()
	PlayerData.reset()
	PlayerSave.load_player_data()
	assert_true(PlayerData.scenario_history.has("scenario_895"))
	assert_eq(PlayerData.scenario_history.results("scenario_895")[0].score, 7890)


func test_one_bad_file() -> void:
	PlayerData.scenario_history.add("scenario_895", _rank_result)
	PlayerSave.save_player_data()
	PlayerData.reset()
	FileUtils.write_file(PlayerSave.current_player_data_filename, "invalid-772")
	PlayerSave.load_player_data()
	assert_true(PlayerData.scenario_history.has("scenario_895"))
	assert_eq(PlayerData.scenario_history.results("scenario_895")[0].score, 7890)
	assert_true(FileUtils.file_exists("user://test936.save.corrupt"), "user://test936.save.corrupt")
	assert_true(FileUtils.file_exists("user://test936.save"), "user://test936.save")
	
	var dir := Directory.new()
	dir.remove("user://test936.save.corrupt")
