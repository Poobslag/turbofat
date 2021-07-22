extends Control
"""
UI control for toggling the ghost piece.
"""

onready var _checkbox_button := $CheckboxButton

func _ready() -> void:
	_checkbox_button.pressed = SystemData.gameplay_settings.ghost_piece


func _on_OptionButton_toggled(_button_pressed: bool) -> void:
	SystemData.gameplay_settings.ghost_piece = _checkbox_button.pressed
