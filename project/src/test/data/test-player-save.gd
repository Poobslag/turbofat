extends GutTest

const TEMP_FILENAME := "user://test936.save"

var _rank_result: RankResult

func before_each() -> void:
	PlayerSave.data_filename = TEMP_FILENAME
	PlayerData.reset()
	
	_rank_result = RankResult.new()
	_rank_result.seconds = 600.0
	_rank_result.score = 7890


func after_each() -> void:
	var rolling_backups := RollingBackups.new()
	rolling_backups.data_filename = TEMP_FILENAME
	rolling_backups.delete_all_backups()


func test_save_and_load() -> void:
	PlayerData.level_history.add_result("level_895", _rank_result)
	PlayerSave.save_player_data()
	PlayerData.reset()
	PlayerSave.load_player_data()
	assert_true(PlayerData.level_history.has_result("level_895"))
	assert_eq(PlayerData.level_history.results("level_895")[0].score, 7890)


func test_one_bad_file() -> void:
	PlayerData.level_history.add_result("level_895", _rank_result)
	PlayerSave.save_player_data()
	PlayerData.reset()
	FileUtils.write_file(PlayerSave.data_filename, "invalid-772")
	PlayerSave.load_player_data()
	assert_true(PlayerData.level_history.has_result("level_895"))
	assert_eq(PlayerData.level_history.results("level_895")[0].score, 7890)
	assert_true(FileUtils.file_exists("user://test936.save.corrupt"), "user://test936.save.corrupt")
	assert_true(FileUtils.file_exists("user://test936.save"), "user://test936.save")
	
	var dir := Directory.new()
	dir.remove("user://test936.save.corrupt")
