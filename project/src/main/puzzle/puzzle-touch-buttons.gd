extends Control
## Manages the touchscreen buttons for puzzle mode.

const CLOSE := preload("res://assets/main/ui/touch/menu.png")
const CLOSE_PRESSED := preload("res://assets/main/ui/touch/menu-pressed.png")

## when the player is testing buttons, we replace the icon so we don't confuse players trying to quit
## (although... there's an argument that replacing the close button with a duck might confuse them more...)
const DUCK := preload("res://assets/main/ui/touch/duck.png")
const DUCK_PRESSED := preload("res://assets/main/ui/touch/duck-pressed.png")

## touchscreen control schemes the player can select in the settings menu
const SCHEMES := {
	TouchSettings.EASY_CONSOLE: {
		"sw_actions": ["hard_drop", "soft_drop", "move_piece_left", "move_piece_right"],
		"sw_weights": [1, 1, 1, 1],
		"se_actions": ["", "rotate_ccw", "", "rotate_cw"],
		"se_weights": [0, 0, 0, 1],
		"se_hold": true,
	},
	TouchSettings.EASY_DESKTOP: {
		"sw_actions": ["", "rotate_cw", "rotate_ccw", ""],
		"sw_weights": [0, 0, 1, 0],
		"se_actions": ["hard_drop", "soft_drop", "move_piece_left", "move_piece_right"],
		"se_weights": [1, 1, 1, 1],
		"sw_hold": true,
	},
	TouchSettings.AMBI_CONSOLE: {
		"sw_actions": ["hard_drop", "soft_drop", "move_piece_left", "move_piece_right"],
		"sw_weights": [1, 1, 1, 1],
		"se_actions": ["hard_drop", "rotate_ccw", "soft_drop", "rotate_cw"],
		"se_weights": [1, 0, 0, 1],
		"se_hold": true,
	},
	TouchSettings.AMBI_DESKTOP: {
		"sw_actions": ["hard_drop", "rotate_cw", "rotate_ccw", "soft_drop"],
		"sw_weights": [0, 1, 1, 0],
		"se_actions": ["hard_drop", "soft_drop", "move_piece_left", "move_piece_right"],
		"se_weights": [1, 1, 1, 1],
		"sw_hold": true,
	},
	TouchSettings.LOCO_CONSOLE: {
		"sw_actions": ["soft_drop", "move_piece_right", "move_piece_left", "hard_drop"],
		"sw_weights": [0, 1, 0, 0],
		"se_actions": ["hard_drop", "rotate_ccw", "soft_drop", "rotate_cw"],
		"se_weights": [1, 0, 0, 1],
		"se_hold": true,
	},
	TouchSettings.LOCO_DESKTOP: {
		"sw_actions": ["soft_drop", "rotate_cw", "rotate_ccw", "hard_drop"],
		"sw_weights": [0, 1, 1, 0],
		"se_actions": ["hard_drop", "move_piece_left", "soft_drop", "move_piece_right"],
		"se_weights": [1, 0, 0, 0],
		"sw_hold": true,
	},
}

## if false, pressing the buttons won't emit any actions.
export (bool) var emit_actions := true setget set_emit_actions

onready var _menu_button := $MenuButtonHolder/MenuButton

func _ready() -> void:
	if OS.has_touchscreen_ui_hint():
		SystemData.touch_settings.connect("settings_changed", self, "_on_TouchSettings_settings_changed")
		_refresh_emit_actions()
		_refresh_settings()
		show()
	else:
		hide()
	_menu_button.connect("pressed", self, "_on_MenuButton_pressed")


func set_emit_actions(new_emit_actions: bool) -> void:
	emit_actions = new_emit_actions
	_refresh_emit_actions()


## Refreshes the buttons based on the emit_actions property.
##
## Propogates the setting to the EightWay child objects.
func _refresh_emit_actions() -> void:
	if not is_inside_tree():
		return
	
	$ButtonsSw.emit_actions = emit_actions
	$ButtonsSe.emit_actions = emit_actions
	if emit_actions:
		_menu_button.action = "ui_menu"
		_menu_button.normal = CLOSE
		_menu_button.pressed = CLOSE_PRESSED
	else:
		# when the player is testing buttons, we replace the icon so we don't confuse users trying who are trying
		# to quit. (there's an argument that replacing the close button with a duck might confuse them more...)
		_menu_button.action = ""
		_menu_button.normal = DUCK
		_menu_button.pressed = DUCK_PRESSED


