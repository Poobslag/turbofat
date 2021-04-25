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


func load_19c5_data() -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/turbofat-19c5.json", "user://%s" % TEMP_FILENAME)
	PlayerSave.load_player_data()


func load_1b3c_data() -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/turbofat-1b3c.json", "user://%s" % TEMP_FILENAME)
	PlayerSave.load_player_data()


func test_0517_lost_true() -> void:
	load_0517_data()
	
	# level where the player topped out and lost
	assert_true(PlayerData.level_history.level_names().has("practice/sprint_normal"))
	var history_sprint: RankResult = PlayerData.level_history.results("practice/sprint_normal")[0]
	assert_eq(history_sprint.lost, true)
	assert_eq(history_sprint.top_out_count, 1)


func test_0517_lost_false() -> void:
	load_0517_data()
	
	# level where the player survived
	assert_true(PlayerData.level_history.level_names().has("practice/ultra_normal"))
	var history_ultra: RankResult = PlayerData.level_history.results("practice/ultra_normal")[0]
	assert_eq(history_ultra.lost, false)
	assert_eq(history_ultra.top_out_count, 0)


func test_0517_money_preserved() -> void:
	load_0517_data()
	
	# other data
	assert_eq(PlayerData.money, 202)


func test_0517_marathon_records_preserved() -> void:
	load_0517_data()
	
	# 'marathon mode' was renamed to 'survival mode' and back to 'marathon mode'
	assert_true(PlayerData.level_history.level_names().has("practice/marathon_normal"))
	var history_marathon: RankResult = PlayerData.level_history.results("practice/marathon_normal")[0]
	assert_eq(history_marathon.lost, false)
	assert_eq(history_marathon.score, 1335)


func test_0517_timestamp_created() -> void:
	load_0517_data()
	
	assert_true(PlayerData.level_history.level_names().has("practice/ultra_normal"))
	var history_ultra: RankResult = PlayerData.level_history.results("practice/ultra_normal")[0]
	
	# save data doesn't include timestamp, so we make one up
	assert_true(history_ultra.timestamp.has("year"))
	assert_true(history_ultra.timestamp.has("month"))
	assert_true(history_ultra.timestamp.has("day"))
	assert_true(history_ultra.timestamp.has("hour"))
	assert_true(history_ultra.timestamp.has("minute"))
	assert_true(history_ultra.timestamp.has("second"))


func test_0517_compare_seconds() -> void:
	load_0517_data()
	
	assert_true(PlayerData.level_history.level_names().has("practice/ultra_normal"))
	var results: Array = PlayerData.level_history.results("practice/ultra_normal")
	assert_eq(results.size(), 3)
	
	# ultra records should be compared by lowest seconds. this 'compare' field didn't exist before
	assert_eq(results[0].compare, "-seconds")
	assert_eq(results[1].compare, "-seconds")
	assert_eq(results[2].compare, "-seconds")


func test_0517_compare_score() -> void:
	load_0517_data()
	
	assert_true(PlayerData.level_history.level_names().has("practice/sprint_normal"))
	var history_sprint: RankResult = PlayerData.level_history.results("practice/sprint_normal")[0]
	
	# sprint records should be compared by highest score. this 'compare' field didn't exist before
	assert_eq(history_sprint.compare, "+score")


func test_0517_volume() -> void:
	load_0517_data()
	
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.MUSIC), 0.700, 0.01)
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.SOUND), 0.700, 0.01)
	assert_almost_eq(PlayerData.volume_settings.get_bus_volume_linear(VolumeSettings.VOICE), 0.700, 0.01)


func test_15d2_rank_success() -> void:
	load_15d2_data()
	
	var history_rank_7k: RankResult = PlayerData.level_history.results("rank/7k")[0]
	
	# we didn't used to store 'success', but it should be calculated based on how well they did
	assert_eq(history_rank_7k.success, true)


func test_163e_lost_erases_success() -> void:
	load_163e_data()
	
	# rank-6d was a success, and the player didn't lose
	assert_eq(PlayerData.level_history.results("rank/6d")[0].success, true)
	# rank-7d was recorded as a success, but the player lost
	assert_eq(PlayerData.level_history.results("rank/7d")[0].success, false)


func test_1682_chat_history_preserved() -> void:
	load_1682_data()
	
	assert_eq(PlayerData.chat_history.get_chat_age("creatures/primary/boatricia/my_maid_died"), 5)
	assert_eq(PlayerData.chat_history.get_filler_count("creatures/primary/boatricia"), 13)


func test_19c5() -> void:
	load_19c5_data()
	
	assert_eq(PlayerData.level_history.successful_levels.has("rank/7k"), true)
	
	assert_eq(PlayerData.level_history.finished_levels.has("tutorial/basics_0"), true)
	assert_eq(PlayerData.level_history.finished_levels.has("practice/ultra_normal"), true)
	
	assert_eq(PlayerData.level_history.best_result("tutorial/basics_0").score, 158)
	assert_eq(PlayerData.level_history.best_result("rank/7k").score, 230)
	assert_almost_eq(PlayerData.level_history.best_result("practice/ultra_normal").seconds, 40.81, 0.1)


func test_1b3c() -> void:
	load_1b3c_data()
	
	# 'survival mode' was renamed to 'marathon mode'
	assert_true(PlayerData.level_history.level_names().has("practice/marathon_hard"))
	var history_marathon: RankResult = PlayerData.level_history.results("practice/marathon_hard")[0]
	assert_eq(history_marathon.lost, false)
	assert_eq(history_marathon.score, 5115)
