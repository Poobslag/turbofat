extends GutTest

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
	dir.copy("res://assets/test/data/%s" % filename, "user://%s" % TEMP_LEGACY_FILENAME)
	PlayerSave.load_player_data()


func load_player_data(filename: String) -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/data/%s" % filename, "user://%s" % TEMP_FILENAME)
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


## Note: There is no test for save data version 1682. The updater performs some chat history renames, but these chat
## items are nonexistent in the newest version of the game because of the removal of free roam mode


func test_199c() -> void:
	load_legacy_player_data("turbofat-199c.json")
	
	assert_eq(PlayerData.level_history.successful_levels.has("practice/marathon_normal"), true)
	assert_eq(PlayerData.level_history.successful_levels.has("rank/7k"), true)
	
	assert_eq(PlayerData.level_history.finished_levels.has("rank/7k"), true)


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


## Note: There is no test for save data version 245b or 24cc. The updater performs some chat history/level history
## tweaks, but these chat items and levels are nonexistent in the newest version of the game because of the removal of
## free roam mode


func test_2743() -> void:
	load_legacy_player_data("turbofat-2743.json")
	
	assert_almost_eq(PlayerData.creature_library.get_fatness("#filler_000#"), 1.03, 0.01)
	assert_almost_eq(PlayerData.creature_library.get_fatness("#filler_100#"), 1.68, 0.01)
	assert_almost_eq(PlayerData.creature_library.get_fatness("i_n_cognito"), 1.30, 0.01)


func test_2783() -> void:
	load_legacy_player_data("turbofat-2783.json")
	
	# We did not measure playtime in 2783, but we can approximate it based on the player's money.
	assert_almost_eq(PlayerData.seconds_played, 1181359.0, 0.1)
	
	# Save data was in one file in 2783, but was then split into system and player data.
	# Level history is a part of the player data, and should be preserved.
	assert_true(PlayerData.level_history.finished_levels.has("rank/7k"))


func test_27bb() -> void:
	load_player_data("turbofat-27bb.json")
	
	# changed 'max_distance_travelled' to 'best_distance_travelled'
	assert_eq(PlayerData.career.best_distance_travelled, 167)


func test_36c3() -> void:
	load_player_data("turbofat-36c3.json")
	
	# changed 'chat_theme_def' to 'chat_theme
	assert_eq(PlayerData.creature_library.player_def.chat_theme.accent_scale, 1.33)
	assert_eq(PlayerData.creature_library.player_def.chat_theme.accent_swapped, true)
	assert_eq(PlayerData.creature_library.player_def.chat_theme.accent_texture_index, 13)
	assert_eq(PlayerData.creature_library.player_def.chat_theme.color, Color("907027"))
	assert_eq(PlayerData.creature_library.player_def.chat_theme.dark, false)


func test_375c() -> void:
	load_player_data("turbofat-375c.json")
	
	# added missing 'finished_level' entries -- successful levels weren't recorded as finished
	assert_eq(PlayerData.level_history.finished_levels.keys(), ["practice/marathon_normal"])
	
	# update sandbox data to 'm' rank
	var best_result := PlayerData.level_history.best_result("practice/sandbox_normal")
	assert_eq(best_result.score_rank, 0.0)


## With the removal of free roam mode, we also remove all of the old level history items.
##
## This includes levels specific to free roam mode as well as experimental levels from older Turbo Fat versions. Each
## level's history is about 4 kb, so added together across 3 save slots and 7 (!) rotating backups, this can add up to
## about 4-5 megabytes that we're cleaning up
func test_3776_level_history_purged() -> void:
	load_player_data("turbofat-3776.json")
	
	# finished levels
	var finished_levels := PlayerData.level_history.finished_levels
	assert_eq(finished_levels.has("tutorial/basics_0"), true)
	assert_eq(finished_levels.has("boatricia"), false)
	assert_eq(finished_levels.has("practice/sandbox_hard"), false)
	assert_eq(finished_levels.has("marsh/hello_everyone"), false)
	assert_eq(finished_levels.has("five-customers-no-vegetables"), false)
	assert_eq(finished_levels.has("career/bottomless_pit_2"), false) # removed later in 49eb
	
	# successful levels
	var successful_levels := PlayerData.level_history.successful_levels
	assert_eq(successful_levels.has("practice/marathon_hard"), true)
	assert_eq(successful_levels.has("bogus_level"), false)
	assert_eq(successful_levels.has("career/bottomless_pit_2"), false) # removed later in 49eb
	
	# level history
	var rank_results := PlayerData.level_history.rank_results
	assert_eq(rank_results.has("practice/marathon_hard"), true)
	assert_eq(rank_results.has("boatricia"), false)
	assert_eq(rank_results.has("practice/sandbox_hard"), false)
	assert_eq(rank_results.has("marsh/hello_everyone"), false)
	assert_eq(rank_results.has("five-customers-no-vegetables"), false)
	assert_eq(rank_results.has("career/bottomless_pit_2"), false) # removed later in 49eb


## With the removal of free roam mode, we also remove all of the old chat history items.
##
## This includes chats specific to free roam mode as well as from older Turbo Fat versions.
func test_3776_chat_history_purged() -> void:
	load_player_data("turbofat-3776.json")
	
	# chat history
	var history_index_by_chat_key := PlayerData.chat_history.history_index_by_chat_key
	assert_eq(history_index_by_chat_key.has("chat/career/marsh/010_b"), true)
	assert_eq(history_index_by_chat_key.has("chat/level_select"), false)
	assert_eq(history_index_by_chat_key.has("creature/bort/filler_000"), false)
	assert_eq(history_index_by_chat_key.has("level/marsh/pulling_for_everyone_100"), false)


func test_37b3_chat_history_migrated() -> void:
	load_player_data("turbofat-37b3.json")
	
	assert_eq(PlayerData.chat_history.chat_age("chat/career/general/000_b"), 10)
	assert_eq(PlayerData.chat_history.chat_age("chat/career/marsh/010_c_end"), 7)
	assert_eq(PlayerData.chat_history.chat_age("chat/career/marsh/060_end"), 1)
	assert_eq(PlayerData.chat_history.chat_age("chat/career/marsh/epilogue"), 0)


func test_prepend_third_zero() -> void:
	var upgrader: PlayerSaveUpgrader = PlayerSaveUpgrader.new()
	assert_eq(upgrader.prepend_third_zero("ilesa/sin/00_ibo_suture"), "ilesa/sin/000_ibo_suture")
	assert_eq(upgrader.prepend_third_zero("ilesa_40"), "ilesa_040")
	assert_eq(upgrader.prepend_third_zero("ilesa_21_sin"), "ilesa_021_sin")
	assert_eq(upgrader.prepend_third_zero("93_ilesa"), "093_ilesa")
	assert_eq(upgrader.prepend_third_zero("36_ilesa_72"), "036_ilesa_072")
	assert_eq(upgrader.prepend_third_zero("ilesa"), "ilesa")
	assert_eq(upgrader.prepend_third_zero("ilesa_443_sin"), "ilesa_443_sin")
	assert_eq(upgrader.prepend_third_zero("ilesa_8_sin"), "ilesa_8_sin")
