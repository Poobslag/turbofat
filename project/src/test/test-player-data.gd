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
	dir.remove(PlayerSave.rolling_filename(PlayerSave.CURRENT))
	dir.remove(PlayerSave.rolling_filename(PlayerSave.THIS_HOUR))
	dir.remove(PlayerSave.rolling_filename(PlayerSave.PREV_HOUR))
	dir.remove(PlayerSave.rolling_filename(PlayerSave.THIS_DAY))
	dir.remove(PlayerSave.rolling_filename(PlayerSave.PREV_DAY))
	dir.remove(PlayerSave.rolling_filename(PlayerSave.THIS_WEEK))
	dir.remove(PlayerSave.rolling_filename(PlayerSave.PREV_WEEK))


func test_save_and_load() -> void:
	PlayerData.scenario_history.add("scenario-895", _rank_result)
	PlayerSave.save_player_data()
	PlayerData.reset()
	PlayerSave.load_player_data()
	assert_true(PlayerData.scenario_history.has("scenario-895"))
	assert_eq(PlayerData.scenario_history.results("scenario-895")[0].score, 7890)


func test_rolling_filename() -> void:
	assert_eq(PlayerSave.rolling_filename(PlayerSave.CURRENT), "user://test936.save")
	assert_eq(PlayerSave.rolling_filename(PlayerSave.THIS_HOUR), "user://test936.this-hour.save.bak")
	assert_eq(PlayerSave.rolling_filename(PlayerSave.PREV_HOUR), "user://test936.prev-hour.save.bak")
	assert_eq(PlayerSave.rolling_filename(PlayerSave.THIS_DAY), "user://test936.this-day.save.bak")
	assert_eq(PlayerSave.rolling_filename(PlayerSave.PREV_DAY), "user://test936.prev-day.save.bak")
	assert_eq(PlayerSave.rolling_filename(PlayerSave.THIS_WEEK), "user://test936.this-week.save.bak")
	assert_eq(PlayerSave.rolling_filename(PlayerSave.PREV_WEEK), "user://test936.prev-week.save.bak")


func test_corrupt_filename() -> void:
	assert_eq(PlayerSave.corrupt_filename("user://test936.save"), "user://test936.save.corrupt")
	assert_eq(PlayerSave.corrupt_filename("user://test936.this-day.save.bak"), "user://test936.this-day.save.corrupt")
	
	# invalid input should produce non-harmful output
	assert_eq(PlayerSave.corrupt_filename("abcd"), "abcd.save.corrupt")


func test_rotate_backups_none_exist() -> void:
	FileUtils.write_file(PlayerSave.current_player_data_filename, "")
	PlayerSave.rotate_backups()
	var file := File.new()
	
	# current save still exists
	assert_true(file.file_exists(PlayerSave.rolling_filename(PlayerSave.CURRENT)), "PlayerSave.CURRENT")
	
	# newest backups were created
	assert_true(file.file_exists(PlayerSave.rolling_filename(PlayerSave.THIS_HOUR)), "PlayerSave.THIS_HOUR")
	assert_true(file.file_exists(PlayerSave.rolling_filename(PlayerSave.THIS_DAY)), "PlayerSave.THIS_DAY")
	assert_true(file.file_exists(PlayerSave.rolling_filename(PlayerSave.THIS_WEEK)), "PlayerSave.THIS_WEEK")
	
	# old backups weren't created yet
	assert_false(file.file_exists(PlayerSave.rolling_filename(PlayerSave.PREV_HOUR)), "PlayerSave.PREV_HOUR")
	assert_false(file.file_exists(PlayerSave.rolling_filename(PlayerSave.PREV_DAY)), "PlayerSave.PREV_DAY")
	assert_false(file.file_exists(PlayerSave.rolling_filename(PlayerSave.PREV_WEEK)), "PlayerSave.PREV_WEEK")


"""
Don't overwrite the 'this_xxx' backups if they already exist
"""
func test_rotate_backups_dont_overwrite_thisxxx() -> void:
	FileUtils.write_file(PlayerSave.current_player_data_filename, "new-920")
	FileUtils.write_file(PlayerSave.rolling_filename(PlayerSave.THIS_HOUR), "old-920")
	PlayerSave.rotate_backups()
	
	assert_eq(FileUtils.get_file_as_text(PlayerSave.rolling_filename(PlayerSave.THIS_HOUR)), "old-920")


"""
Move the 'this_xxx' backups out of the way if they're old
"""
func test_move_backups() -> void:
	FileUtils.write_file(PlayerSave.rolling_filename(PlayerSave.THIS_HOUR), "")
	var file: File = File.new()
	file.close()


func test_one_bad_file() -> void:
	PlayerData.scenario_history.add("scenario-895", _rank_result)
	PlayerSave.save_player_data()
	PlayerData.reset()
	FileUtils.write_file(PlayerSave.current_player_data_filename, "invalid-772")
	PlayerSave.load_player_data()
	assert_true(PlayerData.scenario_history.has("scenario-895"))
	assert_eq(PlayerData.scenario_history.results("scenario-895")[0].score, 7890)
	assert_true(FileUtils.file_exists("user://test936.save.corrupt"), "user://test936.save.corrupt")
	assert_true(FileUtils.file_exists("user://test936.save"), "user://test936.save")
	
	var dir := Directory.new()
	dir.remove("user://test936.save.corrupt")
