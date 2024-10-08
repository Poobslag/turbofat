extends Node
## Hides the mouse cursor when joypad or keyboard input is detected.

signal input_mode_changed

## The input method the player is using to play the game; keyboard or joypad
enum InputMode {
	KEYBOARD_MOUSE,
	JOYPAD,
}

const KEYBOARD_MOUSE := InputMode.KEYBOARD_MOUSE
const JOYPAD := InputMode.JOYPAD

## The input method the player is using to play the game; keyboard or joypad
##
## This is automatically updated as the player presses keys or joypad buttons.
var input_mode: int = InputMode.KEYBOARD_MOUSE setget set_input_mode

func _ready() -> void:
	# allow the mouse to show/hide when gameplay is paused
	pause_mode = Node.PAUSE_MODE_PROCESS


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventKey:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif event is InputEventJoypadButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if event is InputEventKey:
		set_input_mode(KEYBOARD_MOUSE)
	elif event is InputEventJoypadButton:
		set_input_mode(JOYPAD)


func set_input_mode(new_input_mode: int) -> void:
	if input_mode == new_input_mode:
		return
	
	input_mode = new_input_mode
	emit_signal("input_mode_changed")
