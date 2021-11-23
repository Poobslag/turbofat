tool
class_name Utils
## Contains global utilities.

const NUM_SCANCODES := {
	KEY_0: 0, KEY_1: 1, KEY_2: 2, KEY_3: 3, KEY_4: 4,
	KEY_5: 5, KEY_6: 6, KEY_7: 7, KEY_8: 8, KEY_9: 9,
}

static func print_json(value) -> String:
	return JSON.print(value, "  ")


## Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
static func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode


## Returns [0-9] for a number key event, or -1 if the event is not a number key event.
static func key_num(event: InputEvent) -> int:
	return NUM_SCANCODES.get(key_scancode(event), -1)


## Returns a vector corresponding to the direction the user is pressing.
##
## Parameters:
## 	'event': (Optional) The input event to be evaluated. If null, this method will evaluate all current inputs.
static func walk_pressed_dir(event: InputEvent = null) -> Vector2:
	var walk_dir := Vector2.ZERO
	if event:
		if event.is_action_pressed("walk_up"):
			walk_dir += Vector2.UP
		if event.is_action_pressed("walk_down"):
			walk_dir += Vector2.DOWN
		if event.is_action_pressed("walk_left"):
			walk_dir += Vector2.LEFT
		if event.is_action_pressed("walk_right"):
			walk_dir += Vector2.RIGHT
	else:
		if Input.is_action_pressed("walk_up"):
			walk_dir += Vector2.UP
		if Input.is_action_pressed("walk_down"):
			walk_dir += Vector2.DOWN
		if Input.is_action_pressed("walk_left"):
			walk_dir += Vector2.LEFT
		if Input.is_action_pressed("walk_right"):
			walk_dir += Vector2.RIGHT
	return walk_dir


## Returns 'true' if the player just released a direction key.
##
## Parameters:
## 	'event': (Optional) The input event to be evaluated. If null, this method will evaluate all current inputs.
static func walk_released_dir(event: InputEvent = null) -> bool:
	var walk_dir := Vector2.ZERO
	if event:
		if event.is_action_released("walk_up"):
			walk_dir += Vector2.UP
		if event.is_action_released("walk_down"):
			walk_dir += Vector2.DOWN
		if event.is_action_released("walk_left"):
			walk_dir += Vector2.LEFT
		if event.is_action_released("walk_right"):
			walk_dir += Vector2.RIGHT
	else:
		if Input.is_action_just_released("walk_up"):
			walk_dir += Vector2.UP
		if Input.is_action_just_released("walk_down"):
			walk_dir += Vector2.DOWN
		if Input.is_action_just_released("walk_left"):
			walk_dir += Vector2.LEFT
		if Input.is_action_just_released("walk_right"):
			walk_dir += Vector2.RIGHT
	return walk_dir.length() > 0


## Returns a transparent version of the specified color.
##
## Tweening from forest green to 'Color.transparent' results in some strange in-between frames which are grey or white.
## It's better to tween to a transparent forest green.
static func to_transparent(color: Color, alpha := 0.0) -> Color:
	return Color(color.r, color.g, color.b, alpha)


## Returns the arithmetic mean (average) of the specified array.
##
## Returns a default value of 0.0 if the array is empty.
static func mean(values: Array, default := 0.0) -> float:
	if not values:
		return default
	
	var sum := 0.0
	for value in values:
		sum += value
	return sum / len(values)


## Returns the maximum value of the specified array.
##
## Returns a default value of 0.0 if the array is empty.
static func max_value(values: Array, default := 0.0) -> float:
	if not values:
		return default
	
	var max_value: float = values[0]
	for value in range(1, len(values)):
		max_value = max(value, max_value)
	return max_value


## Returns a random value from the specified array.
static func rand_value(values: Array):
	return values[randi() % values.size()]


## Returns a random key from the specified dictionary.
##
## The values in the dictionary are numeric weights for each key.
static func weighted_rand_value(weights_map: Dictionary):
	# select a random index in the range [0.0, sum_of_weights)
	var selected_index := 0.0
	for value in weights_map.values():
		selected_index += value
	selected_index *= randf()
	
	# calculate which value corresponds to the selected index
	var selected_value
	for key in weights_map:
		selected_index -= weights_map[key]
		if selected_index <= 0.0:
			selected_value = key
			break
	
	return selected_value


## Returns the array index whose contents are closest to a target number.
##
## Utils.find_closest([1.0, 2.0, 4.0, 8.0], 6.0) = 2
## Utils.find_closest([1.0, 2.0, 4.0, 8.0], 100) = 3
## Utils.find_closest([], 100)                   = -1
static func find_closest(values: Array, target: float) -> int:
	if not values:
		return -1
	
	var result := 0
	for i in range(1, values.size()):
		if abs(target - values[i]) < abs(target - values[result]):
			result = i
	return result


## If the specified key does not exist, this method associates it with the given value.
static func put_if_absent(dict: Dictionary, key: String, value) -> void:
	dict[key] = dict.get(key, value)


static func remove_all(values: Array, value) -> Array:
	var index := 0
	while index < values.size():
		if values[index] == value:
			values.remove(index)
		else:
			index += 1
	return values


