extends Control
## UI control for toggling the soft drop lock cancel.

onready var _check_box := $CheckBox

func _ready() -> void:
	SystemData.gameplay_settings.connect("soft_drop_lock_cancel_changed", self,
			"_on_GameplaySettings_soft_drop_lock_cancel_changed")
	_refresh()


func _refresh() -> void:
	_check_box.pressed = SystemData.gameplay_settings.soft_drop_lock_cancel


func _on_CheckBox_toggled(_button_pressed: bool) -> void:
	SystemData.gameplay_settings.soft_drop_lock_cancel = _check_box.pressed


func _on_GameplaySettings_soft_drop_lock_cancel_changed(_value: bool) -> void:
	_refresh()
