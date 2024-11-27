extends HBoxContainer
## UI control for toggling chewing sounds.

onready var _check_box: CheckBox = $CheckBox

func _ready() -> void:
	_refresh_checkbox()


func _refresh_checkbox() -> void:
	_check_box.pressed = SystemData.volume_settings.chewing_sounds


func _on_CheckBox_pressed() -> void:
	SystemData.volume_settings.chewing_sounds = _check_box.pressed
	SystemData.has_unsaved_changes = true
