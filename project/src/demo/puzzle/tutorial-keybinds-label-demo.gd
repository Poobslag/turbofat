extends Node
## Demonstrates the tutorial keybinds label ability to show different kinds of inputs.
##
## Keys:
## 	[0]: Blank settings
## 	[1]: Guideline settings
## 	[2]: WASD settings
## 	[Q]: Default custom settings
## 	[W]: Random controller settings
## 	[E]: Random keyboard settings

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_0:
			SystemData.keybind_settings.preset = KeybindSettings.CUSTOM
			_set_empty_keybinds()
		KEY_1:
			SystemData.keybind_settings.preset = KeybindSettings.GUIDELINE
		KEY_2:
			SystemData.keybind_settings.preset = KeybindSettings.WASD
		KEY_Q:
			SystemData.keybind_settings.preset = KeybindSettings.CUSTOM
			_restore_default_keybinds()
		KEY_W:
			SystemData.keybind_settings.preset = KeybindSettings.CUSTOM
			_set_random_controller_keybinds()
		KEY_E:
			SystemData.keybind_settings.preset = KeybindSettings.CUSTOM
			_set_random_keyboard_keybinds()


func _restore_default_keybinds() -> void:
	for action_name in KeybindSettings.PUZZLE_ACTION_NAMES:
		SystemData.keybind_settings.restore_default_keybinds(action_name)


func _set_random_controller_keybinds() -> void:
	var shuffled_joypad_buttons := []
	for i in range(16):
		shuffled_joypad_buttons.append(i)
	shuffled_joypad_buttons.shuffle()
	
	for action_name in KeybindSettings.PUZZLE_ACTION_NAMES:
		SystemData.keybind_settings.set_custom_keybind(action_name, 0, \
				{"type": "joypad_button", "device": 0, "button_index": shuffled_joypad_buttons.pop_front()})
		SystemData.keybind_settings.set_custom_keybind(action_name, 1, {})
		SystemData.keybind_settings.set_custom_keybind(action_name, 2, {})


func _set_random_keyboard_keybinds() -> void:
	var shuffled_scancodes := []
	for i in range (32, 91):
		shuffled_scancodes.append(i)
	shuffled_scancodes.shuffle()
	
	for action_name in KeybindSettings.PUZZLE_ACTION_NAMES:
		SystemData.keybind_settings.set_custom_keybind(action_name, 0, \
				{"type": "key", "device": 0, "scancode": shuffled_scancodes.pop_front()})
		SystemData.keybind_settings.set_custom_keybind(action_name, 1, {})
		SystemData.keybind_settings.set_custom_keybind(action_name, 2, {})


func _set_empty_keybinds() -> void:
	for action_name in KeybindSettings.PUZZLE_ACTION_NAMES:
		SystemData.keybind_settings.set_custom_keybind(action_name, 0, {})
		SystemData.keybind_settings.set_custom_keybind(action_name, 1, {})
		SystemData.keybind_settings.set_custom_keybind(action_name, 2, {})
