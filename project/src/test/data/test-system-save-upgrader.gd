extends GutTest

const TEMP_PLAYER_FILENAME := "user://test366.save"
const TEMP_SYSTEM_FILENAME := "user://test-ripe-bucket.json"
const TEMP_LEGACY_FILENAME := "user://test-oven-bucket.save"

func before_each() -> void:
	PlayerSave.data_filename = TEMP_PLAYER_FILENAME
	SystemSave.data_filename = TEMP_SYSTEM_FILENAME
	SystemSave.legacy_filename = TEMP_LEGACY_FILENAME
	SystemData.reset()
	var rolling_backups := RollingBackups.new()
	rolling_backups.data_filename = TEMP_PLAYER_FILENAME
	rolling_backups.delete_all_backups()


func after_each() -> void:
	var dir := Directory.new()
	dir.remove(TEMP_SYSTEM_FILENAME)
	dir.remove(TEMP_LEGACY_FILENAME)
	var rolling_backups := RollingBackups.new()
	rolling_backups.data_filename = TEMP_PLAYER_FILENAME
	rolling_backups.delete_all_backups()


func load_system_data(filename: String) -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/data/%s" % filename, TEMP_SYSTEM_FILENAME)
	SystemSave.load_system_data()


func load_player_data(filename: String) -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/data/%s" % filename, TEMP_PLAYER_FILENAME)
	PlayerSave.load_player_data()


func load_legacy_data(filename: String) -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/data/%s" % filename, TEMP_LEGACY_FILENAME)
	SystemSave.load_system_data()


func test_1b3c() -> void:
	var original_locale := TranslationServer.get_locale()
	load_legacy_data("turbofat-1b3c.json")
	
	# 'miscellaneous settings' were renamed to 'misc settings'
	assert_eq(TranslationServer.get_locale(), "es")
	TranslationServer.set_locale(original_locale)


func test_27bb() -> void:
	load_system_data("config-27bb.json")
	load_player_data("turbofat-27bb.json")
	
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("interact"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("phone"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("walk_down"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("walk_left"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("walk_right"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("walk_up"), false)
	
	assert_eq(PlayerData.difficulty.speed, DifficultyData.Speed.DEFAULT)
	assert_eq(PlayerData.difficulty.hold_piece, false)
	assert_eq(PlayerData.difficulty.line_piece, false)


func test_37b3() -> void:
	load_system_data("config-37b3.json")
	
	# should fill in missing keybinds
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("next_tab"), true)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("prev_tab"), true)
	
	# should preserve existing keybinds
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("rotate_ccw"), true)
	assert_eq_deep(SystemData.keybind_settings.custom_keybinds["rotate_ccw"], [
		{"type": "key", "scancode": 91.0},
		{},
		{},
	])


func test_5a24() -> void:
	load_system_data("config-5a24.json")
	load_player_data("turbofat-59c3.json")
	
	# should load difficulty data from file
	assert_eq(PlayerData.difficulty.speed, DifficultyData.Speed.SLOWER)
	assert_eq(PlayerData.difficulty.hold_piece, true)
	assert_eq(PlayerData.difficulty.line_piece, true)


func test_5a24_defaults() -> void:
	load_system_data("config-5a24-default.json")
	load_player_data("turbofat-59c3.json")
	
	# should provide default difficulty
	assert_eq(PlayerData.difficulty.speed, DifficultyData.Speed.DEFAULT)
	assert_eq(PlayerData.difficulty.hold_piece, false)
	assert_eq(PlayerData.difficulty.line_piece, false)


func test_5a24_slowest() -> void:
	load_system_data("config-5a24-slowest.json")
	load_player_data("turbofat-59c3.json")
	
	# 'slowest' is no longer accepted through the UI; should replace with 'slower'
	assert_eq(PlayerData.difficulty.speed, DifficultyData.Speed.SLOWER)
