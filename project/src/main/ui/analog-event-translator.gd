extends Node
## Allows the analog stick to update actions mapped to the D-Pad.
##
## Actions such as 'ui_up' and 'move_piece_right' are mapped to the D-Pad. Godot supports adding Joypad axes to input
## maps, but this results in undesired behavior:
##
## 	1. Pressing a direction on the analog stick activates the action many times, not just once
## 	2. Holding the direction 100% on the analog stick stops activating the action at all
##
## This autoload singleton scans the Input Map for any events mapped to the D-Pad, and activates those events when the
## analog stick is pressed. Each event is activated only once each time the analog stick is pressed.

## Deadzone for detecting analog stick input
const DEADZONE := 0.5

## List of joypad devices currently mapped in the InputMap
var _monitored_devices: Array

## 'True' if the specified direction is currently held by the analog stick. It is possible for multiple directions to
## be held at once.
var _up_pressed := false
var _down_pressed := false
var _left_pressed := false
var _right_pressed := false

## Joypad action mappings populated by scanning the InputMap.
##
## Key: (String) Hyphenated joypad device and direction, such as '0-right' or '0-left'
## Value: (Array, String) Actions activated by the specified joypad device and direction
var _actions_by_device_and_direction := {}

func _ready() -> void:
	KeybindManager.connect("input_map_updated", self, "_on_KeybindManager_input_map_updated")
	_refresh_inputs()


func _process(_delta: float) -> void:
	if not InputManager.input_mode == InputManager.InputMode.JOYPAD:
		# Disable analog processing if the player is not using the gamepad, for efficiency.
		#
		# Processing analog stick input is extremely fast (15 usec) but intuitively, this algorithm is complicated and
		# it feels inefficient to leave it running.
		return
	
	for device in _monitored_devices:
		# trigger left and right actions based on the joypad x-axis
		var left_stick_x := Input.get_joy_axis(device, JOY_AXIS_0)
		if left_stick_x < -DEADZONE:
			if not _left_pressed:
				_trigger_actions(_actions_by_device_and_direction["%s-left" % [device]], true)
				_left_pressed = true
		elif left_stick_x > DEADZONE:
			if not _right_pressed:
				_trigger_actions(_actions_by_device_and_direction["%s-right" % [device]], true)
				_right_pressed = true
		else:
			if _left_pressed:
				_trigger_actions(_actions_by_device_and_direction["%s-left" % [device]], false)
				_left_pressed = false
			if _right_pressed:
				_trigger_actions(_actions_by_device_and_direction["%s-right" % [device]], false)
				_right_pressed = false
		
		# trigger up and down actions based on the joypad y-axis
		var left_stick_y := Input.get_joy_axis(device, JOY_AXIS_1)
		if left_stick_y < -DEADZONE:
			if not _up_pressed:
				_trigger_actions(_actions_by_device_and_direction["%s-up" % [device]], true)
				_up_pressed = true
		elif left_stick_y > DEADZONE:
			if not _down_pressed:
				_trigger_actions(_actions_by_device_and_direction["%s-down" % [device]], true)
				_down_pressed = true
		else:
			if _up_pressed:
				_trigger_actions(_actions_by_device_and_direction["%s-up" % [device]], false)
				_up_pressed = false
			if _down_pressed:
				_trigger_actions(_actions_by_device_and_direction["%s-down" % [device]], false)
				_down_pressed = false


## Refreshes the input mappings for all monitored devices by scanning the InputMap.
func _refresh_inputs() -> void:
	_monitored_devices = _get_monitored_devices()
	
	_actions_by_device_and_direction.clear()
	for device in _monitored_devices:
		_actions_by_device_and_direction["%s-up" % [device]] = _get_actions_for_device_and_button(device, 12)
		_actions_by_device_and_direction["%s-down" % [device]] = _get_actions_for_device_and_button(device, 13)
		_actions_by_device_and_direction["%s-left" % [device]] = _get_actions_for_device_and_button(device, 14)
		_actions_by_device_and_direction["%s-right" % [device]] = _get_actions_for_device_and_button(device, 15)


## Triggers the given list of actions as either pressed or released.
##
## Parameters:
## 	'actions': List of String actions to trigger.
##
## 	'pressed': If true, the action's state is pressed. If false, the action's state is released.
func _trigger_actions(actions: Array, pressed: bool) -> void:
	for action in actions:
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = pressed
		Input.parse_input_event(ev)


## Returns a list of device indexes with D-Pad inputs mapped in the InputMap.
##
## Specifically looks for actions mapped to buttons 12 (up), 13 (down), 14 (left) and 15 (right)
func _get_monitored_devices() -> Array:
	var devices_set := {}
	for action in InputMap.get_actions():
		var events := InputMap.get_action_list(action)
		for event in events:
			if event is InputEventJoypadButton and event.button_index in [12, 13, 14, 15]:
				devices_set[event.device] = true
	return devices_set.keys()


## Returns a list of actions mapped to the specified D-Pad input in the InputMap.
##
## Parameters:
## 	'device': joypad device index
##
## 	'button': A D-Pad button such as 12 (up), 13 (down), 14 (left) or 15 (right)
func _get_actions_for_device_and_button(device: int, button: int) -> Array:
	var actions_set := {}
	for action in InputMap.get_actions():
		var events := InputMap.get_action_list(action)
		for event in events:
			if event is InputEventJoypadButton and event.device == device and event.button_index == button:
				actions_set[action] = true
	return actions_set.keys()


## When the player changes their keybinds, we refresh our joypad action mappings.
func _on_KeybindManager_input_map_updated() -> void:
	_refresh_inputs()
