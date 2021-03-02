class_name FrameInput
extends Node
"""
Tracks the state of an input action over time.

Also provides support for buffered inputs. The buffer duration is dictated by the child timer.
"""

# The action to track
export (String) var action: String

# An action which negates this one if pressed. For example if the player holds move_piece_left and presses
# move_piece_right, move_piece_left no longer gets triggered.
export (String) var cancel_action: String

var pressed_frames: int

var _just_pressed: bool
var _pressed: bool
var _buffer: bool

# If 'true' the inputs will be printed to the console. These printed inputs can be converted into an input replay.
var _print_inputs := false

func _unhandled_input(event: InputEvent) -> void:
	if not CurrentLevel.settings.input_replay.empty():
		# don't process button presses when replaying prerecorded input
		return
	
	if event.is_action_pressed(action):
		if _print_inputs: print("\"%s +%s\"," % [PuzzleScore.input_frame, action])
		_just_pressed = true
		_pressed = true
	elif event.is_action_released(action):
		if _print_inputs: print("\"%s -%s\"," % [PuzzleScore.input_frame, action])
		_pressed = false
	
	if cancel_action:
		if event.is_action_pressed(cancel_action):
			_just_pressed = false
			_pressed = false
		elif event.is_action_released(cancel_action):
			if Input.is_action_pressed(action) and not _pressed:
				# player was holding both buttons, but let go of the cancel_button
				_just_pressed = true
				_pressed = true


func _physics_process(_delta: float) -> void:
	pressed_frames = pressed_frames + 1 if _pressed else 0
	
	if _buffer and _just_pressed:
		$Buffer.start()
	
	_just_pressed = false
	
	# process the input replay last; this way just_pressed remains true for a frame
	if not CurrentLevel.settings.input_replay.empty():
		_process_input_replay()


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
	return _pressed and pressed_frames >= PieceSpeeds.current_speed.delayed_auto_shift_delay


"""
Applies prerecorded puzzle inputs for things such as tutorials.
"""
func _process_input_replay() -> void:
	if CurrentLevel.settings.input_replay.is_action_pressed(action):
		if _print_inputs: print("\"%s +%s\"," % [PuzzleScore.input_frame, action])
		_just_pressed = true
		_pressed = true
	elif CurrentLevel.settings.input_replay.is_action_released(action):
		if _print_inputs: print("\"%s -%s\"," % [PuzzleScore.input_frame, action])
		_pressed = false
	
	if cancel_action:
		if CurrentLevel.settings.input_replay.is_action_pressed(cancel_action):
			_just_pressed = false
			_pressed = false
		elif CurrentLevel.settings.input_replay.is_action_released(cancel_action):
			if CurrentLevel.settings.input_replay.is_action_held(action) and not _pressed:
				# player was holding both buttons, but let go of the cancel_button
				_just_pressed = true
				_pressed = true
