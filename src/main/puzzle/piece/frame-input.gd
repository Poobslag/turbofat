class_name FrameInput
extends Node
"""
Tracks the state of an input action over time.
"""

# The action to track
export (String) var action: String

# An action which negates this one if pressed. For example if the player holds 'ui_left' and presses 'ui_right',
# 'ui_left' no longer gets triggered.
export (String) var cancel_action: String

var just_pressed: bool
var pressed: bool
var frames: int

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(action, false):
		just_pressed = true
		pressed = true
	elif event.is_action_released(action):
		pressed = false
		frames = 0
	
	if cancel_action and event.is_action_pressed(cancel_action, false):
		just_pressed = false
		pressed = false
		frames = 0


func _physics_process(_delta: float) -> void:
	if pressed:
		frames += 1
	just_pressed = false


"""
Returns true if the player held the input long enough to trigger DAS.
"""
func is_das_active() -> bool:
	return frames >= PieceSpeeds.current_speed.delayed_auto_shift_delay
