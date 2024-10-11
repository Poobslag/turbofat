tool
extends HBoxContainer
## Row which shows the player the keybinds for a specific action, such as 'Move Piece Left'.
##
## This row is used for presets like 'Guideline' and 'WASD', and is non-interactive.

## Size of joypad image textures
const IMAGE_SIZE := Vector2(20, 20)

export (String) var description: String setget set_description

## String and Texture instances shown for the keybind. Strings are used for keys like "Backspace", textures are used
## for XBox buttons like the A button.
export (Array) var keybind_values: Array setget set_keybind_values

func _ready() -> void:
	_refresh_description_label()
	_refresh_keybind_value_label()


func set_description(new_description: String) -> void:
	description = new_description
	_refresh_description_label()


func set_keybind_values(new_keybind_values: Array) -> void:
	keybind_values = new_keybind_values
	_refresh_keybind_value_label()


func _refresh_description_label() -> void:
	$Description.text = description


## Updates the text to include all strings and images in the 'texture keybind' property.
func _refresh_keybind_value_label() -> void:
	var previous_item_was_text := false
	$Value.text = ""
	for keybind_value in keybind_values:
		if keybind_value is String and keybind_value:
			if previous_item_was_text:
				$Value.add_text(", ")
			$Value.add_text(keybind_value)
			previous_item_was_text = true
		if keybind_value is Texture:
			if previous_item_was_text:
				$Value.add_text(", ")
			$Value.add_image(keybind_value, IMAGE_SIZE.x, IMAGE_SIZE.y)
			previous_item_was_text = false
