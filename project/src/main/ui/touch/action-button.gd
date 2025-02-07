class_name ActionButton
extends TextureRect
## Touchscreen button used with EightWay.
##
## Note: Intuitively this functionality should be implemented as a TouchscreenButton. However this is challenging
## because of several unique and exciting decisions regarding the design of TouchscreenButton, as well as some
## bugs and limitations in its current implementation.
##
## 1. The absence of Godot #18654 (https://github.com/godotengine/godot/issues/18654) prevents setters from being
## overridden. This makes it difficult to change the button's icon when its action changes.
##
## 2. Most buttons and UI elements are controls, but because of Godot #171
## (https://github.com/godotengine/godot/issues/171) TouchscreenButton does not behave like a control. There are
## workarounds for this, but in the end it is easier to embed touchscreen functionality within a control node, rather
## than to force a Node2D to behave like a control.
##
## 3. TouchscreenButton does not have a way to set its state as pressed/unpressed. This makes it impossible to have
## business logic pulled out into a controller class such as EightWay.
##
## 4. Godot #36963 (https://github.com/godotengine/godot/issues/39693) prevents TouchscreenButton from accepting input
## outside of its boundaries. This makes it difficult to arrange TouchscreenButtons with overlapping collision shapes
## for diagonal presses.

signal pressed

## default textures to use when our action has no icon
const EMPTY_TEXTURE := preload("res://assets/main/ui/touch/empty.png")
const EMPTY_PRESSED_TEXTURE := preload("res://assets/main/ui/touch/empty-pressed.png")

const NORMAL_TEXTURES := {
	"ui_up": preload("res://assets/main/ui/touch/move-up.png"),
	"ui_down": preload("res://assets/main/ui/touch/move-down.png"),
	"ui_left": preload("res://assets/main/ui/touch/move-left.png"),
	"ui_right": preload("res://assets/main/ui/touch/move-right.png"),

	"move_piece_left": preload("res://assets/main/ui/touch/move-left.png"),
	"move_piece_right": preload("res://assets/main/ui/touch/move-right.png"),
	"hard_drop": preload("res://assets/main/ui/touch/move-up.png"),
	"soft_drop": preload("res://assets/main/ui/touch/move-down.png"),
	"swap_hold_piece": preload("res://assets/main/ui/touch/duck.png"),
	"rotate_cw": preload("res://assets/main/ui/touch/rotate-cw.png"),
	"rotate_ccw": preload("res://assets/main/ui/touch/rotate-ccw.png"),

	"ui_menu": preload("res://assets/main/ui/touch/menu.png"),
}

const PRESSED_TEXTURES := {
	"move_piece_left": preload("res://assets/main/ui/touch/move-left-pressed.png"),
	"move_piece_right": preload("res://assets/main/ui/touch/move-right-pressed.png"),
	"hard_drop": preload("res://assets/main/ui/touch/move-up-pressed.png"),
	"soft_drop": preload("res://assets/main/ui/touch/move-down-pressed.png"),
	"swap_hold_piece": preload("res://assets/main/ui/touch/duck-pressed.png"),
	"rotate_cw": preload("res://assets/main/ui/touch/rotate-cw-pressed.png"),
	"rotate_ccw": preload("res://assets/main/ui/touch/rotate-ccw-pressed.png"),

	"ui_menu": preload("res://assets/main/ui/touch/menu-pressed.png"),
}

## action activated by this button. also affects its appearance
export (String) var action: String setget set_action

## if false, pressing the button won't emit any actions.
export (bool) var emit_actions: bool = true

var pressed := false setget set_pressed

## current textures this button toggles between when pressed/unpressed
var _normal_texture: Texture
var _pressed_texture: Texture

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
	_normal_texture = NORMAL_TEXTURES.get(action, EMPTY_TEXTURE)
	_pressed_texture = PRESSED_TEXTURES.get(action, EMPTY_PRESSED_TEXTURE)
	texture = _pressed_texture if pressed else _normal_texture
	visible = true if action else false
