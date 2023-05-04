class_name ImageButton
extends Button
## Button represented by a pair of icons.
##
## Pressing the button toggles between the normal and pressed icon. The button's size changes based on the player's
## touch settings.

@export var normal_icon: Texture2D: set = set_normal_icon
@export var pressed_icon: Texture2D: set = set_pressed_icon

func _ready() -> void:
	icon = normal_icon
	SystemData.touch_settings.changed.connect(_on_TouchSettings_settings_changed)
	_refresh_touch_settings()


func set_normal_icon(new_normal_icon: Texture2D) -> void:
	normal_icon = new_normal_icon
	
	if not button_pressed:
		icon = normal_icon


func set_pressed_icon(new_pressed_icon: Texture2D) -> void:
	pressed_icon = new_pressed_icon
	
	if button_pressed:
		icon = pressed_icon


func _refresh_touch_settings() -> void:
	custom_minimum_size = Vector2(96, 96) * SystemData.touch_settings.size
	size = Vector2.ZERO


func _on_button_down() -> void:
	icon = pressed_icon


func _on_button_up() -> void:
	icon = normal_icon


func _on_TouchSettings_settings_changed() -> void:
	_refresh_touch_settings()
