extends "res://addons/gut/test.gd"

const TEMP_FILENAME := "test-ground-lucky.save"
const TEMP_LEGACY_FILENAME := "test-snatch-lucky.save"

func before_each() -> void:
	PlayerSave.data_filename = "user://%s" % TEMP_FILENAME
	PlayerSave.legacy_filename = "user://%s" % TEMP_LEGACY_FILENAME
	
	# don't increment playtime during this test or it ruins our assertions
	PlayerData.seconds_played_timer.stop()
	PlayerData.reset()


func after_each() -> void:
	var save_dir := Directory.new()
	save_dir.open("user://")
	save_dir.remove(TEMP_FILENAME)
	save_dir.remove(TEMP_LEGACY_FILENAME)


func load_legacy_player_data(filename: String) -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/%s" % filename, "user://%s" % TEMP_LEGACY_FILENAME)
	PlayerSave.load_player_data()


func test_15d2_rank_success() -> void:
	load_legacy_player_data("turbofat-15d2.json")
	
	assert_true(PlayerData.level_history.results("rank/7k").size() >= 1)
	var history_rank_7k: RankResult = PlayerData.level_history.results("rank/7k")[0]
	
	# we didn't used to store 'success', but it should be calculated based on how well they did
	assert_eq(history_rank_7k.success, true)


func test_163e_lost_erases_success() -> void:
	load_legacy_player_data("turbofat-163e.json")
	
	# rank-6d was a success, and the player didn't lose
	assert_true(PlayerData.level_history.results("rank/6d").size() >= 1)
	assert_eq(PlayerData.level_history.results("rank/6d")[0].success, true)
	# rank-7d was recorded as a success, but the player lost
	assert_true(PlayerData.level_history.results("rank/7d").size() >= 1)
	assert_eq(PlayerData.level_history.results("rank/7d")[0].success, false)


func test_1682_chat_history_preserved() -> void:
	load_legacy_player_data("turbofat-1682.json")
	
	assert_eq(PlayerData.chat_history.chat_age("creature/boatricia/my_maid_died"), 5)
	assert_eq(PlayerData.chat_history.filler_count("creature/boatricia"), 13)


func test_199c() -> void:
	load_legacy_player_data("turbofat-199c.json")
	
	assert_eq(PlayerData.level_history.successful_levels.has("practice/marathon_normal"), true)
	assert_eq(PlayerData.level_history.successful_levels.has("rank/7k"), true)
	
	assert_eq(PlayerData.level_history.finished_levels.has("boatricia"), true)
	assert_eq(PlayerData.level_history.finished_levels.has("example"), true)


func test_19c5() -> void:
	load_legacy_player_data("turbofat-19c5.json")
	
	assert_eq(PlayerData.level_history.successful_levels.has("rank/7k"), true)
	
	assert_eq(PlayerData.level_history.is_level_finished("tutorial/basics_0"), true)
	assert_eq(PlayerData.level_history.is_level_finished("practice/ultra_normal"), true)
	
	assert_eq(PlayerData.level_history.best_result("tutorial/basics_0").score, 158)
	assert_eq(PlayerData.level_history.best_result("rank/7k").score, 230)
	assert_almost_eq(PlayerData.level_history.best_result("practice/ultra_normal").seconds, 40.81, 0.1)


func test_1b3c() -> void:
	load_legacy_player_data("turbofat-1b3c.json")
	
	# 'survival mode' was renamed to 'marathon mode'
	assert_true(PlayerData.level_history.level_names().has("practice/marathon_hard"))
	var history_marathon: RankResult = PlayerData.level_history.results("practice/marathon_hard")[0]
	assert_eq(history_marathon.lost, false)
	assert_eq(history_marathon.score, 5115)


func test_245b() -> void:
	load_legacy_player_data("turbofat-245b.json")
	
	# some levels were made much harder/different, and their scores should be invalidated
	assert_true(PlayerData.level_history.level_names().has("marsh/pulling_for_everyone"))
	assert_false(PlayerData.level_history.level_names().has("marsh/hello_everyone"))
	assert_false(PlayerData.level_history.level_names().has("marsh/hello_skins"))
	assert_false(PlayerData.level_history.level_names().has("marsh/pulling_for_skins"))
	assert_false(PlayerData.level_history.level_names().has("marsh/goodbye_skins"))


func test_24cc() -> void:
	load_legacy_player_data("turbofat-24cc.json")
	
	assert_eq(PlayerData.chat_history.chat_history.get("chat/level_select"), 10)
	assert_eq(PlayerData.chat_history.chat_history.get("creature/bort/filler"), 6)
	assert_eq(PlayerData.chat_history.chat_counts.get("chat"), 77)
	assert_eq(PlayerData.chat_history.chat_counts.get("creature/bort"), 24)
	assert_eq(PlayerData.chat_history.filler_counts.get("creature/richie"), 6)
	assert_eq(PlayerData.chat_history.filler_counts.get("creature/boatricia"), 58)


func test_2743() -> void:
	load_legacy_player_data("turbofat-2743.json")
	
	# chat history should use underscores, and new prefixes
	assert_eq(PlayerData.chat_history.chat_history.get("creature/boatricia/hi"), 57)
	assert_eq(PlayerData.chat_history.chat_history.get("creature/richie/filler_000"), 4)
	assert_eq(PlayerData.chat_history.chat_history.get("level/five_customers_no_vegetables_000"), 4)
	assert_eq(PlayerData.chat_history.chat_history.get("level/marsh/hello_everyone_000"), 55)
	assert_eq(PlayerData.chat_history.chat_history.get("level/marsh/hello_shirts_000"), 57)
	assert_eq(PlayerData.chat_history.chat_history.get("chat/meet_the_competition"), 78)
	
	# chat counts should use underscores, and new prefixes
	assert_eq(PlayerData.chat_history.chat_counts.get("creature/richie"), 6)
	assert_eq(PlayerData.chat_history.chat_counts.get("creature/shirts"), 2)
	
	# filler counts should use underscores, and new prefixes
	assert_eq(PlayerData.chat_history.filler_counts.get("creature/richie"), 6)
	assert_eq(PlayerData.chat_history.filler_counts.get("creature/shirts"), 2)
	
	assert_almost_eq(PlayerData.creature_library.get_fatness("#filler_000#"), 1.03, 0.01)
	assert_almost_eq(PlayerData.creature_library.get_fatness("#filler_100#"), 1.68, 0.01)
	assert_almost_eq(PlayerData.creature_library.get_fatness("i_n_cognito"), 1.30, 0.01)


func test_2783() -> void:
	load_legacy_player_data("turbofat-2783.json")
	
	# We did not measure playtime in 2783, but we can approximate it based on the player's money.
	assert_almost_eq(PlayerData.seconds_played, 1181359.0, 0.1)
	
	# Save data was in one file in 2783, but was then split into system and player data.
	# Level history is a part of the player data, and should be preserved.
	assert_true(PlayerData.level_history.finished_levels.has("marsh/hello_everyone"))
