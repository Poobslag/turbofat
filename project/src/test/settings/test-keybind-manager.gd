extends GutTest

func test_pretty_string_keys() -> void:
	var original_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	
	assert_eq(KeybindManager.pretty_string({"type": "key", "scancode": 0}), "")
	assert_eq(KeybindManager.pretty_string({"type": "key", "scancode": 82}), "R")
	assert_eq(KeybindManager.pretty_string({"type": "key", "scancode": 16777231}), "Left")
	
	TranslationServer.set_locale(original_locale)


func test_pretty_string_joypad_buttons() -> void:
	var original_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	
	assert_eq(KeybindManager.pretty_string({"type": "joypad_button", "device": 0, "button_index": 0}), "Face Bottom")
	assert_eq(KeybindManager.pretty_string({"type": "joypad_button", "device": 0, "button_index": 1}), "Face Right")
	assert_eq(KeybindManager.pretty_string({"type": "joypad_button", "device": 0, "button_index": 5}), "R")
	assert_eq(KeybindManager.pretty_string({"type": "joypad_button", "device": 0, "button_index": 14}), "DPAD Left")
	
	TranslationServer.set_locale(original_locale)
