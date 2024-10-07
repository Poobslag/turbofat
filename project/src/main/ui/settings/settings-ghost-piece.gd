extends Control
## UI control for toggling the ghost piece.

onready var _check_box := $CheckBox

func _ready() -> void:
	SystemData.gameplay_settings.connect("ghost_piece_changed", self, "_on_GameplaySettings_ghost_piece_changed")
	_refresh()


func _refresh() -> void:
	_check_box.pressed = SystemData.gameplay_settings.ghost_piece


func _on_CheckBox_toggled(_button_pressed: bool) -> void:
	if SystemData.gameplay_settings.ghost_piece == _check_box.pressed:
		return
	
	SystemData.gameplay_settings.ghost_piece = _check_box.pressed
	SystemData.has_unsaved_changes = true


func _on_GameplaySettings_ghost_piece_changed(_value: bool) -> void:
	_refresh()
