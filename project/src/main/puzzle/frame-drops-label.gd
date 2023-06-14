extends Label
## Renders to screen debug information about dropped frames or dropped physics steps.
##
## A 'dropped frame' occurs when the _process() function isn't called 60 times per second. This coincides with a visual
## hiccup in the game where the graphics don't update for a few frames.
##
## A 'dropped physics step' occurs when the _physics_process() function isn't called 60 times per second. This
## coincides in a gameplay hiccup where the game ignores the player's input for a few frames.

## expected seconds per frame; 0.01667 if physics_fps is set to 60 FPS
var _seconds_per_frame: float

## expected system clock for the previous _physics_process() call
var _expected_physics_msec := 0.0
## actual system clock for the previous _physics_process() call
var _actual_physics_msec := 0.0
## increments when the system clock falls behind the expected value
var _physics_step_drops := 0

## expected system clock for the previous _process() call
var _expected_visual_msec := 0.0
## actual system clock for the previous _process() call
var _actual_visual_msec := 0.0
## increments when the system clock falls behind the expected value
var _visual_frame_drops := 0

func _ready() -> void:
	var physics_fps: int = ProjectSettings.get_setting("physics/common/physics_fps")
	_seconds_per_frame = 1.0 / physics_fps
	
	_reset()
	_refresh_text()


func _process(_delta: float) -> void:
	_expected_visual_msec += _seconds_per_frame * 1000
	_actual_visual_msec = Time.get_ticks_msec()
	
	var disparity := (_actual_visual_msec - _expected_visual_msec) / 1000.0
	if disparity > _seconds_per_frame:
		var newly_dropped_frames: int = floor(disparity / _seconds_per_frame)
		_visual_frame_drops += newly_dropped_frames
		_expected_visual_msec += _seconds_per_frame * newly_dropped_frames * 1000
		_refresh_text()


func _physics_process(_delta: float) -> void:
	_expected_physics_msec += _seconds_per_frame * 1000
	_actual_physics_msec = Time.get_ticks_msec()
	
	var disparity := (_actual_physics_msec - _expected_physics_msec) / 1000.0
	if disparity > _seconds_per_frame:
		var newly_dropped_frames: int = floor(disparity / _seconds_per_frame)
		_physics_step_drops += newly_dropped_frames
		_expected_physics_msec += _seconds_per_frame * newly_dropped_frames * 1000
		_refresh_text()


func _refresh_text() -> void:
	var new_text := ""
	new_text += (tr("%s frame drops") % [_visual_frame_drops]) + "\n"
	new_text += tr("%s step drops") % [_physics_step_drops]
	text = new_text


func _reset() -> void:
	var system_time_msec := Time.get_ticks_msec()
	
	_expected_physics_msec = system_time_msec
	_actual_physics_msec = system_time_msec
	_physics_step_drops = 0
	
	_expected_visual_msec = system_time_msec
	_actual_visual_msec = system_time_msec
	_visual_frame_drops = 0
	
	# disable processing if invisible
	set_process(visible)
	set_physics_process(visible)


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "bigfps":
		# show/hide frames per second
		visible = not visible
		_reset()
		if visible:
			_refresh_text()
		detector.play_cheat_sound(visible)
