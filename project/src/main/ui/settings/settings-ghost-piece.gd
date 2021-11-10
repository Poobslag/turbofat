extends Control
## UI control for toggling the ghost piece.

onready var _check_box := $CheckBox

func _ready() -> void:
	_check_box.pressed = SystemData.gameplay_settings.ghost_piece


func _on_OptionButton_toggled(_button_pressed: bool) -> void:
	SystemData.gameplay_settings.ghost_piece = _check_box.pressed