## Updates the buttons based on the player's settings.
##
## This updates their location and size.
func _refresh_button_positions() -> void:
	$ButtonsSw.rect_scale = Vector2.ONE * SystemData.touch_settings.size
	$ButtonsSw.rect_position.y = rect_size.y - 10 - $ButtonsSw.rect_size.y * $ButtonsSw.rect_scale.y
	
	$ButtonsSe.rect_scale = Vector2.ONE * SystemData.touch_settings.size
	$ButtonsSe.rect_position.x = rect_size.x - 10 - $ButtonsSw.rect_size.x * $ButtonsSw.rect_scale.x
	$ButtonsSe.rect_position.y = rect_size.y - 10 - $ButtonsSw.rect_size.y * $ButtonsSw.rect_scale.y
	
	_menu_button.scale = Vector2(0.375, 0.375) * SystemData.touch_settings.size
	$MenuButtonHolder.rect_position.x = rect_size.x - 20 - _menu_button.pressed.get_size().x * _menu_button.scale.x


## Updates the buttons based on the player's settings.
##
## This updates their location, size, how they're arranged and their sensitivity.
func _refresh_settings() -> void:
	# update scale/position
	_refresh_button_positions()
	
	# update actions
	var scheme_dict: Dictionary = SCHEMES.get(SystemData.touch_settings.scheme, TouchSettings.EASY_CONSOLE)
	$ButtonsSw.up_action = scheme_dict["sw_actions"][0]
	$ButtonsSw.down_action = scheme_dict["sw_actions"][1]
	$ButtonsSw.left_action = scheme_dict["sw_actions"][2]
	$ButtonsSw.right_action = scheme_dict["sw_actions"][3]
	$ButtonsSw/HoldHolder.visible = scheme_dict.get("sw_hold", false) and CurrentLevel.is_hold_piece_cheat_enabled()
	$ButtonsSe.up_action = scheme_dict["se_actions"][0]
	$ButtonsSe.down_action = scheme_dict["se_actions"][1]
	$ButtonsSe.left_action = scheme_dict["se_actions"][2]
	$ButtonsSe.right_action = scheme_dict["se_actions"][3]
	$ButtonsSe/HoldHolder.visible = scheme_dict.get("se_hold", false) and CurrentLevel.is_hold_piece_cheat_enabled()
	
	# update diagonal sensitivity
	$ButtonsSw.up_left_weight = scheme_dict["sw_weights"][0] * SystemData.touch_settings.fat_finger
	$ButtonsSw.up_right_weight = scheme_dict["sw_weights"][1] * SystemData.touch_settings.fat_finger
	$ButtonsSw.down_left_weight = scheme_dict["sw_weights"][2] * SystemData.touch_settings.fat_finger
	$ButtonsSw.down_right_weight = scheme_dict["sw_weights"][3] * SystemData.touch_settings.fat_finger
	$ButtonsSe.up_left_weight = scheme_dict["se_weights"][0] * SystemData.touch_settings.fat_finger
	$ButtonsSe.up_right_weight = scheme_dict["se_weights"][1] * SystemData.touch_settings.fat_finger
	$ButtonsSe.down_left_weight = scheme_dict["se_weights"][2] * SystemData.touch_settings.fat_finger
	$ButtonsSe.down_right_weight = scheme_dict["se_weights"][3] * SystemData.touch_settings.fat_finger


func _on_TouchSettings_settings_changed() -> void:
	_refresh_settings()


## Plays sounds when testing out controls in the 'settings' menu.
func _on_MenuButton_pressed() -> void:
	if not emit_actions:
		$DuckSound.play()


## Plays sounds when testing out controls in the 'settings' menu.
func _on_EightWay_pressed() -> void:
	if not emit_actions:
		$ButtonSound.play()


func _on_Menu_show() -> void:
	hide()


func _on_Menu_hide() -> void:
	if OS.has_touchscreen_ui_hint():
		show()
