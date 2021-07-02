class_name ImageButton
extends Button
"""
A button represented by a pair of icons.

Pressing the button toggles between the normal and pressed icon. The button's size changes based on the player's touch
settings.
"""

export (Texture) var normal_icon: Texture setget set_normal_icon
export (Texture) var pressed_icon: Texture setget set_pressed_icon

func _ready() -> void:
	icon = normal_icon
	PlayerData.touch_settings.connect("settings_changed", self, "_on_TouchSettings_settings_changed")
	_refresh_touch_settings()


func set_normal_icon(new_normal_icon: Texture) -> void:
	normal_icon = new_normal_icon
	
	if not pressed:
		icon = normal_icon


func set_pressed_icon(new_pressed_icon: Texture) -> void:
	pressed_icon = new_pressed_icon
	
	if pressed:
		icon = pressed_icon


func _refresh_touch_settings() -> void:
	rect_min_size = Vector2(96, 96) * PlayerData.touch_settings.size
	rect_size = Vector2(0, 0)


func _on_button_down() -> void:
	icon = pressed_icon


func _on_button_up() -> void:
	icon = normal_icon


func _on_TouchSettings_settings_changed() -> void:
	_refresh_touch_settings()
