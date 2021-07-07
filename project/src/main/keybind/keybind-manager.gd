extends Node
"""
Binds the player's input settings to the input map.
"""

func _ready() -> void:
	PlayerData.keybind_settings.connect("settings_changed", self, "_on_KeybindSettings_settings_changed")


"""
Converts a json dictionary to an InputEvent instance.

This supports InputEventKey and InputEventJoypadButton events. It does not support joystick, mouse or touch events.
"""
func input_event_from_json(json: Dictionary) -> InputEvent:
	if not json:
		return null
	
	var input_event: InputEvent
	match json.get("type"):
		"key":
			var input_event_key := InputEventKey.new()
			input_event_key.scancode = json.get("scancode")
			input_event = input_event_key
		"joypad_button":
			var input_event_joypad_button := InputEventJoypadButton.new()
			input_event_joypad_button.device = json.get("device")
			input_event_joypad_button.button_index = json.get("button_index")
			input_event = input_event_joypad_button
		_:
			push_warning("Unrecognized input event type: '%s'" % [json.get("type")])
	return input_event


"""
Converts an InputEvent to a json dictionary.

This supports InputEventKey and InputEventJoypadButton events. It does not support joystick, mouse or touch events.
"""
func input_event_to_json(input_event: InputEvent) -> Dictionary:
	var json := {}
	if input_event is InputEventKey:
		json["type"] = "key"
		json["scancode"] = input_event.scancode
	elif input_event is InputEventJoypadButton:
		json["type"] = "joypad_button"
		json["device"] = input_event.device
		json["button_index"] = input_event.button_index
	return json


"""
Returns a string representation of an input, suitable for showing to the player.

Parameters:
	'input_json': A json representation of a keyboard or joypad input

Returns:
	A short human-readable string like 'DPAD Left' or 'Escape'
"""
func pretty_string(input_json: Dictionary) -> String:
	var result: String
	match input_json["type"]:
		"key":
			result = OS.get_scancode_string(input_json["scancode"])
		"joypad_button":
			result = Input.get_joy_button_string(input_json["button_index"])
			result = result.replace("Face Button", "Face")
	return result


"""
Updates the InputMap with the bindings in the specified json file
"""
func _bind_keys_from_file(path: String) -> void:
	var json_text := FileUtils.get_file_as_text(path)
	var json_dict: Dictionary = parse_json(json_text)
	_bind_keys_from_json_dict(json_dict)


"""
Updates the InputMap with the bindings in the specified json
"""
func _bind_keys_from_json_dict(json: Dictionary) -> void:
	for action_name in json:
		var input_events := []
		for input_event_json in json.get(action_name):
			var input_event := input_event_from_json(input_event_json)
			if input_event:
				input_events.append(input_event)
		
		_bind_keys(action_name, input_events)


"""
Updates a single InputMap action with the specified bindings

This replaces all bindings for the specified action with a new set of bindings.

Parameters:
	'action_name': the action to rebind
	
	'input_events': the InputEvents to bind
"""
func _bind_keys(action_name: String, input_events: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	for input_event in input_events:
		InputMap.action_add_event(action_name, input_event)


"""
Updates the InputMap when the player's keybind settings change
"""
func _on_KeybindSettings_settings_changed() -> void:
	match PlayerData.keybind_settings.preset:
		KeybindSettings.GUIDELINE:
			_bind_keys_from_file("res://assets/main/keybind/guideline.json")
		KeybindSettings.WASD:
			_bind_keys_from_file("res://assets/main/keybind/wasd.json")
		KeybindSettings.CUSTOM:
			_bind_keys_from_json_dict(PlayerData.keybind_settings.custom_keybinds)
		_:
			push_warning("Unrecognized keybind settings preset: %s" % PlayerData.keybind_settings.preset)
