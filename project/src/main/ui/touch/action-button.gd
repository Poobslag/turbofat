class_name ActionButton
extends TextureRect
## A touchscreen button used with EightWay.
##
## Note: Intuitively this functionality should be implemented as a TouchscreenButton. However this is challenging
## because of several unique and exciting decisions regarding the design of TouchscreenButton, as well as some
## bugs and limitations in its current implementation.
##
## 1. https://github.com/godotengine/godot/issues/18654 The absence of Godot #18654 prevents setters from being
## overridden. This makes it difficult to change the button's icon when its action changes.
##
## 2. https://github.com/godotengine/godot/issues/171 Most buttons and UI elements are controls, but TouchscreenButton
## does not behave like a control. There are workarounds for this, but in the end it is easier to embed touchscreen
## functionality within a control node, rather than to force a Node2D to behave like a control.
##
## 3. TouchscreenButton does not have a way to set its state as pressed/unpressed. This makes it impossible to have
## business logic pulled out into a controller class such as EightWay.
##
## 4. https://github.com/godotengine/godot/issues/39693 Godot #36963 prevents TouchscreenButton from accepting input
## outside of its boundaries. This makes it difficult to arrange TouchscreenButtons with overlapping collision shapes
## for diagonal presses.

signal pressed

## the action activated by this button. also affects its appearance
export (String) var action: String setget set_action

## if false, pressing the button won't emit any actions.
export (bool) var emit_actions: bool = true

var pressed := false setget set_pressed

## the current textures this button toggles between when pressed/unpressed
var _normal_texture: Texture
var _pressed_texture: Texture

## the default textures to use when our action has no icon
onready var _empty_texture := preload("res://assets/main/ui/touch/empty.png")
onready var _empty_pressed_texture := preload("res://assets/main/ui/touch/empty-pressed.png")

onready var _normal_textures := {
	"ui_up": preload("res://assets/main/ui/touch/move-up.png"),
	"ui_down": preload("res://assets/main/ui/touch/move-down.png"),
	"ui_left": preload("res://assets/main/ui/touch/move-left.png"),
	"ui_right": preload("res://assets/main/ui/touch/move-right.png"),

	"walk_up": preload("res://assets/main/ui/touch/move-up.png"),
	"walk_down": preload("res://assets/main/ui/touch/move-down.png"),
	"walk_left": preload("res://assets/main/ui/touch/move-left.png"),
	"walk_right": preload("res://assets/main/ui/touch/move-right.png"),

	"move_piece_left": preload("res://assets/main/ui/touch/move-left.png"),
	"move_piece_right": preload("res://assets/main/ui/touch/move-right.png"),
	"hard_drop": preload("res://assets/main/ui/touch/move-up.png"),
	"soft_drop": preload("res://assets/main/ui/touch/move-down.png"),
	"rotate_cw": preload("res://assets/main/ui/touch/rotate-cw.png"),
	"rotate_ccw": preload("res://assets/main/ui/touch/rotate-ccw.png"),

	"interact": preload("res://assets/main/ui/touch/interact.png"),
	"ui_menu": preload("res://assets/main/ui/touch/menu.png"),
}

onready var _pressed_textures := {
	"ui_up": preload("res://assets/main/ui/touch/move-up-pressed.png"),
	"ui_down": preload("res://assets/main/ui/touch/move-down-pressed.png"),
	"ui_left": preload("res://assets/main/ui/touch/move-left-pressed.png"),
	"ui_right": preload("res://assets/main/ui/touch/move-right-pressed.png"),

	"walk_up": preload("res://assets/main/ui/touch/move-up-pressed.png"),
	"walk_down": preload("res://assets/main/ui/touch/move-down-pressed.png"),
	"walk_left": preload("res://assets/main/ui/touch/move-left-pressed.png"),
	"walk_right": preload("res://assets/main/ui/touch/move-right-pressed.png"),

	"move_piece_left": preload("res://assets/main/ui/touch/move-left-pressed.png"),
	"move_piece_right": preload("res://assets/main/ui/touch/move-right-pressed.png"),
	"hard_drop": preload("res://assets/main/ui/touch/move-up-pressed.png"),
	"soft_drop": preload("res://assets/main/ui/touch/move-down-pressed.png"),
	"rotate_cw": preload("res://assets/main/ui/touch/rotate-cw-pressed.png"),
	"rotate_ccw": preload("res://assets/main/ui/touch/rotate-ccw-pressed.png"),

	"interact": preload("res://assets/main/ui/touch/interact-pressed.png"),
	"ui_menu": preload("res://assets/main/ui/touch/menu-pressed.png"),
}

func _ready() -> void:
	_refresh()


## Sets the action used for this button and updates its appearance.
func set_action(new_action: String) -> void:
	action = new_action
	_refresh()


## Emits a pressed/released InputEvent and updates the button's appearance.
func set_pressed(new_pressed: bool) -> void:
	if pressed == new_pressed:
		return
	
	pressed = new_pressed
	texture = _pressed_texture if pressed else _normal_texture
	
	if emit_actions:
		# fire the appropriate events
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = pressed
		Input.parse_input_event(ev)
	emit_signal("pressed")


## Updates the button's appearance based on its assigned action.
func _refresh() -> void:
	_normal_texture = _normal_textures.get(action, _empty_texture)
	_pressed_texture = _pressed_textures.get(action, _empty_pressed_texture)
	texture = _pressed_texture if pressed else _normal_texture
	visible = true if action else false
