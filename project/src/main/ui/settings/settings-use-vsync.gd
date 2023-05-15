extends HBoxContainer
## UI control for toggling vertical synchronization.

@onready var _check_box: CheckBox = $CheckBox

func _ready() -> void:
	_check_box.button_pressed = SystemData.graphics_settings.use_vsync


func _on_CheckBox_pressed() -> void:
	SystemData.graphics_settings.use_vsync = _check_box.pressed
