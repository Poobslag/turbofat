extends Control
"""
Touchscreen buttons displayed for the overworld.
"""

func _ready() -> void:
	if OS.has_touchscreen_ui_hint():
		show()
	else:
		hide()


"""
Shows the touchscreen buttons and captures touch input.
"""
func show() -> void:
	.show()
	# stop ignoring touch input
	$ButtonsSw.show()
	$ButtonsSe.show()


"""
Hides the touchscreen buttons and ignores touch input.
"""
func hide() -> void:
	.hide()
	# release any held buttons, and ignore touch input
	$ButtonsSw.hide()
	$ButtonsSe.hide()


func _on_OverworldUi_chat_started() -> void:
	hide()


func _on_OverworldUi_chat_ended() -> void:
	if OS.has_touchscreen_ui_hint():
		show()


func _on_SettingsMenu_show() -> void:
	hide()


func _on_SettingsMenu_hide() -> void:
	if OS.has_touchscreen_ui_hint():
		show()
