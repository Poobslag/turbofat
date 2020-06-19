class_name TouchControlButton
extends TouchScreenButton
"""
A touchscreen button the player uses to control the game.
"""

var _empty_texture := preload("res://assets/main/ui/touch/empty.png")
var _empty_pressed_texture := preload("res://assets/main/ui/touch/empty-pressed.png")

var _normal_textures := {
	"move_up": preload("res://assets/main/ui/touch/move-up.png"),
	"move_down": preload("res://assets/main/ui/touch/move-down.png"),
	"ui_left": preload("res://assets/main/ui/touch/move-left.png"),
	"ui_right": preload("res://assets/main/ui/touch/move-right.png"),
	
	"hard_drop": preload("res://assets/main/ui/touch/move-up.png"),
	"soft_drop": preload("res://assets/main/ui/touch/move-down.png"),
	"rotate_cw": preload("res://assets/main/ui/touch/rotate-cw.png"),
	"rotate_ccw": preload("res://assets/main/ui/touch/rotate-ccw.png"),
}

var _pressed_textures := {
	"move_up": preload("res://assets/main/ui/touch/move-up-pressed.png"),
	"move_down": preload("res://assets/main/ui/touch/move-down-pressed.png"),
	"ui_left": preload("res://assets/main/ui/touch/move-left-pressed.png"),
	"ui_right": preload("res://assets/main/ui/touch/move-right-pressed.png"),
	
	"hard_drop": preload("res://assets/main/ui/touch/move-up-pressed.png"),
	"soft_drop": preload("res://assets/main/ui/touch/move-down-pressed.png"),
	"rotate_cw": preload("res://assets/main/ui/touch/rotate-cw-pressed.png"),
	"rotate_ccw": preload("res://assets/main/ui/touch/rotate-ccw-pressed.png"),
}

"""
Updates the texture based on the button's assigned action.
"""
func refresh() -> void:
	normal = _normal_textures.get(action, _empty_texture)
	pressed = _pressed_textures.get(action, _empty_pressed_texture)
