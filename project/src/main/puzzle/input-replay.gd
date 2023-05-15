class_name InputReplay
## Stores a sequence of puzzle inputs to be replayed for things such as tutorials.

## set of actions which are currently in the 'pressed' state
## key: (String) action name
## value: (bool) true
var _pressed_actions: Dictionary

## set of frames when different actions are pressed/released
## key: (String) action key containing the frame number and action, '46 +ui_right'
## value: (bool) true
var action_timings: Dictionary

## Returns true if there is no replay data.
func is_empty() -> bool:
	return action_timings.is_empty()


## Clears the replay data, removing all action timings.
func clear() -> void:
	_pressed_actions.clear()
	action_timings.clear()


## Returns 'true' if the replay data specifies that the action was pressed on the current input frame.
##
## This only true for the exact frame when the press is first triggered.
func is_action_pressed(action: String) -> bool:
	var action_frame_key := "%s +%s" % [PuzzleState.input_frame, action]
	var pressed := action_timings.has(action_frame_key)
	if pressed:
		_pressed_actions[action] = true
	return pressed


## Returns 'true' if the replay data specifies that the action was released on the current input frame.
##
## This only true for the exact frame when the release is first triggered.
func is_action_released(action: String) -> bool:
	var action_frame_key := "%s -%s" % [PuzzleState.input_frame, action]
	var released := action_timings.has(action_frame_key)
	if released:
		_pressed_actions[action] = false
	return released


## Returns 'true' if the replay data specifies that the action was held down on the current input frame.
##
## This returns true once the action is pressed, and returns false once the action is released. It assumes the pressed
## and released functions are being called sequentially on every frame; it does not traverse the input history to find
## the previous press/release event.
func is_action_held(action: String) -> bool:
	return _pressed_actions.get(action, false)


func from_json_array(json: Array) -> void:
	for json_obj in json:
		action_timings[json_obj] = true


func to_json_array() -> Array:
	return action_timings.keys()


## Returns 'true' if the input replay is empty. Empty replays are omitted from our json output.
##
## Note: This method is called 'is_default' for consistency with other similar methods related to LevelSettings.
func is_default() -> bool:
	return action_timings.is_empty()
