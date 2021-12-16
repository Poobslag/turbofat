class_name CareerLevelSelect
extends CanvasLayer
## UI components for career mode's level select buttons.

signal level_button_focused(button_index)

onready var _level_select_buttons := $Control/LevelButtons.get_children()
onready var _control := $Control

func _ready() -> void:
	for i in range(_level_select_buttons.size()):
		var button: Button = _level_select_buttons[i]
		button.connect("focus_entered", self, "_on_LevelSelectButton_focus_entered", [i])


## Returns the index of the currently focused level button, or -1 if none is selected.
##
## For a boss level where only one level is available, this will return '0' if the level button is selected.
func focused_level_button_index() -> int:
	return _level_select_buttons.find(_control.get_focus_owner())


func _on_LevelSelectButton_focus_entered(button_index: int) -> void:
	emit_signal("level_button_focused", button_index)


func _on_SettingsMenu_show() -> void:
	_control.hide()


func _on_SettingsMenu_hide() -> void:
	_control.show()
