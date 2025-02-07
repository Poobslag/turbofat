class_name KeybindSettings
## Manages settings which affect the keyboard/joystick input for controlling the game.
##
## The player can select between 'Guideline', 'WASD' or 'Custom' presets. We store a set of custom keybinds, although
## these are ignored unless the player selects the 'Custom' preset.

## emitted if new settings are loaded, or the preset changes, or the player rebinds a key
signal settings_changed

enum KeybindPreset {
	GUIDELINE,
	WASD,
	CUSTOM
}

## Images to show for XBox inputs
const XBOX_IMAGE_A := preload("res://assets/main/ui/xbox/xbox-a.png")
const XBOX_IMAGE_B := preload("res://assets/main/ui/xbox/xbox-b.png")
const XBOX_IMAGE_X := preload("res://assets/main/ui/xbox/xbox-x.png")
const XBOX_IMAGE_Y := preload("res://assets/main/ui/xbox/xbox-y.png")
const XBOX_IMAGE_LB := preload("res://assets/main/ui/xbox/xbox-lb.png")
const XBOX_IMAGE_RB := preload("res://assets/main/ui/xbox/xbox-rb.png")
const XBOX_IMAGE_LT := preload("res://assets/main/ui/xbox/xbox-lt.png")
const XBOX_IMAGE_RT := preload("res://assets/main/ui/xbox/xbox-rt.png")
const XBOX_IMAGE_LEFT_STICK_CLICK := preload("res://assets/main/ui/xbox/xbox-left-stick-click.png")
const XBOX_IMAGE_RIGHT_STICK_CLICK := preload("res://assets/main/ui/xbox/xbox-right-stick-click.png")
const XBOX_IMAGE_VIEW := preload("res://assets/main/ui/xbox/xbox-view.png")
const XBOX_IMAGE_MENU := preload("res://assets/main/ui/xbox/xbox-menu.png")
const XBOX_IMAGE_DPAD := preload("res://assets/main/ui/xbox/xbox-dpad.png")
const XBOX_IMAGE_DPAD_UP := preload("res://assets/main/ui/xbox/xbox-dpad-up.png")
const XBOX_IMAGE_DPAD_DOWN := preload("res://assets/main/ui/xbox/xbox-dpad-down.png")
const XBOX_IMAGE_DPAD_LEFT := preload("res://assets/main/ui/xbox/xbox-dpad-left.png")
const XBOX_IMAGE_DPAD_RIGHT := preload("res://assets/main/ui/xbox/xbox-dpad-right.png")

## key: button index
## value: XBox input image texture
const XBOX_IMAGES_BY_BUTTON := {
	0: XBOX_IMAGE_A,
	1: XBOX_IMAGE_B,
	2: XBOX_IMAGE_X,
	3: XBOX_IMAGE_Y,
	4: XBOX_IMAGE_LB,
	5: XBOX_IMAGE_RB,
	6: XBOX_IMAGE_LT,
	7: XBOX_IMAGE_RT,
	8: XBOX_IMAGE_LEFT_STICK_CLICK,
	9: XBOX_IMAGE_RIGHT_STICK_CLICK,
	10: XBOX_IMAGE_VIEW,
	11: XBOX_IMAGE_MENU,
	12: XBOX_IMAGE_DPAD_UP,
	13: XBOX_IMAGE_DPAD_DOWN,
	14: XBOX_IMAGE_DPAD_LEFT,
	15: XBOX_IMAGE_DPAD_RIGHT,
}

## files defining keybind presets
const GUIDELINE_PATH := "res://assets/main/keybind/guideline.json"
const GUIDELINE_HOLD_PATH := "res://assets/main/keybind/guideline-hold.json"
const WASD_PATH := "res://assets/main/keybind/wasd.json"
const WASD_HOLD_PATH := "res://assets/main/keybind/wasd-hold.json"
const DEFAULT_CUSTOM_PATH := "res://assets/main/keybind/default-custom.json"

const GUIDELINE := KeybindPreset.GUIDELINE
const WASD := KeybindPreset.WASD
const CUSTOM := KeybindPreset.CUSTOM

## Set of inputs accepted while playing a puzzle.
## This includes inputs for steering the piece and bringing up a menu.
const PUZZLE_ACTION_NAMES := {
	"move_piece_left": true,
	"move_piece_right": true,
	"soft_drop": true,
	"hard_drop": true,
	"rotate_ccw": true,
	"rotate_cw": true,
	"ui_menu": true,
}

