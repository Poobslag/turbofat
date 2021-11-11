extends Button
## A button which shows the player's custom keybind, and lets them rebind a key.

## emitted when the player starts or stops rebinding a key
signal awaiting_changed(awaiting)

export (String) var action_name: String
export (int) var action_index: int

## 'true' if this button is waiting for the player to press a key
var awaiting := false

func _ready() -> void:
	connect("pressed", self, "_on_pressed")
	SystemData.keybind_settings.connect("settings_changed", self, "_on_KeybindSettings_settings_changed")
	_refresh_text()


func _input(event: InputEvent) -> void:
	if awaiting:
		var input_json: Dictionary = KeybindManager.input_event_to_json(event)
		if input_json:
			accept_event()
			SystemData.keybind_settings.set_custom_keybind(action_name, action_index, input_json)
			end_awaiting()


## Takes the button out of the 'awaiting state', so it no longer waits for the player to press a key.
func end_awaiting() -> void:
	if not awaiting:
		return
	
	pressed = false
	awaiting = false
	_refresh_text()
	emit_signal("awaiting_changed", awaiting)


## Takes the button into the 'awaiting state', where it waits for the player to press a key.
func _start_awaiting() -> void:
	var custom_keybind_buttons := get_tree().get_nodes_in_group("custom_keybind_buttons")
	for keybind_button in custom_keybind_buttons:
		keybind_button.end_awaiting()
	
	pressed = true
	awaiting = true
	text = tr("<Enter Key>")
	emit_signal("awaiting_changed", awaiting)


## Updates the button's text based on the player's current keybinds.
func _refresh_text() -> void:
	var new_text := ""
	var json: Dictionary = SystemData.keybind_settings.get_custom_keybind(action_name, action_index)
	if json:
		new_text = tr(KeybindManager.pretty_string(json))
	text = new_text


func _on_pressed() -> void:
	if pressed:
		_start_awaiting()
	else:
		end_awaiting()


func _on_KeybindSettings_settings_changed() -> void:
	_refresh_text()
