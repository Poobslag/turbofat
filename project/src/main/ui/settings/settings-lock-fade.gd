extends Control
## UI control for toggling the lock fade.

onready var _check_box := $HBoxContainer/CheckBox
onready var _description := $HBoxContainer/Description

func _ready() -> void:
	SystemData.gameplay_settings.connect("lock_fade_changed", self,
			"_on_GameplaySettings_lock_fade_changed")
	_refresh()


func _refresh() -> void:
	_check_box.pressed = SystemData.gameplay_settings.lock_fade
	_description.modulate = Color(1.0, 1.0, 1.0, 0.5) if SystemData.gameplay_settings.lock_fade \
			else Color.transparent


func _on_CheckBox_toggled(_button_pressed: bool) -> void:
	if SystemData.gameplay_settings.lock_fade == _check_box.pressed:
		return
	
	SystemData.gameplay_settings.lock_fade = _check_box.pressed
	SystemData.has_unsaved_changes = true


func _on_GameplaySettings_lock_fade_changed(_value: bool) -> void:
	_refresh()