## Set of inputs accepted in menus.
const MENU_ACTION_NAMES := {
	"ui_up": true,
	"ui_down": true,
	"ui_left": true,
	"ui_right": true,
	"ui_accept": true,
	"ui_cancel": true,
	"next_tab": true,
	"prev_tab": true,
}

## Set of inputs accepted on the overworld.
## This includes inputs for walking, interacting, and bringing up a menu.
const OVERWORLD_ACTION_NAMES := {
	"rewind_text": true,
	"ui_menu": true,
}

## Player's selected keybind preset, or 'Custom' if they've defined their own
var preset := GUIDELINE setget set_preset

## Json representation of the player's custom keybinds
var custom_keybinds: Dictionary

func reset() -> void:
	from_json_dict({})


func set_preset(new_preset: int) -> void:
	preset = new_preset
	emit_signal("settings_changed")


## Restore the default keybind for a specific action.
##
## This can also trigger unbinding/rebinding other conflicting actions.
##
## Parameters:
## 	'action_name': The action whose keybinds to restore
func restore_default_keybinds(action_name: String) -> void:
	var json_text := FileUtils.get_file_as_text(DEFAULT_CUSTOM_PATH)
	var json_dict: Dictionary = parse_json(json_text)
	
	for i in range(json_dict[action_name].size()):
		_set_custom_keybind_inner(action_name, i, json_dict[action_name][i])
	
	emit_signal("settings_changed")


## Updates the custom keybind for a specific action.
##
## Unbinds any conflicting actions to avoid cases where the Left Arrow is accidentally bound to two conflicting
## actions. It's OK if the actions are in different contexts (ui_left, move_piece_left) but problematic if the actions
## are in the same context (activate, rewind_text)
##
## Parameters:
## 	'action_name': The action whose keybind is being updated
##
## 	'index': A number in the range [0, 2] specifying which keybind is being updated. Each action supports up to three
## 		custom keybinds.
##
## 	'json': A json representation of a keyboard or joypad input
func set_custom_keybind(action_name: String, index: int, json: Dictionary) -> void:
	_set_custom_keybind_inner(action_name, index, json)
	emit_signal("settings_changed")


func _set_custom_keybind_inner(action_name: String, index: int, json: Dictionary) -> void:
	_unbind_conflicting_actions(action_name, index, json)
	
	Utils.put_if_absent(custom_keybinds, action_name, [{}, {}, {}])
	custom_keybinds[action_name][index] = json
	
	if not valid_custom_ui_keybinds():
		push_warning("Invalid custom ui keybinds; restoring defaults.")
		restore_default_custom_keybinds()


## Returns a json reprentation of the specified keybind.
##
## Parameters:
## 	'action_name': The action whose keybind should be returned
##
## 	'index': A number in the range [0, 2] specifying which keybind should be returned. Each action supports up to three
## 		custom keybinds.
func get_custom_keybind(action_name: String, index: int) -> Dictionary:
	var result := {}
	if custom_keybinds.has(action_name):
		result = custom_keybinds[action_name][index]
	return result


func to_json_dict() -> Dictionary:
	return {
		"preset": preset,
		"custom_keybinds": custom_keybinds,
	}


func from_json_dict(json: Dictionary) -> void:
	preset = int(json.get("preset", GUIDELINE))
	custom_keybinds = json.get("custom_keybinds", {})
	if custom_keybinds.empty():
		restore_default_custom_keybinds()
	
	if not valid_custom_ui_keybinds():
		push_warning("Invalid custom ui keybinds; restoring defaults.")
		restore_default_custom_keybinds()
	
	emit_signal("settings_changed")


## Resets the custom keybinds to a sensible set of defaults.
func restore_default_custom_keybinds() -> void:
	var json_text := FileUtils.get_file_as_text(DEFAULT_CUSTOM_PATH)
	var json_dict: Dictionary = parse_json(json_text)
	custom_keybinds = json_dict
	emit_signal("settings_changed")


