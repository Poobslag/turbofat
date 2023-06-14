extends RichTextLabel
## Label for tutorials which shows the keybinds.

func _ready() -> void:
	SystemData.keybind_settings.connect("changed", Callable(self, "_on_KeybindSettings_settings_changed"))
	_refresh_message()


## Refreshes the message based on the current InputMap.
func _refresh_message() -> void:
	text = ""
	_append_keybind_line(tr("Move"), ["move_piece_left", "move_piece_right"])
	_append_keybind_line(tr("Soft Drop"), ["soft_drop"])
	_append_keybind_line(tr("Hard Drop"), ["hard_drop"])
	_append_keybind_line(tr("Rotate"), ["rotate_ccw", "rotate_cw"])
	
	# replace wordy phrasing like 'DPAD Left, DPAD Right' with succinct phrasing like 'DPAD'
	text = text.replace("%s, %s" % [tr("Left"), tr("Right")], tr("Arrows"))
	text = text.replace("%s, %s" % [tr("DPAD Left"), tr("DPAD Right")], tr("DPAD"))
	
	if not text:
		# If the player unbinds all of their keys, they can't play.
		text = tr("What have you done!? Click 'Settings' to reconfigure your controls, you silly goose!")
	
	size = Vector2(238, 0)


## Appends a single keybind line to the message, like 'Move: Left, Right'
##
## The inputs such as 'Left' or 'Right' which are shown to the player are derived based on the current InputMap. If the
## InputMap's actions aren't defined, this will append a partial message or no message at all.
##
## Parameters:
## 	'desc': A description of the input, such as 'Rotate'
##
## 	'action_names': One or more action names to translate for the player, such as 'rotate_cw' and 'rotate_ccw'
func _append_keybind_line(desc: String, action_names: Array) -> void:
	var keybind_strings := _keybind_strings(action_names)
	if keybind_strings:
		if text:
			text += "\n"
		if keybind_strings:
			text += "%s: %s" % [desc, ", ".join(PackedStringArray(keybind_strings))]


## Translates a list of action names like 'rotate_cw' and 'rotate_ccw' into human-readable inputs like 'Z' and 'X'.
##
## These inputs are derived based on the current InputMap. If the InputMap's actions aren't defined, the array may have
## fewer items in it, or even be empty.
func _keybind_strings(action_names: Array) -> Array:
	var result := []
	for action_name in action_names:
		var input_event_json := _input_event_json(action_name)
		if input_event_json:
			result.append(tr(KeybindManager.pretty_string(input_event_json)))
	return result


## Returns a json representation of the input for the specified action name.
##
## This is derived based on the earliest translatable input in the current InputMap. If the InputMap's actions aren't
## defined this will return an empty dictionary.
func _input_event_json(action_name: String) -> Dictionary:
	var result := {}
	var action_list := InputMap.action_get_events(action_name)
	if action_list:
		for input_event in action_list:
			result = KeybindManager.input_event_to_json(input_event)
			if result:
				break
	return result


func _on_KeybindSettings_settings_changed() -> void:
	_refresh_message()
