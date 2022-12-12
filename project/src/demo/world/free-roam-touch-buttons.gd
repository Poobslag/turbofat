extends Control
## Touchscreen buttons displayed for the overworld.

func _ready() -> void:
	if OS.has_touchscreen_ui_hint():
		SystemData.touch_settings.connect("settings_changed", self, "_on_TouchSettings_settings_changed")
		_refresh_button_positions()
		show()
	else:
		hide()


## Shows the touchscreen buttons and captures touch input.
func show() -> void:
	.show()
	# stop ignoring touch input
	$ButtonsSw.show()


## Hides the touchscreen buttons and ignores touch input.
func hide() -> void:
	.hide()
	# release any held buttons, and ignore touch input
	$ButtonsSw.hide()


## Updates the buttons based on the player's settings.
##
## This updates their location and size.
func _refresh_button_positions() -> void:
	$ButtonsSw.rect_scale = Vector2.ONE * SystemData.touch_settings.size
	$ButtonsSw.rect_position.y = rect_size.y - 10 - $ButtonsSw.rect_size.y * $ButtonsSw.rect_scale.y


func _on_Menu_show() -> void:
	hide()


func _on_Menu_hide() -> void:
	if OS.has_touchscreen_ui_hint():
		show()


func _on_TouchSettings_settings_changed() -> void:
	_refresh_button_positions()
