extends "res://addons/gut/test.gd"
"""
Tests backwards compatibility with older save formats.
"""

const TEMP_FILENAME := "test-ground-lucky.save"

func before_each() -> void:
	PlayerSave.current_player_data_filename = "user://%s" % TEMP_FILENAME
	PlayerData.reset()


func after_each() -> void:
	var save_dir := Directory.new()
	save_dir.open("user://")
	save_dir.remove(TEMP_FILENAME)


func load_player_data(filename: String) -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/%s" % filename, "user://%s" % TEMP_FILENAME)
	PlayerSave.load_player_data()


func test_15d2_rank_success() -> void:
	load_player_data("turbofat-15d2.json")
	
	var history_rank_7k: RankResult = PlayerData.level_history.results("rank/7k")[0]
	
	# we didn't used to store 'success', but it should be calculated based on how well they did
	assert_eq(history_rank_7k.success, true)


func test_163e_lost_erases_success() -> void:
	load_player_data("turbofat-163e.json")
	
	# rank-6d was a success, and the player didn't lose
	assert_eq(PlayerData.level_history.results("rank/6d")[0].success, true)
	# rank-7d was recorded as a success, but the player lost
	assert_eq(PlayerData.level_history.results("rank/7d")[0].success, false)


func test_1682_chat_history_preserved() -> void:
	load_player_data("turbofat-1682.json")
	
	assert_eq(PlayerData.chat_history.get_chat_age("creatures/primary/boatricia/my_maid_died"), 5)
	assert_eq(PlayerData.chat_history.get_filler_count("creatures/primary/boatricia"), 13)


func test_19c5() -> void:
	load_player_data("turbofat-19c5.json")
	
	assert_eq(PlayerData.level_history.successful_levels.has("rank/7k"), true)
	
	assert_eq(PlayerData.level_history.finished_levels.has("tutorial/basics_0"), true)
	assert_eq(PlayerData.level_history.finished_levels.has("practice/ultra_normal"), true)
	
	assert_eq(PlayerData.level_history.best_result("tutorial/basics_0").score, 158)
	assert_eq(PlayerData.level_history.best_result("rank/7k").score, 230)
	assert_almost_eq(PlayerData.level_history.best_result("practice/ultra_normal").seconds, 40.81, 0.1)


func test_1b3c() -> void:
	load_player_data("turbofat-1b3c.json")
	
	# 'survival mode' was renamed to 'marathon mode'
	assert_true(PlayerData.level_history.level_names().has("practice/marathon_hard"))
	var history_marathon: RankResult = PlayerData.level_history.results("practice/marathon_hard")[0]
	assert_eq(history_marathon.lost, false)
	assert_eq(history_marathon.score, 5115)


func test_245b() -> void:
	load_player_data("turbofat-245b.json")
	
	# some levels were made much harder/different, and their scores should be invalidated
	assert_true(PlayerData.level_history.level_names().has("marsh/pulling_for_everyone"))
	assert_false(PlayerData.level_history.level_names().has("marsh/hello_everyone"))
	assert_false(PlayerData.level_history.level_names().has("marsh/hello_skins"))
	assert_false(PlayerData.level_history.level_names().has("marsh/pulling_for_skins"))
	assert_false(PlayerData.level_history.level_names().has("marsh/goodbye_skins"))


func test_24cc() -> void:
	load_player_data("turbofat-24cc.json")
	
	assert_eq(PlayerData.chat_history.chat_history.get("chat/level_select"), 10)
	assert_eq(PlayerData.chat_history.chat_history.get("chat/bort/filler"), 6)
	assert_eq(PlayerData.chat_history.chat_counts.get("chat"), 77)
	assert_eq(PlayerData.chat_history.chat_counts.get("chat/bort"), 24)
	assert_eq(PlayerData.chat_history.filler_counts.get("chat/richie"), 6)
	assert_eq(PlayerData.chat_history.filler_counts.get("chat/boatricia"), 9)
