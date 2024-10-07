extends HBoxContainer
## UI control for toggling fullscreen.

## Platforms where this toggle should be visible. Web and mobile targets do not support windowing.
const WINDOWABLE_PLATFORMS := ["osx", "windows", "x11"]

onready var _check_box: CheckBox = $CheckBox

func _ready() -> void:
	_refresh_checkbox()
	SystemData.graphics_settings.connect("fullscreen_changed", self, "_on_GraphicsSettings_fullscreen_changed")
	
	if not OS.get_name().to_lower() in WINDOWABLE_PLATFORMS:
		# hide component for web or mobile targets
		visible = false


func _refresh_checkbox() -> void:
	_check_box.pressed = SystemData.graphics_settings.fullscreen


func _on_CheckBox_pressed() -> void:
	SystemData.graphics_settings.fullscreen = _check_box.pressed
	SystemData.has_unsaved_changes = true


func _on_GraphicsSettings_fullscreen_changed(_value: bool) -> void:
	_refresh_checkbox()
