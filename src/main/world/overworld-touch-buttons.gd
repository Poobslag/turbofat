extends Control
"""
Touchscreen buttons displayed for the overworld.
"""

# control scheme which emulates consoles; directions on left, buttons on right
const CONSOLE_SCHEME := {
	"sw_actions": ["ui_up", "ui_down", "ui_left", "ui_right"],
	"sw_weights": [1, 1, 1, 1],
	"se_actions": ["ui_menu", "interact", "", ""],
	"se_weights": [0, 0, 0, 0],
}

# control scheme which emulates PCs; buttons on left, directions on right
const DESKTOP_SCHEME := {
	"sw_actions": ["ui_menu", "interact", "", ""],
	"sw_weights": [0, 0, 0, 0],
	"se_actions": ["ui_up", "ui_down", "ui_left", "ui_right"],
	"se_weights": [1, 1, 1, 1],
}

func _ready() -> void:
	if OS.has_touchscreen_ui_hint():
		PlayerData.touch_settings.connect("settings_changed", self, "_on_TouchSettings_settings_changed")
		_refresh_settings()
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


"""
Updates the buttons based on the player's settings.

This updates their location and size.
"""
func _refresh_button_positions() -> void:
	$ButtonsSw.rect_scale = Vector2(1.0, 1.0) * PlayerData.touch_settings.size
	$ButtonsSw.rect_position.y = 600 - 10 - $ButtonsSw.rect_size.y * $ButtonsSw.rect_scale.y
	
	$ButtonsSe.rect_scale = Vector2(1.0, 1.0) * PlayerData.touch_settings.size
	$ButtonsSe.rect_position.x = 1024 - 10 - $ButtonsSw.rect_size.x * $ButtonsSw.rect_scale.x
	$ButtonsSe.rect_position.y = 600 - 10 - $ButtonsSw.rect_size.y * $ButtonsSw.rect_scale.y


"""
Updates the buttons based on the player's settings.

This updates their location, size, how they're arranged and their sensitivity.
"""
func _refresh_settings() -> void:
	# update scale/position
	_refresh_button_positions()
	
	# update actions
	var scheme_dict: Dictionary
	match PlayerData.touch_settings.scheme:
		TouchSettings.EASY_CONSOLE, TouchSettings.AMBI_CONSOLE, TouchSettings.LOCO_CONSOLE:
			scheme_dict = CONSOLE_SCHEME
		TouchSettings.EASY_DESKTOP, TouchSettings.AMBI_DESKTOP, TouchSettings.LOCO_DESKTOP:
			scheme_dict = DESKTOP_SCHEME
		_:
			push_warning("Unrecognized touch settings scheme: %s" % PlayerData.touch_settings.scheme)
			scheme_dict = CONSOLE_SCHEME
	$ButtonsSw.up_action = scheme_dict["sw_actions"][0]
	$ButtonsSw.down_action = scheme_dict["sw_actions"][1]
	$ButtonsSw.left_action = scheme_dict["sw_actions"][2]
	$ButtonsSw.right_action = scheme_dict["sw_actions"][3]
	$ButtonsSe.up_action = scheme_dict["se_actions"][0]
	$ButtonsSe.down_action = scheme_dict["se_actions"][1]
	$ButtonsSe.left_action = scheme_dict["se_actions"][2]
	$ButtonsSe.right_action = scheme_dict["se_actions"][3]
	
	# update diagonal sensitivity
	$ButtonsSw.up_left_weight = scheme_dict["sw_weights"][0]
	$ButtonsSw.up_right_weight = scheme_dict["sw_weights"][1]
	$ButtonsSw.down_left_weight = scheme_dict["sw_weights"][2]
	$ButtonsSw.down_right_weight = scheme_dict["sw_weights"][3]
	$ButtonsSe.up_left_weight = scheme_dict["se_weights"][0]
	$ButtonsSe.up_right_weight = scheme_dict["se_weights"][1]
	$ButtonsSe.down_left_weight = scheme_dict["se_weights"][2]
	$ButtonsSe.down_right_weight = scheme_dict["se_weights"][3]


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


func _on_TouchSettings_settings_changed() -> void:
	_refresh_settings()


func _on_resized() -> void:
	_refresh_button_positions()
