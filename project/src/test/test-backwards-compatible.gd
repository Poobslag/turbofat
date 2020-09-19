extends "res://addons/gut/test.gd"
"""
Tests backwards compatibility with older save formats.
"""

const TEMP_FILENAME := "test-ground-lucky.save"
const TEMP_FILENAME_0517 := "test-ground-lucky-0517.save"

func before_each() -> void:
	PlayerSave.current_player_data_filename = "user://%s" % TEMP_FILENAME
	PlayerSave.old_save.player_data_filename_0517 = "user://%s" % TEMP_FILENAME_0517
	PlayerData.reset()


func after_each() -> void:
	var save_dir := Directory.new()
	save_dir.open("user://")
	save_dir.remove(TEMP_FILENAME)
	save_dir.remove(TEMP_FILENAME_0517)


func load_0517_data() -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/turbofat-0517.json", "user://%s" % TEMP_FILENAME_0517)
	PlayerSave.load_player_data()


func load_15d2_data() -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/turbofat-15d2.json", "user://%s" % TEMP_FILENAME)
	PlayerSave.load_player_data()


func load_163e_data() -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/turbofat-163e.json", "user://%s" % TEMP_FILENAME)
	PlayerSave.load_player_data()


func load_1682_data() -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/turbofat-1682.json", "user://%s" % TEMP_FILENAME)
	PlayerSave.load_player_data()


func test_lost_true() -> void:
	load_0517_data()
	
	# scenario where the player topped out and lost
	assert_true(PlayerData.scenario_history.scenario_names().has("sprint_normal"))
	var history_sprint: RankResult = PlayerData.scenario_history.results("sprint_normal")[0]
	assert_eq(history_sprint.lost, true)
	assert_eq(history_sprint.top_out_count, 1)


func test_lost_false() -> void:
	load_0517_data()
	
	# scenario where the player survived
	assert_true(PlayerData.scenario_history.scenario_names().has("ultra_normal"))
	var history_ultra: RankResult = PlayerData.scenario_history.results("ultra_normal")[0]
	assert_eq(history_ultra.lost, false)
	assert_eq(history_ultra.top_out_count, 0)


func test_money_preserved() -> void:
	load_0517_data()
	
	# other data
	assert_eq(PlayerData.money, 202)


func test_survival_records_preserved() -> void:
	load_0517_data()
	
	# 'survival mode' used to be called 'marathon mode'
	assert_true(PlayerData.scenario_history.scenario_names().has("survival_normal"))
	var history_survival: RankResult = PlayerData.scenario_history.results("survival_normal")[0]
	assert_eq(history_survival.lost, false)
	assert_eq(history_survival.score, 1335)


func test_chat_history_preserved() -> void:
	load_1682_data()
	
	assert_eq(5, PlayerData.chat_history.get_chat_age("creatures/primary/boatricia/my_maid_died"))
	assert_eq(13, PlayerData.chat_history.get_filler_count("creatures/primary/boatricia"))


func test_timestamp_created() -> void:
	load_0517_data()
	
	assert_true(PlayerData.scenario_history.scenario_names().has("ultra_normal"))
	var history_ultra: RankResult = PlayerData.scenario_history.results("ultra_normal")[0]
	
	# save data doesn't include timestamp, so we make one up
	assert_true(history_ultra.timestamp.has("year"))
	assert_true(history_ultra.timestamp.has("month"))
	assert_true(history_ultra.timestamp.has("day"))
	assert_true(history_ultra.timestamp.has("hour"))
	assert_true(history_ultra.timestamp.has("minute"))
	assert_true(history_ultra.timestamp.has("second"))


func test_compare_seconds() -> void:
	load_0517_data()
	
	assert_true(PlayerData.scenario_history.scenario_names().has("ultra_normal"))
	var results: Array = PlayerData.scenario_history.results("ultra_normal")
	assert_eq(results.size(), 3)
	
	# ultra records should be compared by lowest seconds. this 'compare' field didn't exist before
	assert_eq(results[0].compare, "-seconds")
	assert_eq(results[1].compare, "-seconds")
	assert_eq(results[2].compare, "-seconds")


func test_compare_score() -> void:
	load_0517_data()
	
	assert_true(PlayerData.scenario_history.scenario_names().has("sprint_normal"))
	var history_sprint: RankResult = PlayerData.scenario_history.results("sprint_normal")[0]
	
	# sprint records should be compared by highest score. this 'compare' field didn't exist before
	assert_eq(history_sprint.compare, "+score")


func test_volume() -> void:
	load_0517_data()
	
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.MUSIC), 0.700, 0.01)
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.SOUND), 0.700, 0.01)
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.VOICE), 0.700, 0.01)


func test_15d2_rank_success() -> void:
	load_15d2_data()
	
	var history_rank_7k: RankResult = PlayerData.scenario_history.results("rank_7k")[0]
	
	# we didn't used to store 'success', but it should be calculated based on how well they did
	assert_eq(history_rank_7k.success, true)


func test_163e_lost_erases_success() -> void:
	load_163e_data()
	
	# rank-6d was a success, and the player didn't lose
	assert_eq(PlayerData.scenario_history.results("rank_6d")[0].success, true)
	# rank-7d was recorded as a success, but the player lost
	assert_eq(PlayerData.scenario_history.results("rank_7d")[0].success, false)
