extends Control
## UI control for toggling the soft drop lock cancel.

onready var _check_box := $HBoxContainer/CheckBox
onready var _description := $HBoxContainer/Description

func _ready() -> void:
	SystemData.gameplay_settings.connect("soft_drop_lock_cancel_changed", self,
			"_on_GameplaySettings_soft_drop_lock_cancel_changed")
	_refresh()


func _refresh() -> void:
	_check_box.pressed = SystemData.gameplay_settings.soft_drop_lock_cancel
	_description.modulate = Color(1.0, 1.0, 1.0, 0.5) if SystemData.gameplay_settings.soft_drop_lock_cancel \
			else Color.transparent


func _on_CheckBox_toggled(_button_pressed: bool) -> void:
	if SystemData.gameplay_settings.soft_drop_lock_cancel == _check_box.pressed:
		return
	
	SystemData.gameplay_settings.soft_drop_lock_cancel = _check_box.pressed
	SystemData.has_unsaved_changes = true


func _on_GameplaySettings_soft_drop_lock_cancel_changed(_value: bool) -> void:
	_refresh()
