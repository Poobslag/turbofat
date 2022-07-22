extends "res://addons/gut/test.gd"

const TEMP_FILENAME := "test-ripe-bucket.json"
const TEMP_LEGACY_FILENAME := "test-oven-bucket.save"

func before_each() -> void:
	SystemSave.data_filename = "user://%s" % TEMP_FILENAME
	SystemSave.legacy_filename = "user://%s" % TEMP_LEGACY_FILENAME
	SystemData.reset()


func after_each() -> void:
	var save_dir := Directory.new()
	save_dir.open("user://")
	save_dir.remove(TEMP_FILENAME)
	save_dir.remove(TEMP_LEGACY_FILENAME)


func load_legacy_player_data(filename: String) -> void:
	var dir := Directory.new()
	dir.copy("res://assets/test/%s" % filename, "user://%s" % TEMP_LEGACY_FILENAME)
	SystemSave.load_system_data()


func test_1b3c() -> void:
	load_legacy_player_data("turbofat-1b3c.json")
	
	# 'miscellaneous settings' were renamed to 'misc settings'
	assert_eq(TranslationServer.get_locale(), "es")


func test_27bb() -> void:
	load_legacy_player_data("turbofat-1b3c.json")
	
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("interact"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("phone"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("walk_down"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("walk_left"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("walk_right"), false)
	assert_eq(SystemData.keybind_settings.custom_keybinds.has("walk_up"), false)
