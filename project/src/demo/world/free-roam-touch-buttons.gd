extends Control
## Touchscreen buttons displayed for the overworld.

func _ready() -> void:
	if OS.has_touchscreen_ui_hint():
		SystemData.touch_settings.connect("settings_changed", self, "_on_TouchSettings_settings_changed")
		show()
	else:
		hide()


## Updates the buttons based on the player's settings.
##
## This updates their location, visibility and size.
func _refresh_buttons() -> void:
	if visible and OS.has_touchscreen_ui_hint():
		# stop ignoring touch input
		$ButtonsSw.show()
		$ButtonsSw.rect_scale = Vector2.ONE * SystemData.touch_settings.size
		$ButtonsSw.rect_position.y = rect_size.y - 10 - $ButtonsSw.rect_size.y * $ButtonsSw.rect_scale.y
	else:
		# release any held buttons, and ignore touch input
		$ButtonsSw.hide()


func _on_Menu_show() -> void:
	hide()


func _on_Menu_hide() -> void:
	if OS.has_touchscreen_ui_hint():
		show()


func _on_TouchSettings_settings_changed() -> void:
	_refresh_buttons()


func _on_TouchButtons_visibility_changed():
	_refresh_buttons()
