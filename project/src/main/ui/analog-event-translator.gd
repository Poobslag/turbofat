extends Node
## Allows the analog stick to update actions mapped to the D-Pad.
##
## Actions such as 'ui_up' and 'move_piece_right' are mapped to the D-Pad. Godot supports adding Joypad axes to input
## maps, but this results in undesired behavior:
##
## 	1. Pressing a direction on the analog stick activates the action many times, not just once
## 	2. Holding the direction 100% on the analog stick stops activating the action at all
##
## This autoload singleton scans the Input Map for any events mapped to the D-Pad, and sends out JoypadButton events
## when the analog stick is held. A JoypadButton event is activated only once each time the analog stick is held.

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

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
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
				_trigger_joypad_button(device, 14, true)
				_left_pressed = true
		elif left_stick_x > DEADZONE:
			if not _right_pressed:
				_trigger_joypad_button(device, 15, true)
				_right_pressed = true
		else:
			if _left_pressed:
				_trigger_joypad_button(device, 14, false)
				_left_pressed = false
			if _right_pressed:
				_trigger_joypad_button(device, 15, false)
				_right_pressed = false
		
		# trigger up and down actions based on the joypad y-axis
		var left_stick_y := Input.get_joy_axis(device, JOY_AXIS_1)
		if left_stick_y < -DEADZONE:
			if not _up_pressed:
				_trigger_joypad_button(device, 12, true)
				_up_pressed = true
		elif left_stick_y > DEADZONE:
			if not _down_pressed:
				_trigger_joypad_button(device, 13, true)
				_down_pressed = true
		else:
			if _up_pressed:
				_trigger_joypad_button(device, 12, false)
				_up_pressed = false
			if _down_pressed:
				_trigger_joypad_button(device, 13, false)
				_down_pressed = false


## Refreshes the input mappings for all monitored devices by scanning the InputMap.
func _refresh_inputs() -> void:
	_monitored_devices = _get_monitored_devices()


## Triggers the given joypad button as either pressed or released.
##
## Parameters:
## 	'device': Joypad device to trigger
##
## 	'button_index': D-Pad button index to trigger such as 12 (up), 13 (down), 14 (left) or 15 (right)
##
## 	'pressed': If true, the action's state is pressed. If false, the action's state is released.
func _trigger_joypad_button(device: int, button_index: int, pressed: bool) -> void:
	var ev := InputEventJoypadButton.new()
	ev.device = device
	ev.button_index = button_index
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


## When the player changes their keybinds, we refresh our joypad action mappings.
func _on_KeybindManager_input_map_updated() -> void:
	_refresh_inputs()
