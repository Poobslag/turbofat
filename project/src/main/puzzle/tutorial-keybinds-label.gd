extends RichTextLabel
## Label for tutorials which shows the keybinds.

## Size of joypad image textures
const IMAGE_SIZE := Vector2(24, 24)

func _ready() -> void:
	InputManager.connect("input_mode_changed", self, "_on_InputManager_input_mode_changed")
	SystemData.keybind_settings.connect("settings_changed", self, "_on_KeybindSettings_settings_changed")
	_refresh_message()


## Refreshes the message based on the current InputMap.
func _refresh_message() -> void:
	text = ""
	
	_append_keybind_line(tr("Move"), ["move_piece_left", "move_piece_right"])
	_append_keybind_line(tr("Soft Drop"), ["soft_drop"])
	_append_keybind_line(tr("Hard Drop"), ["hard_drop"])
	_append_keybind_line(tr("Rotate"), ["rotate_ccw", "rotate_cw"])

	if not text:
		# If the player unbinds all of their keys, they can't play.
		text = tr("What have you done!? Go into 'Settings' and reconfigure your controls, you silly goose!")
	
	# shrink the label to its minimum vertical size
	call_deferred("set", "rect_size", Vector2(238, 0))


## Appends a single keybind line to the message, like 'Left, Right: Move'
##
## The inputs such as 'Left' or 'Right' which are shown to the player are derived based on the current InputMap. If the
## InputMap's actions aren't defined, this will append a partial message or no message at all.
##
## Parameters:
## 	'desc': A description of the input, such as 'Rotate'
##
## 	'action_names': One or more action names to translate for the player, such as 'rotate_cw' and 'rotate_ccw'
func _append_keybind_line(desc: String, action_names: Array) -> void:
	if text:
		newline()
	var previous_item_was_text := false
	var line_is_empty := true
	
	var input_event_jsons := []
	for action_name in action_names:
		input_event_jsons.append(_input_event_json(action_name))
	
	for input_event_json in input_event_jsons:
		match input_event_json.get("type"):
			"joypad_button":
				# append an image texture corresponding to a joypad button
				var image: Texture = KeybindSettings.xbox_image_for_input_event(input_event_json)
				if image:
					if previous_item_was_text:
						add_text(", ")
					add_image(image, IMAGE_SIZE.x, IMAGE_SIZE.y, INLINE_ALIGN_CENTER)
					line_is_empty = false
					previous_item_was_text = true
			"key":
				# append text corresponding to a keyboard button
				var new_text := tr(KeybindManager.pretty_string(input_event_json))
				if new_text:
					if previous_item_was_text:
						add_text(", ")
					add_text(new_text)
					line_is_empty = false
					previous_item_was_text = true

	if not line_is_empty:
		add_text(": %s" % [desc])


## Returns a json representation of the input for the specified action name.
##
## This is derived based on the earliest translatable input in the current InputMap. If the InputMap's actions aren't
## defined this will return an empty dictionary.
func _input_event_json(action_name: String) -> Dictionary:
	var result := {}
	var action_list := InputMap.get_action_list(action_name)
	if action_list:
		for input_event in action_list:
			var input_event_json := KeybindManager.input_event_to_json(input_event)
			if input_event_json:
				result = input_event_json
			if result and result.get("type") == "key" and InputManager.input_mode == InputManager.KEYBOARD_MOUSE:
				break
			if result and result.get("type") == "joypad_button" and InputManager.input_mode == InputManager.JOYPAD:
				break
	return result


func _on_KeybindSettings_settings_changed() -> void:
	_refresh_message()


func _on_InputManager_input_mode_changed() -> void:
	_refresh_message()
