class_name FrameInput
extends Node
"""
Tracks the state of an input action over time.

Also provides support for buffered inputs. The buffer duration is dictated by the child timer.
"""

# The action to track
export (String) var action: String

# An action which negates this one if pressed. For example if the player holds 'ui_left' and presses 'ui_right',
# 'ui_left' no longer gets triggered.
export (String) var cancel_action: String

var _just_pressed: bool
var _pressed: bool

var frames: int
var _buffer: bool

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(action, false):
		_just_pressed = true
		_pressed = true
	elif event.is_action_released(action):
		_pressed = false
	
	if cancel_action and event.is_action_pressed(cancel_action, false):
		_just_pressed = false
		_pressed = false


func _physics_process(_delta: float) -> void:
	frames = frames + 1 if _pressed else 0
	
	if _buffer and _just_pressed:
		$Buffer.start()
	
	_just_pressed = false


func is_pressed() -> bool:
	return _pressed or _just_pressed


func is_just_pressed() -> bool:
	return _just_pressed


"""
Records any inputs to a buffer to be replayed later.
"""
func buffer_input() -> void:
	_buffer = true


"""
Replays any inputs which were pressed while buffering.
"""
func pop_buffered_input() -> void:
	_buffer = false
	if not $Buffer.is_stopped():
		_just_pressed = true
		$Buffer.stop()


"""
Marks the 'just pressed' event as handled, to avoid a buffered input from triggering two events.
"""
func set_input_as_handled() -> void:
	_just_pressed = false


"""
Returns true if the player held the input long enough to trigger DAS.
"""
func is_das_active() -> bool:
	return _pressed and frames >= PieceSpeeds.current_speed.delayed_auto_shift_delay
