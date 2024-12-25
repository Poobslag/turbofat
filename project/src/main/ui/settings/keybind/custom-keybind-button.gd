extends Button
## Button which shows the player's custom keybind, and lets them rebind a key.

## emitted when the player starts or stops rebinding a key
signal awaiting_changed(awaiting)

export (String) var action_name: String
export (int) var action_index: int

## 'true' if this button is waiting for the player to press a key
var awaiting := false

func _ready() -> void:
	SystemData.keybind_settings.connect("settings_changed", self, "_on_KeybindSettings_settings_changed")
	_refresh()


func _input(event: InputEvent) -> void:
	if awaiting:
		var input_json: Dictionary = KeybindManager.input_event_to_json(event)
		if input_json:
			accept_event()
			SystemData.keybind_settings.set_custom_keybind(action_name, action_index, input_json)
			SystemData.has_unsaved_changes = true
			end_awaiting()


func _pressed() -> void:
	if pressed:
		_start_awaiting()
	else:
		end_awaiting()


## Takes the button out of the 'awaiting state', so it no longer waits for the player to press a key.
func end_awaiting() -> void:
	if not awaiting:
		return
	
	pressed = false
	awaiting = false
	_refresh()
	emit_signal("awaiting_changed", awaiting)


## Takes the button into the 'awaiting state', where it waits for the player to press a key.
func _start_awaiting() -> void:
	if not is_inside_tree():
		return
	var custom_keybind_buttons := get_tree().get_nodes_in_group("custom_keybind_buttons")
	for keybind_button in custom_keybind_buttons:
		keybind_button.end_awaiting()
	
	pressed = true
	awaiting = true
	text = tr("<Enter...>")
	icon = null
	emit_signal("awaiting_changed", awaiting)


## Updates the button's text and texture based on the player's current keybinds.
func _refresh() -> void:
	var new_text := ""
	var new_image: Texture = null
	var json: Dictionary = SystemData.keybind_settings.get_custom_keybind(action_name, action_index)
	if json.get("type") == "key":
		new_text = tr(KeybindManager.pretty_string(json))
	elif json.get("type") == "joypad_button":
		new_image = KeybindSettings.xbox_image_for_input_event(json)
	text = new_text
	icon = new_image


func _on_KeybindSettings_settings_changed() -> void:
	_refresh()
