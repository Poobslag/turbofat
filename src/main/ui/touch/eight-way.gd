extends Control
"""
Manages four touchscreen buttons in a plus shape which behave like a directional pad.

The player can press each button individually to emit different actions. If diagonal weights are specified, the player
can press two diagonally adjacent buttons with a single touch.
"""

# radius from the eightway's center where touches should be processed. significantly larger than its visual radius
const RADIUS = 180

# actions associated with each cardinal direction. if omitted, the button will not be shown
export (String) var _up_action: String
export (String) var _down_action: String
export (String) var _left_action: String
export (String) var _right_action: String

# these values influence how easy it is to press two buttons at once
# 0.0 = impossible; 1.0 = as easy as pressing a single button
export (float, 0, 1) var _up_right_weight := 0.0
export (float, 0, 1) var _up_left_weight := 0.0
export (float, 0, 1) var _down_right_weight := 0.0
export (float, 0, 1) var _down_left_weight := 0.0

# the position relative to our center of the most recent touch event
var _touch_dir: Vector2

# the index of the most recent touch event
var _touch_index := -1

onready var _up := $HBoxContainer/VBoxContainer/Up
onready var _down := $HBoxContainer/VBoxContainer/Down
onready var _left := $VBoxContainer/HBoxContainer/Left
onready var _right := $VBoxContainer/HBoxContainer/Right
onready var _buttons := [_up, _down, _left, _right]

func _ready() -> void:
	_up.action = _up_action
	_down.action = _down_action
	_left.action = _left_action
	_right.action = _right_action


"""
Converts drag/touch events into button presses.
"""
func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.pressed):
		var center := rect_position + rect_size * rect_scale / 2
		_touch_dir = (event.position as Vector2 - center) / rect_scale
		if _touch_dir.length() < RADIUS:
			get_tree().set_input_as_handled()
			_touch_index = event.index
			_press_buttons(event)
		elif event.index == _touch_index:
			get_tree().set_input_as_handled()
			_touch_index = -1
			_release_buttons()
	elif event is InputEventScreenTouch and not event.pressed:
		if event.index == _touch_index:
			get_tree().set_input_as_handled()
			_touch_index = -1
			_release_buttons()


"""
Becomes visible and receives touch input.
"""
func show() -> void:
	visible = true


"""
Becomes invisible. Releases any held buttons and ignores touch input.
"""
func hide() -> void:
	visible = false
	_touch_index = -1
	_release_buttons()


"""
Release all buttons currently pressed.

This also emits InputEvents for any action buttons released.
"""
func _release_buttons() -> void:
	for button in _buttons:
		button.pressed = false


"""
Press the buttons associated with the specified touch event.

This also emits InputEvents for any action buttons pressed or released.
"""
func _press_buttons(event: InputEvent) -> void:
	# cardinal direction; 0 = right, 1 = down, 2 = left, 3 = right
	var touch_cardinal_dir := wrapi(round(2 * _touch_dir.angle() / PI), 0, 4)
	
	var up_right_pressed := _diagonalness(_touch_dir, Vector2(1.0, -1.0)) < _up_right_weight
	var up_left_pressed := _diagonalness(_touch_dir, Vector2(-1.0, -1.0)) < _up_left_weight
	var down_right_pressed := _diagonalness(_touch_dir, Vector2(1.0, 1.0)) < _down_right_weight
	var down_left_pressed := _diagonalness(_touch_dir, Vector2(-1.0, 1.0)) < _down_left_weight
	
	_right.pressed = touch_cardinal_dir == 0 or up_right_pressed or down_right_pressed
	_down.pressed = touch_cardinal_dir == 1 or down_right_pressed or down_left_pressed
	_left.pressed = touch_cardinal_dir == 2 or up_left_pressed or down_left_pressed
	_up.pressed = touch_cardinal_dir == 3 or up_left_pressed or up_right_pressed


"""
Returns a number [0.0, 4.0] for how close the touch is to the specified diagonal.

0.0 = very close, 4.0 = very far. A value less than 1.0 indicates the touch is in the same correct quadrant as the
diagonal.
"""
func _diagonalness(_touch_dir: Vector2, diagonal_direction: Vector2) -> float:
	return abs(8 * _touch_dir.angle_to(diagonal_direction) / PI)
