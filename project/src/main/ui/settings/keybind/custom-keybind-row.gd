@tool
extends HBoxContainer
## Row which lets the player define keybinds for a specific action, such as 'Move Piece Left'.

@export var description: String: set = set_description
@export var action_name: String: set = set_action_name

func _ready() -> void:
	_refresh_description_label()
	$Delete.pressed.connect(_on_Delete_pressed)


func set_description(new_description: String) -> void:
	description = new_description
	_refresh_description_label()


func set_action_name(new_action_name: String) -> void:
	action_name = new_action_name
	$Value0.action_name = new_action_name
	$Value1.action_name = new_action_name
	$Value2.action_name = new_action_name


func _refresh_description_label() -> void:
	if not is_inside_tree():
		return

	$Description.text = description


func _on_Delete_pressed() -> void:
	for action_index in range(3):
		SystemData.keybind_settings.set_custom_keybind(action_name, action_index, {})
	
	var custom_keybind_buttons := get_tree().get_nodes_in_group("custom_keybind_buttons")
	for keybind_button in custom_keybind_buttons:
		keybind_button.end_awaiting()
