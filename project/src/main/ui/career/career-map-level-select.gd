extends CanvasLayer
## UI components for career mode's level select buttons.

signal level_button_focused(button_index)

onready var _level_select_buttons := $Control/Top/LevelButtons.get_children()
onready var _control := $Control

func _ready() -> void:
	for i in range(_level_select_buttons.size()):
		var button: Button = _level_select_buttons[i]
		button.connect("focus_entered", self, "_on_LevelSelectButton_focus_entered", [i])


func _on_LevelSelectButton_focus_entered(button_index: int) -> void:
	emit_signal("level_button_focused", button_index)


func _on_SettingsMenu_show() -> void:
	_control.hide()


func _on_SettingsMenu_hide() -> void:
	_control.show()