## Returns a new array containing a - b.
##
## The input arrays are not modified. This code is adapted from Apache Common Collections.
static func subtract(a: Array, b: Array) -> Array:
	var result := []
	var bag := {}
	for item in b:
		if not bag.has(item):
			bag[item] = 0
		bag[item] += 1
	for item in a:
		if bag.has(item):
			bag[item] -= 1
			if bag[item] == 0:
				bag.erase(item)
		else:
			result.append(item)
	return result


## Assigns a default path for a FileDialog.
##
## At runtime, this will default to the user's data directory. During development, this will default to a resource path
## for convenience when authoring Turbo Fat's creature's/levels.
##
## Note: We only want to assign the path the first time, but we can't check 'is the path empty' because an empty path
## is a valid choice -- a user can navigate to the root directory. So instead of checking 'is the path empty' we check
## 'is the path this specific UUID' since that's something the user will never navigate to accidentally.
static func assign_default_dialog_path(dialog: FileDialog, default_resource_path: String) -> void:
	if dialog.current_path == "/509e7c82-9399-425a-9f15-9370c2b3de8b":
		var current_path := ProjectSettings.globalize_path(default_resource_path)
		if not Directory.new().dir_exists(current_path):
			current_path = OS.get_user_data_dir()
		dialog.current_path = current_path


## Converts an Aseprite json region to a Rect2.
static func json_to_rect2(json: Dictionary) -> Rect2:
	return Rect2(json.x, json.y, json.w, json.h)


## Converts an enum value like 'LevelTriggerPhase.ROTATED_CW' to a snake case string like 'rotated_cw'.
##
## Parameters:
## 	'enum_dict': An enum type such as 'PuzzleTileMap.TileSetType'
##
## 	'from': The enum value to convert
##
## 	'default': Default value to assume if the specified enum value is invalid
static func enum_to_snake_case(
		enum_dict: Dictionary, from: int, default: String = "e3343934-8d10-46f8-b19d-da50eb47d0d8") -> String:
	var result: String
	if from >= 0 and from < enum_dict.size():
		# 'from' is a valid enum, return the snake case key
		result = enum_dict.keys()[from].to_lower()
	elif default != "e3343934-8d10-46f8-b19d-da50eb47d0d8":
		# 'from' is an invalid enum, return the specified default
		result = default
	elif not enum_dict.empty():
		# 'from' is an invalid enum and no default was specified, use the first key
		result = enum_dict.keys()[0].to_lower()
	else:
		# 'from' is an invalid enum and no defaults are available, return an empty string
		result = ""
	return result


## Converts a snake case string like 'rotated_cw' to an enum value like 'LevelTriggerPhase.ROTATED_CW'.
##
## Parameters:
## 	'enum_dict': An enum type such as 'PuzzleTileMap.TileSetType'
##
## 	'from': The snake case string to convert
##
## 	'default': Default value to assume if the specified snake case string is invalid
static func enum_from_snake_case(enum_dict: Dictionary, from: String, default: int = 0) -> int:
	return enum_dict.get(from.to_upper(), default)


## Converts a string to a bool, treating values like 'False', and 'false' as false values.
##
## This is a workaround for Godot #27529 (https://github.com/godotengine/godot/issues/27529). When converting a bool to
## a String, the String is set to "True" and "False" for the appropriate boolean values. However, when converting a
## String to a bool, the bool is set to true if the string is non-empty, regardless of the contents.
##
## This code is adapted from Andrettin's suggested fix. Per his suggestion, the result is true if the String is "True",
## "TRUE", "true" or "1", and false if the String is "False", "FALSE", "false" or "0". If the string is set to anything
## else, then it is true if non-empty, and false otherwise.
static func to_bool(s: String) -> bool:
	var result: bool
	match s:
		"True", "TRUE", "true", "1": result = true
		"False", "FALSE", "false", "0": result = false
		_: result = false if s.empty() else true
	return result


## Returns the local position of the center of the cell corresponding to the given tilemap (grid-based) coordinates.
##
## One might expect this could be implemented trivially by passing in something like 'map_to_world(2.5, 2.5)' to
## get the center of the cell at (2, 2). But, map_to_world does not work that way.
##
## One might also expect this could be implemented by doing something like "Get the top left corner, and shift it by
## half the cell size." But, this returns incorrect results for isometric tilemaps.
##
## For now, the nuance and complexity required in correctly implementing this trivial functionality warrants a utility
## function.
static func map_to_world_centered(tile_map: TileMap, cell: Vector2) -> Vector2:
	return (tile_map.map_to_world(cell) + tile_map.map_to_world(cell + Vector2(1, 1))) * 0.5


## Shuffles the entries of the given array in a predictable manner, using the Fisher-Yates algorithm.
##
## The randomness is controlled by the seed_int parameter, making this a useful substitute for the built-in
## Array.shuffle() method for scenarios where we want the array to always shuffle the same way.
static func seeded_shuffle(arr: Array, seed_int: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_int
	for i in range(arr.size() - 2):
		var j := rng.randi_range(i, arr.size() - 1)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