## Unbinds/rebinds any keybinds which conflict with the specified keybind.
##
## It's OK for two actions to be bound by the same key if they're in different contexts (ui_left, move_piece_left) but
## problematic if the actions are in the same context (activate, rewind_text).
func _unbind_conflicting_actions(action_name: String, index: int, json: Dictionary) -> void:
	for other_action_name in _conflicting_action_names(action_name):
		if not custom_keybinds.has(other_action_name):
			continue
		for other_index in range(custom_keybinds[other_action_name].size()):
			var other_json: Dictionary = custom_keybinds[other_action_name][other_index]
			if _shallow_equal_dicts(json, other_json):
				custom_keybinds[other_action_name][other_index] = {}
	
	if action_name in MENU_ACTION_NAMES:
		# Ensure all UI actions are bound to something. If the player unbinds their UI controls, they can't fix them
		# using the controller or keyboard. This would hard lock the game on platforms like the Nintendo Switch where
		# they don't have a mouse available.
		
		for menu_action_name in MENU_ACTION_NAMES:
			var menu_action_input_count := _menu_action_input_count(menu_action_name)
			
			if menu_action_input_count == 0:
				# After unbinding, a menu action is bound to nothing. Rebind it to the input currently being rebound.
				var source_index := 0
				if custom_keybinds[action_name][index]:
					source_index = index
				
				custom_keybinds[menu_action_name][0] = custom_keybinds[action_name][source_index]
				custom_keybinds[action_name][source_index] = {}


func _menu_action_input_count(menu_action_name: String) -> int:
	if not custom_keybinds.has(menu_action_name):
		return 0
	
	var menu_action_input_count := 0
	for menu_index in range(custom_keybinds[menu_action_name].size()):
		if custom_keybinds[menu_action_name][menu_index]:
			menu_action_input_count += 1
	return menu_action_input_count


## Returns a list of action names which appear in the same context as the specified keybind.
##
## For example, move_piece_left and ui_menu both appear in the same context as rotate_ccw; when the player is playing a
## puzzle they might activate any of these actions. These are considered 'conflicting actions', and it is problematic
## for the same key to be bound to two of these actions.
##
## On the other hand, move_piece_left and ui_left appear in different contexts; the player would never try to move
## their piece while navigating a menu. These are not considered 'conflicting actions', and it is OK for the same key
## to be bound to two of these actions.
##
## Parameters:
## 	'action_name': The action to analyze
##
## Returns:
## 	An array of action names which cannot share keybinds with the specified action, including the action itself
func _conflicting_action_names(action_name: String) -> Array:
	var conflicting_action_names := {}
	for other_action_names in [PUZZLE_ACTION_NAMES, MENU_ACTION_NAMES, OVERWORLD_ACTION_NAMES]:
		if other_action_names.has(action_name):
			for other_action_name in other_action_names:
				conflicting_action_names[other_action_name] = true
	return conflicting_action_names.keys()


## Performs a shallow equality check for dictionaries.
func _shallow_equal_dicts(a: Dictionary, b: Dictionary) -> bool:
	var result := true
	if a.size() != b.size():
		result = false
	else:
		for key in a:
			if not b.has(key) or b[key] != a[key]:
				result = false
				break
	return result


## Check that all UI actions are bound to something, and that there are no conflicts.
func valid_custom_ui_keybinds() -> bool:
	var valid := true
	var scancodes := {}
	for menu_action_name in MENU_ACTION_NAMES:
		# detect whether any ui keybinds have no keys defined
		var action_scancode_count := 0
		if custom_keybinds.has(menu_action_name):
			for menu_index in range(custom_keybinds[menu_action_name].size()):
				if custom_keybinds[menu_action_name][menu_index].has("scancode"):
					action_scancode_count += 1
		if action_scancode_count == 0:
			valid = false
			break
		
		# detect whether any ui keybinds have duplicate keys
		var duplicate_scancode := false
		for menu_index in range(custom_keybinds[menu_action_name].size()):
			if not custom_keybinds[menu_action_name][menu_index].has("scancode"):
				continue
			var scancode: int = custom_keybinds[menu_action_name][menu_index]["scancode"]
			if scancodes.has(scancode):
				duplicate_scancode = true
				break
			scancodes[scancode] = true
		if duplicate_scancode:
			valid = false
			break
	
	return valid


## Returns the xbox input image texture for the specified joypad event.
##
## Parameters:
## 	'input_event_json': json containing an xbox 'button_index' key
##
## Returns:
## 	An xbox input image texture showing a button or dpad input.
static func xbox_image_for_input_event(input_event_json: Dictionary) -> Texture:
	return XBOX_IMAGES_BY_BUTTON.get(int(input_event_json.get("button_index", -1)))
