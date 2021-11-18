extends Control
## UI control for toggling the soft drop lock cancel.

onready var _check_box := $CheckBox

func _ready() -> void:
	_check_box.pressed = SystemData.gameplay_settings.soft_drop_lock_cancel


func _on_OptionButton_toggled(_button_pressed: bool) -> void:
	SystemData.gameplay_settings.soft_drop_lock_cancel = _check_box.pressed
