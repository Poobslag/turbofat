extends HBoxContainer
"""
UI control for toggling vertical synchronization.
"""

onready var _checkbox_button: CheckBox = $CheckboxButton

func _ready() -> void:
	_checkbox_button.pressed = SystemData.graphics_settings.use_vsync


func _on_CheckboxButton_pressed() -> void:
	SystemData.graphics_settings.use_vsync = _checkbox_button.pressed
