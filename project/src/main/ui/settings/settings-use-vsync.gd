extends HBoxContainer
## UI control for toggling vertical synchronization.

onready var _check_box: CheckBox = $CheckBox

func _ready() -> void:
	_check_box.pressed = SystemData.graphics_settings.use_vsync


func _on_CheckBox_pressed() -> void:
	if SystemData.graphics_settings.use_vsync == _check_box.pressed:
		return
	
	SystemData.graphics_settings.use_vsync = _check_box.pressed
	SystemData.has_unsaved_changes = true
