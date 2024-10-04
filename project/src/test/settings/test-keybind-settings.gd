extends GutTest

func before_each() -> void:
	SystemData.gameplay_settings.reset()


func after_all() -> void:
	SystemData.gameplay_settings.reset()


func test_valid_custom_ui_keybinds() -> void:
	var custom_keybinds := _custom_keybinds()
	SystemData.keybind_settings.custom_keybinds = custom_keybinds
	
	assert_eq(SystemData.keybind_settings.valid_custom_ui_keybinds(), true)


func test_valid_custom_ui_keybinds_missing_keybind_empty_1() -> void:
	var custom_keybinds := _custom_keybinds()
	custom_keybinds["next_tab"] = [{}, {}, {}]
	SystemData.keybind_settings.custom_keybinds = custom_keybinds
	
	assert_eq(SystemData.keybind_settings.valid_custom_ui_keybinds(), false)


func test_valid_custom_ui_keybinds_missing_keybind_null() -> void:
	var custom_keybinds := _custom_keybinds()
	custom_keybinds.erase("next_tab")
	SystemData.keybind_settings.custom_keybinds = custom_keybinds
	
	assert_eq(SystemData.keybind_settings.valid_custom_ui_keybinds(), false)


func test_valid_custom_ui_keybinds_duplicate_keybind() -> void:
	var custom_keybinds := _custom_keybinds()
	custom_keybinds["next_tab"] = [{"type": "key", "scancode": 88}, {}, {}]
	custom_keybinds["prev_tab"] = [{"type": "key", "scancode": 88}, {}, {}]
	SystemData.keybind_settings.custom_keybinds = custom_keybinds
	
	assert_eq(SystemData.keybind_settings.valid_custom_ui_keybinds(), false)


func _custom_keybinds() -> Dictionary:
	var custom_keybinds_text := FileUtils.get_file_as_text("res://assets/main/keybind/default-custom.json")
	return parse_json(custom_keybinds_text)
