extends Node
"""
Contains global utilities.
"""

const NUM_SCANCODES: Dictionary = {
	KEY_0: 0, KEY_1: 1, KEY_2: 2, KEY_3: 3, KEY_4: 4,
	KEY_5: 5, KEY_6: 6, KEY_7: 7, KEY_8: 8, KEY_9: 9,
}

"""
Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
"""
static func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode


"""
Returns [0-9] for a number key event, or -1 if the event is not a number key event.
"""
static func key_num(event: InputEvent) -> int:
	return NUM_SCANCODES.get(key_scancode(event), -1)


"""
Returns a vector corresponding to the direction the user is pressing.

Parameters:
	'event': (Optional) The input event to be evaluated. If null, this method will evaluate all current inputs.
"""
static func ui_pressed_dir(event: InputEvent = null) -> Vector2:
	var ui_dir := Vector2.ZERO
	if event:
		if event.is_action_pressed("ui_up"):
			ui_dir += Vector2.UP
		if event.is_action_pressed("ui_down"):
			ui_dir += Vector2.DOWN
		if event.is_action_pressed("ui_left"):
			ui_dir += Vector2.LEFT
		if event.is_action_pressed("ui_right"):
			ui_dir += Vector2.RIGHT
	else:
		if Input.is_action_pressed("ui_up"):
			ui_dir += Vector2.UP
		if Input.is_action_pressed("ui_down"):
			ui_dir += Vector2.DOWN
		if Input.is_action_pressed("ui_left"):
			ui_dir += Vector2.LEFT
		if Input.is_action_pressed("ui_right"):
			ui_dir += Vector2.RIGHT
	return ui_dir


"""
Returns 'true' if the player just released a direction key.

Parameters:
	'event': (Optional) The input event to be evaluated. If null, this method will evaluate all current inputs.
"""
static func ui_released_dir(event: InputEvent = null) -> bool:
	var ui_dir := Vector2.ZERO
	if event:
		if event.is_action_released("ui_up"):
			ui_dir += Vector2.UP
		if event.is_action_released("ui_down"):
			ui_dir += Vector2.DOWN
		if event.is_action_released("ui_left"):
			ui_dir += Vector2.LEFT
		if event.is_action_released("ui_right"):
			ui_dir += Vector2.RIGHT
	else:
		if Input.is_action_just_released("ui_up"):
			ui_dir += Vector2.UP
		if Input.is_action_just_released("ui_down"):
			ui_dir += Vector2.DOWN
		if Input.is_action_just_released("ui_left"):
			ui_dir += Vector2.LEFT
		if Input.is_action_just_released("ui_right"):
			ui_dir += Vector2.RIGHT
	return ui_dir.length() > 0


"""
Returns a transparent version of the specified color.

Tweening from forest green to 'Color.transparent' results in some strange in-between frames which are grey or white.
It's better to tween to a transparent forest green.
"""
static func to_transparent(color: Color, alpha := 0.0) -> Color:
	return Color(color.r, color.g, color.b, alpha)


"""
Returns the arithmetic mean (average) of the specified array.

Returns a default value of 0.0 if the array is empty.
"""
static func mean(values: Array, default := 0.0) -> float:
	if not values:
		return default
	
	var sum := 0.0
	for value in values:
		sum += value
	return sum / len(values)


"""
Returns the maximum value of the specified array.

Returns a default value of 0.0 if the array is empty.
"""
static func max_value(values: Array, default := 0.0) -> float:
	if not values:
		return default
	
	var max_value: float = values[0]
	for value in range(1, len(values)):
		max_value = max(value, max_value)
	return max_value
