extends GutTest

var _career_cutscene_librarian := CareerCutsceneLibrarian.new()

func before_all() -> void:
	ChatLibrary.chat_key_root_path = "res://assets/test"
	CareerLevelLibrary.regions_path = "res://assets/test/career/career-regions-kpecz.json"
	CareerCutsceneLibrary.career_cutscene_root_path = "res://assets/test/career/fake-career-kpecz"
	CareerCutsceneLibrary.general_chat_key_root = "career/fake_career_kpecz/general"


func after_all() -> void:
	ChatLibrary.chat_key_root_path = ChatLibrary.DEFAULT_CHAT_KEY_ROOT_PATH
	CareerLevelLibrary.regions_path = CareerLevelLibrary.DEFAULT_REGIONS_PATH
	CareerCutsceneLibrary.career_cutscene_root_path = CareerCutsceneLibrary.DEFAULT_CAREER_CUTSCENE_ROOT_PATH
	CareerCutsceneLibrary.general_chat_key_root = CareerCutsceneLibrary.DEFAULT_GENERAL_CHAT_KEY_ROOT


func before_each() -> void:
	PlayerData.chat_history.reset()
	PlayerData.career.reset()


func test_chat_key_pair_intro_level() -> void:
	# move the player to an intro level
	PlayerData.career.distance_travelled = 10
	var chat_key_pair := _chat_key_pair_for_distance()
	
	assert_eq(chat_key_pair.preroll, "career/fake_career_kpecz/krlbb/intro_level")
	assert_eq(chat_key_pair.postroll, "career/fake_career_kpecz/krlbb/intro_level_end")
	assert_eq(chat_key_pair.type, ChatKeyPair.INTRO_LEVEL)


func test_chat_key_pair_interlude() -> void:
	# move the player to an interlude level
	PlayerData.career.distance_travelled = 15
	PlayerData.career.hours_passed = PlayerData.career.career_interlude_hours()[0]
	var chat_key_pair := _chat_key_pair_for_distance()
	
	assert_eq(chat_key_pair.preroll, "career/fake_career_kpecz/krlbb/000")
	assert_eq(chat_key_pair.postroll, "career/fake_career_kpecz/krlbb/000_end")
	assert_eq(chat_key_pair.type, ChatKeyPair.INTERLUDE)


func test_chat_key_pair_boss_level() -> void:
	# move the player to a boss level
	PlayerData.career.distance_travelled = 9
	var chat_key_pair := _chat_key_pair_for_distance()
	
	assert_eq(chat_key_pair.preroll, "career/fake_career_kpecz/krlaa/boss_level")
	assert_eq(chat_key_pair.postroll, "career/fake_career_kpecz/krlaa/boss_level_end")
	assert_eq(chat_key_pair.type, ChatKeyPair.BOSS_LEVEL)


func test_chat_key_pair_boss_level_already_played() -> void:
	# move the player to a boss level
	PlayerData.career.distance_travelled = 9
	PlayerData.chat_history.add_history_item("career/fake_career_kpecz/krlaa/boss_level")
	PlayerData.chat_history.add_history_item("career/fake_career_kpecz/krlaa/boss_level_end")
	var chat_key_pair := _chat_key_pair_for_distance()
	
	assert_eq(chat_key_pair.preroll, "")
	assert_eq(chat_key_pair.postroll, "")
	assert_eq(chat_key_pair.type, ChatKeyPair.NONE)


func test_chat_key_pair_boss_level_retry() -> void:
	# move the player to a boss level
	PlayerData.career.distance_travelled = 19
	PlayerData.chat_history.add_history_item("career/fake_career_kpecz/krlbb/boss_level")
	var chat_key_pair := _chat_key_pair_for_distance()
	
	assert_eq(chat_key_pair.preroll, "career/fake_career_kpecz/krlbb/boss_level_retry")
	assert_eq(chat_key_pair.postroll, "career/fake_career_kpecz/krlbb/boss_level_end")
	assert_eq(chat_key_pair.type, ChatKeyPair.BOSS_LEVEL)


func test_chat_key_pair_boss_level_reretry_1() -> void:
	# move the player to a boss level
	PlayerData.career.distance_travelled = 19
	PlayerData.chat_history.add_history_item("career/fake_career_kpecz/krlbb/boss_level")
	PlayerData.chat_history.add_history_item("career/fake_career_kpecz/krlbb/boss_level_retry")
	var chat_key_pair := _chat_key_pair_for_distance()
	
	assert_eq(chat_key_pair.preroll, "career/fake_career_kpecz/krlbb/boss_level_reretry")
	assert_eq(chat_key_pair.postroll, "career/fake_career_kpecz/krlbb/boss_level_end")
	assert_eq(chat_key_pair.type, ChatKeyPair.BOSS_LEVEL)


func test_chat_key_pair_boss_level_reretry_2() -> void:
	# move the player to a boss level
	PlayerData.career.distance_travelled = 19
	PlayerData.chat_history.add_history_item("career/fake_career_kpecz/krlbb/boss_level")
	PlayerData.chat_history.add_history_item("career/fake_career_kpecz/krlbb/boss_level_retry")
	PlayerData.chat_history.add_history_item("career/fake_career_kpecz/krlbb/boss_level_reretry")
	var chat_key_pair := _chat_key_pair_for_distance()
	
	assert_eq(chat_key_pair.preroll, "career/fake_career_kpecz/krlbb/boss_level_reretry")
	assert_eq(chat_key_pair.postroll, "career/fake_career_kpecz/krlbb/boss_level_end")
	assert_eq(chat_key_pair.type, ChatKeyPair.BOSS_LEVEL)


func _chat_key_pair_for_distance() -> ChatKeyPair:
	var level: CareerLevel = CareerLevelLibrary.career_levels_for_distance(PlayerData.career.distance_travelled)[0]
	return _career_cutscene_librarian.chat_key_pair(level)
