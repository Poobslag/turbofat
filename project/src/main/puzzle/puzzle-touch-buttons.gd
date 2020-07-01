extends Control
"""
Manages the touchscreen buttons for puzzle mode.
"""

# touchscreen control schemes the player can select in the settings menu
const SCHEMES := {
	TouchSettings.EASY_CONSOLE: {
		"sw_actions": ["hard_drop", "soft_drop", "ui_left", "ui_right"],
		"sw_weights": [1, 1, 1, 1],
		"se_actions": ["", "rotate_ccw", "", "rotate_cw"],
		"se_weights": [0, 0, 0, 1],
	},
	TouchSettings.EASY_DESKTOP: {
		"sw_actions": ["", "rotate_cw", "rotate_ccw", ""],
		"sw_weights": [0, 0, 1, 0],
		"se_actions": ["hard_drop", "soft_drop", "ui_left", "ui_right"],
		"se_weights": [1, 1, 1, 1],
	},
	TouchSettings.AMBI_CONSOLE: {
		"sw_actions": ["hard_drop", "soft_drop", "ui_left", "ui_right"],
		"sw_weights": [1, 1, 1, 1],
		"se_actions": ["hard_drop", "rotate_ccw", "soft_drop", "rotate_cw"],
		"se_weights": [1, 0, 0, 1],
	},
	TouchSettings.AMBI_DESKTOP: {
		"sw_actions": ["hard_drop", "rotate_cw", "rotate_ccw", "soft_drop"],
		"sw_weights": [0, 1, 1, 0],
		"se_actions": ["hard_drop", "soft_drop", "ui_left", "ui_right"],
		"se_weights": [1, 1, 1, 1],
	},
	TouchSettings.LOCO_CONSOLE: {
		"sw_actions": ["soft_drop", "ui_right", "ui_left", "hard_drop"],
		"sw_weights": [0, 1, 0, 0],
		"se_actions": ["hard_drop", "rotate_ccw", "soft_drop", "rotate_cw"],
		"se_weights": [1, 0, 0, 1],
	},
	TouchSettings.LOCO_DESKTOP: {
		"sw_actions": ["soft_drop", "rotate_cw", "rotate_ccw", "hard_drop"],
		"sw_weights": [0, 1, 1, 0],
		"se_actions": ["hard_drop", "ui_left", "soft_drop", "ui_right"],
		"se_weights": [1, 0, 0, 0],
	},
}

# if false, pressing the buttons won't emit any actions.
export (bool) var emit_actions := true setget set_emit_actions

onready var _close := preload("res://assets/main/ui/touch/close.png")
onready var _close_pressed := preload("res://assets/main/ui/touch/close-pressed.png")

# when the player is testing buttons, we replace the icon so we don't confuse users trying who are trying to quit
# (although... there's an argument that replacing the close button with a duck might confuse them more...)
onready var _duck := preload("res://assets/main/ui/touch/duck.png")
onready var _duck_pressed := preload("res://assets/main/ui/touch/duck-pressed.png")

func _ready() -> void:
	if OS.has_touchscreen_ui_hint():
		PlayerData.touch_settings.connect("settings_changed", self, "_on_TouchSettings_settings_changed")
		_refresh_emit_actions()
		_refresh_settings()
		show()
	else:
		hide()


func set_emit_actions(new_emit_actions: bool) -> void:
	emit_actions = new_emit_actions
	_refresh_emit_actions()


"""
Refreshes the buttons based on the emit_actions property.

Propogates the setting to the EightWay child objects.
"""
func _refresh_emit_actions() -> void:
	if is_inside_tree():
		$ButtonsSw.emit_actions = emit_actions
		$ButtonsSe.emit_actions = emit_actions
		if emit_actions:
			$MenuButton.action = "ui_menu"
			$MenuButton.normal = _close
			$MenuButton.pressed = _close_pressed
		else:
			# when the player is testing buttons, we replace the icon so we don't confuse users trying who are trying
			# to quit. (there's an argument that replacing the close button with a duck might confuse them more...)
			$MenuButton.action = ""
			$MenuButton.normal = _duck
			$MenuButton.pressed = _duck_pressed


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
	
	$MenuButton.scale = Vector2(0.375, 0.375) * PlayerData.touch_settings.size
	$MenuButton.position.x = 1024 - 10 - $MenuButton.pressed.get_size().x * $MenuButton.scale.x


"""
Updates the buttons based on the player's settings.

This updates their location, size, how they're arranged and their sensitivity.
"""
func _refresh_settings() -> void:
	# update scale/position
	_refresh_button_positions()
	
	# update actions
	var scheme_dict: Dictionary = SCHEMES.get(PlayerData.touch_settings.scheme, TouchSettings.EASY_CONSOLE)
	$ButtonsSw.up_action = scheme_dict["sw_actions"][0]
	$ButtonsSw.down_action = scheme_dict["sw_actions"][1]
	$ButtonsSw.left_action = scheme_dict["sw_actions"][2]
	$ButtonsSw.right_action = scheme_dict["sw_actions"][3]
	$ButtonsSe.up_action = scheme_dict["se_actions"][0]
	$ButtonsSe.down_action = scheme_dict["se_actions"][1]
	$ButtonsSe.left_action = scheme_dict["se_actions"][2]
	$ButtonsSe.right_action = scheme_dict["se_actions"][3]
	
	# update diagonal sensitivity
	$ButtonsSw.up_left_weight = scheme_dict["sw_weights"][0] * PlayerData.touch_settings.fat_finger
	$ButtonsSw.up_right_weight = scheme_dict["sw_weights"][1] * PlayerData.touch_settings.fat_finger
	$ButtonsSw.down_left_weight = scheme_dict["sw_weights"][2] * PlayerData.touch_settings.fat_finger
	$ButtonsSw.down_right_weight = scheme_dict["sw_weights"][3] * PlayerData.touch_settings.fat_finger
	$ButtonsSe.up_left_weight = scheme_dict["se_weights"][0] * PlayerData.touch_settings.fat_finger
	$ButtonsSe.up_right_weight = scheme_dict["se_weights"][1] * PlayerData.touch_settings.fat_finger
	$ButtonsSe.down_left_weight = scheme_dict["se_weights"][2] * PlayerData.touch_settings.fat_finger
	$ButtonsSe.down_right_weight = scheme_dict["se_weights"][3] * PlayerData.touch_settings.fat_finger


func _on_TouchSettings_settings_changed() -> void:
	_refresh_settings()
