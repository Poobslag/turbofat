extends "res://addons/gut/test.gd"
"""
Tests backwards compatibility with older save formats.
"""

const TEMP_FILENAME := "test-ground-lucky.save"
const TEMP_FILENAME_0517 := "test-ground-lucky-0517.save"

func before_each() -> void:
	PlayerSave.player_data_filename = "user://%s" % TEMP_FILENAME
	PlayerSave.old_save.player_data_filename_0517 = "user://%s" % TEMP_FILENAME_0517
	PlayerData.reset()
	
	var dir := Directory.new()
	dir.copy("res://src/test/turbofat-v0.0517.save", "user://%s" % TEMP_FILENAME_0517)
	PlayerSave.load_player_data()


func after_each() -> void:
	var save_dir := Directory.new()
	save_dir.open("user://")
	save_dir.remove(TEMP_FILENAME)
	save_dir.remove(TEMP_FILENAME_0517)


func test_lost_true() -> void:
	# scenario where the player topped out and lost
	assert_true(PlayerData.scenario_history.scenario_names().has("sprint-normal"))
	var history_sprint: RankResult = PlayerData.scenario_history.results("sprint-normal")[0]
	assert_eq(history_sprint.lost, true)
	assert_eq(history_sprint.top_out_count, 1)


func test_lost_false() -> void:
	# scenario where the player survived
	assert_true(PlayerData.scenario_history.scenario_names().has("ultra-normal"))
	var history_ultra: RankResult = PlayerData.scenario_history.results("ultra-normal")[0]
	assert_eq(history_ultra.lost, false)
	assert_eq(history_ultra.top_out_count, 0)


func test_money_preserved() -> void:
	# other data
	assert_eq(PlayerData.money, 202)


func test_survival_records_preserved() -> void:
	# 'survival mode' used to be called 'marathon mode'
	assert_true(PlayerData.scenario_history.scenario_names().has("survival-normal"))
	var history_survival: RankResult = PlayerData.scenario_history.results("survival-normal")[0]
	assert_eq(history_survival.lost, false)
	assert_eq(history_survival.score, 1335)


func test_timestamp_created() -> void:
	assert_true(PlayerData.scenario_history.scenario_names().has("ultra-normal"))
	var history_ultra: RankResult = PlayerData.scenario_history.results("ultra-normal")[0]
	
	# save data doesn't include timestamp, so we make one up
	assert_true(history_ultra.timestamp.has("year"))
	assert_true(history_ultra.timestamp.has("month"))
	assert_true(history_ultra.timestamp.has("day"))
	assert_true(history_ultra.timestamp.has("hour"))
	assert_true(history_ultra.timestamp.has("minute"))
	assert_true(history_ultra.timestamp.has("second"))


func test_compare_seconds() -> void:
	assert_true(PlayerData.scenario_history.scenario_names().has("ultra-normal"))
	var results: Array = PlayerData.scenario_history.results("ultra-normal")
	assert_eq(results.size(), 3)
	
	# ultra records should be compared by lowest seconds. this 'compare' field didn't exist before
	assert_eq(results[0].compare, "-seconds")
	assert_eq(results[1].compare, "-seconds")
	assert_eq(results[2].compare, "-seconds")


func test_compare_score() -> void:
	assert_true(PlayerData.scenario_history.scenario_names().has("sprint-normal"))
	var history_sprint: RankResult = PlayerData.scenario_history.results("sprint-normal")[0]
	
	# sprint records should be compared by highest score. this 'compare' field didn't exist before
	assert_eq(history_sprint.compare, "+score")


func test_volume() -> void:
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.MUSIC), 0.500, 0.01)
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.SOUND), 0.500, 0.01)
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.VOICE), 0.500, 0.01)
