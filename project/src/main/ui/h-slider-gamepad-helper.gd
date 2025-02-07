extends Node
## Improves gamepad support for HSliders.
##
## In Godot 3.x, while holding a key continuously advances a slider, holding a D-Pad direction on the gamepad does
## not. This script extends the functionality of HSlider to support continuous movement holding a D-Pad direction.

## Pressing and holding the gamepad for this duration will continuously advance the slider.
const ECHO_DURATION := 0.30

## Speed at which the slider moves when the gamepad is held.
##
## For our game's sliders, the speed is half the approximate length of the slider. So for example, our HSV sliders
## have a length of 256, and their speed is 128.
export (float) var sliding_speed: float = 2.0

## Direction of slider movement (1.0 = right, -1.0 = left, 0.0 = no movement)
var _sliding_dir := 0.0

## Current value of the slider stored as a float.
##
## When making incremental changes to the slider value, we cannot modify the slider's value directly because it's
## possible for its value to be snapped to its step value and never advance.
var _slider_value_float: float

onready var _slider: HSlider = get_parent()

## Timer which monitors whether a D-Pad input was recently pressed.
onready var _delay_timer: Timer

func _ready() -> void:
	_slider.connect("focus_exited", self, "_on_HSlider_focus_exited")
	_initialize_delay_timer()
	set_process(false)


func _input(event: InputEvent) -> void:
	if not _slider.editable or not _slider.has_focus():
		return
	
	if event is InputEventJoypadButton:
		_handle_dpad(event)


func _process(delta: float) -> void:
	# update the slider value based on the direction and speed
	_slider_value_float += _sliding_dir * sliding_speed * delta
	_slider.value = _slider_value_float


## Updates our sliding direction and state based on a D-Pad input event.
func _handle_dpad(event: InputEventJoypadButton) -> void:
	if event.is_action_released("ui_left") and _sliding_dir < 0.0:
		_stop_sliding()
	if event.is_action_released("ui_right") and _sliding_dir > 0.0:
		_stop_sliding()
	
	if event.is_action_pressed("ui_left"):
		# slide left after a delay
		_sliding_dir = -1.0
		_delay_timer.start(ECHO_DURATION)
	if event.is_action_pressed("ui_right"):
		# slide right after a delay
		_sliding_dir = 1.0
		_delay_timer.start(ECHO_DURATION)


func _initialize_delay_timer() -> void:
	_delay_timer = Timer.new()
	_delay_timer.connect("timeout", self, "_on_DelayTimer_timeout")
	_delay_timer.one_shot = true
	add_child(_delay_timer)


func _stop_sliding() -> void:
	_delay_timer.stop()
	_sliding_dir = 0.0
	set_process(false)


## When the delay timer times out, we update our stored value and start sliding.
func _on_DelayTimer_timeout() -> void:
	set_process(true)
	_slider_value_float = _slider.value


func _on_HSlider_focus_exited() -> void:
	_stop_sliding()
