extends VBoxContainer
## UI control for picking a mode in practice mode.
##
## Also displays a description of the mode, 'Score 200 points as quickly as possible!'

signal mode_changed

## group which ensures only one mode button is pressed
onready var button_group: ButtonGroup = $Buttons/Marathon.group

## Returns the currently selected mode string such as 'Normal' or 'Expert'
func get_selected_mode() -> String:
	return button_group.get_pressed_button().name


## Sets the currently selected mode string such as 'Marathon' or 'Sprint'
func set_selected_mode(new_selected_mode: String) -> void:
	match new_selected_mode:
		"Marathon":
			$Buttons/Marathon.pressed = true
		"Ultra":
			$Buttons/Ultra.pressed = true
		"Sprint":
			$Buttons/Sprint.pressed = true
		"Rank":
			$Buttons/Rank.pressed = true
		"Sandbox":
			$Buttons/Sandbox.pressed = true


## Sets the currently selected level, used for generating a description.
func set_level(new_level: LevelSettings) -> void:
	var new_description := new_level.description
	$Desc.text = new_description


func _on_Button_pressed() -> void:
	emit_signal("mode_changed")
