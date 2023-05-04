extends Control
## Touchscreen buttons displayed for the overworld.

func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		SystemData.touch_settings.changed.connect(_on_TouchSettings_settings_changed)
		show()
	else:
		hide()


## Updates the buttons based on the player's settings.
##
## This updates their location, visibility and size.
func _refresh_buttons() -> void:
	if visible and DisplayServer.is_touchscreen_available():
		# stop ignoring touch input
		$ButtonsSw.show()
		$ButtonsSw.scale = Vector2.ONE * SystemData.touch_settings.size
		$ButtonsSw.position.y = size.y - 10 - $ButtonsSw.size.y * $ButtonsSw.scale.y
	else:
		# release any held buttons, and ignore touch input
		$ButtonsSw.hide()


func _on_Menu_shown() -> void:
	hide()


func _on_Menu_hidden() -> void:
	if DisplayServer.is_touchscreen_available():
		show()


func _on_TouchSettings_settings_changed() -> void:
	_refresh_buttons()


func _on_visibility_changed():
	_refresh_buttons()
