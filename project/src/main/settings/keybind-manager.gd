extends Node
## Binds the player's input settings to the input map.

## Mapping from joystick scancodes to names. Adapted from the names in Godot 3.x
## https://github.com/madmiraal/godot/blob/280d4e2965db7d448ce0f0ee3902559ee3f2a467/editor/input_map_editor.cpp
##
## key: (int) Joystick button scancode
## value: (String) Description shown to the player for the button
var names_by_joy_button := {
	JOY_BUTTON_A: tr("Face Bottom"),
	JOY_BUTTON_B: tr("Face Right"),
	JOY_BUTTON_X: tr("Face Left"),
	JOY_BUTTON_Y: tr("Face Top"),
	JOY_BUTTON_BACK: tr("Select"),
	JOY_BUTTON_GUIDE: tr("Guide"),
	JOY_BUTTON_START: tr("Start"),
	JOY_BUTTON_LEFT_STICK: tr("L3"),
	JOY_BUTTON_RIGHT_STICK: tr("R3"),
	JOY_BUTTON_LEFT_SHOULDER: tr("L"),
	JOY_BUTTON_RIGHT_SHOULDER: tr("R"),
	JOY_BUTTON_DPAD_UP: tr("D-Pad Up"),
	JOY_BUTTON_DPAD_DOWN: tr("D-Pad Down"),
	JOY_BUTTON_DPAD_LEFT: tr("D-Pad Left"),
	JOY_BUTTON_DPAD_RIGHT: tr("D-Pad Right"),
	JOY_BUTTON_MISC1: tr("Misc 1"),
	JOY_BUTTON_PADDLE1: tr("Paddle 1"),
	JOY_BUTTON_PADDLE2: tr("Paddle 2"),
	JOY_BUTTON_PADDLE3: tr("Paddle 3"),
	JOY_BUTTON_PADDLE4: tr("Paddle 4"),
	JOY_BUTTON_TOUCHPAD: tr("Touchpad"),
}

func _ready() -> void:
	SystemData.keybind_settings.changed.connect(_on_KeybindSettings_settings_changed)
	SystemData.gameplay_settings.hold_piece_changed.connect(_on_GameplaySettings_hold_piece_changed)


## Converts a json dictionary to an InputEvent instance.
##
## This supports InputEventKey and InputEventJoypadButton events. It does not support joystick, mouse or touch events.
func input_event_from_json(json: Dictionary) -> InputEvent:
	if json.is_empty():
		return null
	
	var input_event: InputEvent
	match json.get("type"):
		"key":
			var input_event_key := InputEventKey.new()
			input_event_key.keycode = json.get("scancode")
			input_event = input_event_key
		"joypad_button":
			var input_event_joypad_button := InputEventJoypadButton.new()
			input_event_joypad_button.device = json.get("device")
			input_event_joypad_button.button_index = json.get("button_index")
			input_event = input_event_joypad_button
		_:
			push_warning("Unrecognized input event type: '%s'" % [json.get("type")])
	return input_event


## Converts an InputEvent to a json dictionary.
##
## This supports InputEventKey and InputEventJoypadButton events. It does not support joystick, mouse or touch events.
func input_event_to_json(input_event: InputEvent) -> Dictionary:
	var json := {}
	if input_event is InputEventKey:
		json["type"] = "key"
		json["scancode"] = input_event.keycode
	elif input_event is InputEventJoypadButton:
		json["type"] = "joypad_button"
		json["device"] = input_event.device
		json["button_index"] = input_event.button_index
	return json


## Returns a string representation of an input, suitable for showing to the player.
##
## Parameters:
## 	'input_json': A json representation of a keyboard or joypad input
##
## Returns:
## 	A short human-readable string like 'D-Pad Left' or 'Escape'
func pretty_string(input_json: Dictionary) -> String:
	var result: String
	match input_json["type"]:
		"key":
			result = OS.get_keycode_string(input_json["scancode"])
		"joypad_button":
			result = get_joy_button_string(input_json["button_index"])
	return result


func get_joy_button_string(button_index: int) -> String:
	var result: String
	if button_index in names_by_joy_button:
		result = names_by_joy_button.get(button_index)
	else:
		result = tr("Joypad Button %s") % [button_index]
	return result


## Updates the InputMap with the bindings in the specified json file
func _bind_keys_from_file(path: String) -> void:
	var json_text := FileUtils.get_file_as_text(path)
	var json_dict: Dictionary = JSON.parse_string(json_text)
	_bind_keys_from_json_dict(json_dict)


## Updates the InputMap with the bindings in the specified json
func _bind_keys_from_json_dict(json: Dictionary) -> void:
	for action_name in json:
		var input_events := []
		for input_event_json in json.get(action_name):
			var input_event := input_event_from_json(input_event_json)
			if input_event:
				input_events.append(input_event)
		
		_bind_keys(action_name, input_events)


## Updates a single InputMap action with the specified bindings
##
## This replaces all bindings for the specified action with a new set of bindings.
##
## Parameters:
## 	'action_name': the action to rebind
##
## 	'input_events': the InputEvents to bind
func _bind_keys(action_name: String, input_events: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	for input_event in input_events:
		InputMap.action_add_event(action_name, input_event)


func _refresh_keybinds() -> void:
	match SystemData.keybind_settings.preset:
		KeybindSettings.GUIDELINE:
			var path := KeybindSettings.GUIDELINE_PATH
			if SystemData.gameplay_settings.hold_piece:
				path = KeybindSettings.GUIDELINE_HOLD_PATH
			_bind_keys_from_file(path)
		KeybindSettings.WASD:
			var path := KeybindSettings.WASD_PATH
			if SystemData.gameplay_settings.hold_piece:
				path = KeybindSettings.WASD_HOLD_PATH
			_bind_keys_from_file(path)
		KeybindSettings.CUSTOM:
			_bind_keys_from_json_dict(SystemData.keybind_settings.custom_keybinds)
		_:
			push_warning("Unrecognized keybind settings preset: %s" % SystemData.keybind_settings.preset)


## Updates the InputMap when the player's keybind settings change
func _on_KeybindSettings_settings_changed() -> void:
	_refresh_keybinds()


func _on_GameplaySettings_hold_piece_changed(_value: bool) -> void:
	_refresh_keybinds()
