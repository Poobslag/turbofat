extends Control
"""
UI control for toggling the ghost piece.
"""

func _ready() -> void:
	$OptionButton.pressed = PlayerData.gameplay_settings.ghost_piece


func _on_OptionButton_toggled(_button_pressed: bool) -> void:
	PlayerData.gameplay_settings.ghost_piece = $OptionButton.pressed
