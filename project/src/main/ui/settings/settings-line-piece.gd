extends Control
## UI control for enabling line pieces to all levels

onready var _check_box := $CheckBox

func _ready() -> void:
	_check_box.pressed = SystemData.gameplay_settings.line_piece


func _on_OptionButton_toggled(_button_pressed: bool) -> void:
	SystemData.gameplay_settings.line_piece = _check_box.pressed
