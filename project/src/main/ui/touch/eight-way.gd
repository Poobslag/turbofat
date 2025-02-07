extends Control
## Manages four touchscreen buttons in a plus shape which behave like a directional pad.
##
## The player can press each button individually to emit different actions. If diagonal weights are specified, the
## player can press two diagonally adjacent buttons with a single touch.

signal pressed

## radius from the eightway's center where touches should be processed. significantly larger than its visual radius
const RADIUS := 180

## 'swap hold piece' button which is adjacent to this eight-way
export (NodePath) var hold_button_path: NodePath

## actions associated with each cardinal direction. if omitted, the button will not be shown
export (String) var up_action: String setget set_up_action
export (String) var down_action: String setget set_down_action
export (String) var left_action: String setget set_left_action
export (String) var right_action: String setget set_right_action

## these values influence how easy it is to press two buttons at once
## 0.0 = impossible; 1.0 = as easy as pressing a single button
export (float, 0, 1) var up_right_weight := 0.0
export (float, 0, 1) var up_left_weight := 0.0
export (float, 0, 1) var down_right_weight := 0.0
export (float, 0, 1) var down_left_weight := 0.0

## if false, pressing the buttons won't emit any actions.
export (bool) var emit_actions := true setget set_emit_actions

## position relative to our center of the most recent touch event
var _touch_dir: Vector2

## index of the most recent touch event
var _touch_index := -1

onready var _hold_button: TouchScreenButton = get_node(hold_button_path) if hold_button_path else null

onready var _up := $HBoxContainer/VBoxContainer/Up
onready var _down := $HBoxContainer/VBoxContainer/Down
onready var _left := $VBoxContainer/HBoxContainer/Left
onready var _right := $VBoxContainer/HBoxContainer/Right
onready var _buttons := [_up, _down, _left, _right]

func _ready() -> void:
	_refresh_up_action()
	_refresh_down_action()
	_refresh_left_action()
	_refresh_right_action()


## Converts drag/touch events into button presses.
func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if _hold_button and _hold_button.is_pressed():
		# the hold button takes precedence over our inputs
		return

	# Process the touch event, but don't mark it as handled. Other touch buttons might need to handle the same touch
	# event, such as when dragging a finger from one EightWay into another.
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.pressed):
		var center := rect_position + rect_size * rect_scale / 2
		_touch_dir = (event.position as Vector2 - center) / rect_scale
		if _touch_dir.length() < RADIUS:
			_touch_index = event.index
			_press_buttons()
		elif event.index == _touch_index:
			_touch_index = -1
			_release_buttons()
	elif event is InputEventScreenTouch and not event.pressed:
		if event.index == _touch_index:
			_touch_index = -1
			_release_buttons()


func set_emit_actions(new_emit_actions: bool) -> void:
	for button in _buttons:
		button.emit_actions = new_emit_actions


func set_up_action(new_up_action: String) -> void:
	up_action = new_up_action
	_refresh_up_action()


func set_down_action(new_down_action: String) -> void:
	down_action = new_down_action
	_refresh_down_action()


func set_left_action(new_left_action: String) -> void:
	left_action = new_left_action
	_refresh_left_action()


func set_right_action(new_right_action: String) -> void:
	right_action = new_right_action
	_refresh_right_action()


## Becomes visible and receives touch input.
func show() -> void:
	visible = true


## Becomes invisible. Releases any held buttons and ignores touch input.
func hide() -> void:
	visible = false
	_touch_index = -1
	_release_buttons()


func _refresh_up_action() -> void:
	if is_inside_tree():
		_up.action = up_action


func _refresh_down_action() -> void:
	if is_inside_tree():
		_down.action = down_action


func _refresh_left_action() -> void:
	if is_inside_tree():
		_left.action = left_action


func _refresh_right_action() -> void:
	if is_inside_tree():
		_right.action = right_action


## Release all buttons currently pressed.
##
## This also emits InputEvents for any action buttons released.
func _release_buttons() -> void:
	for button in _buttons:
		button.pressed = false


## Press the buttons associated with the newest touch event.
##
## This also emits InputEvents for any action buttons pressed or released.
func _press_buttons() -> void:
	# cardinal direction; 0 = right, 1 = down, 2 = left, 3 = right
	var touch_cardinal_dir := wrapi(round(2 * _touch_dir.angle() / PI), 0, 4)
	
	var up_right_pressed := _diagonalness(Vector2(1.0, -1.0)) < up_right_weight
	var up_left_pressed := _diagonalness(Vector2(-1.0, -1.0)) < up_left_weight
	var down_right_pressed := _diagonalness(Vector2(1.0, 1.0)) < down_right_weight
	var down_left_pressed := _diagonalness(Vector2(-1.0, 1.0)) < down_left_weight
	
	_right.pressed = touch_cardinal_dir == 0 or up_right_pressed or down_right_pressed
	_down.pressed = touch_cardinal_dir == 1 or down_right_pressed or down_left_pressed
	_left.pressed = touch_cardinal_dir == 2 or up_left_pressed or down_left_pressed
	_up.pressed = touch_cardinal_dir == 3 or up_left_pressed or up_right_pressed


## Returns a number [0.0, 4.0] for how close the touch is to the specified diagonal.
##
## 0.0 = very close, 4.0 = very far. A value less than 1.0 indicates the touch is in the same correct quadrant as the
## diagonal.
func _diagonalness(diagonal_direction: Vector2) -> float:
	return abs(8 * _touch_dir.angle_to(diagonal_direction) / PI)


func _on_ActionButton_pressed() -> void:
	emit_signal("pressed")
