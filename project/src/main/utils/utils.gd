tool
class_name Utils
## Contains global utilities.

const NUM_SCANCODES := {
	KEY_0: 0, KEY_1: 1, KEY_2: 2, KEY_3: 3, KEY_4: 4,
	KEY_5: 5, KEY_6: 6, KEY_7: 7, KEY_8: 8, KEY_9: 9,
}


## If the specified array item does not exist, this method appends it.
static func append_if_absent(array: Array, value) -> void:
	if not array.has(value):
		array.append(value)


## Assigns a default path for a FileDialog.
##
## At runtime, this will default to the user data directory. During development, this will default to a resource path
## for convenience when authoring Turbo Fat's creature's/levels.
##
## Note: We only want to assign the path the first time, but we can't check 'is the path empty' because an empty path
## is a valid choice -- a player can navigate to the root directory. So instead of checking 'is the path empty' we
## check 'is the path this specific UUID' since that's something the user will never navigate to accidentally.
static func assign_default_dialog_path(dialog: FileDialog, default_resource_path: String) -> void:
	if dialog.current_path == "/509e7c82-9399-425a-9f15-9370c2b3de8b":
		var current_path := ProjectSettings.globalize_path(default_resource_path)
		if not Directory.new().dir_exists(current_path):
			current_path = OS.get_user_data_dir()
		dialog.current_path = current_path


## Returns the perceived brightness of a color.
##
## This allows UI elements to avoid combinations like dark blue on black or light green on white.
##
## Parameters:
## 	'color': The color whose brightness should be calculated. The alpha component is ignored.
##
## Returns:
## 	A number in the range [0.0, 1.0] corresponding to the color's perceived brightness.
static func brightness(color: Color) -> float:
	return clamp(color.r * 0.2990 + color.g * 0.5871 + color.b * 0.1140, 0.0, 1.0)


## Converts the float values in an array to int values.
##
## Godot's JSON parser converts all ints into floats, so we need to change them back. See Godot #9499
## (https://github.com/godotengine/godot/issues/9499)
static func convert_floats_to_ints_in_array(a: Array) -> Array:
	var result := []
	for i in range(a.size()):
		result.append(int(a[i]) if a[i] is float else a[i])
	return result


## Converts the float keys and values in a Dictionary to int values.
##
## Godot's JSON parser converts all ints into floats, so we need to change them back. See Godot #9499
## (https://github.com/godotengine/godot/issues/9499)
static func convert_floats_to_ints_in_dict(dict: Dictionary) -> Dictionary:
	var result := {}
	for in_key in dict:
		var out_key := int(in_key) if in_key is float else in_key
		var out_value := int(dict[in_key]) if dict[in_key] is float else dict[in_key]
		result[out_key] = out_value
	return result


## Returns a new array containing the disjunction of the given arrays.
##
## This is equivalent to union(subtract(a, b), subtract(b, a)).
static func disjunction(a: Array, b: Array) -> Array:
	var result := []
	var bag := {}
	for item in a:
		put_if_absent(bag, item, 0)
		bag[item] += 1
	for item in b:
		put_if_absent(bag, item, 0)
		bag[item] -= 1
	for item in bag:
		for _i in range(abs(bag[item])):
			result.append(item)
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


## Returns the array index whose contents are closest to a target number.
##
## find_closest([1.0, 2.0, 4.0, 8.0], 6.0) = 2
## find_closest([1.0, 2.0, 4.0, 8.0], 100) = 3
## find_closest([], 100)                   = -1
static func find_closest(values: Array, target: float) -> int:
	if values.empty():
		return -1
	
	var result := 0
	for i in range(1, values.size()):
		if abs(target - values[i]) < abs(target - values[result]):
			result = i
	return result


## Returns a list of all of a node's descendants assigned to the given group.
##
## Parameters:
## 	'parent': The parent node to search
##
## 	'group': The group name to search for
static func get_child_members(parent: Node, group: String) -> Array:
	if not parent:
		return []
	
	var child_members := []
	for member in parent.get_tree().get_nodes_in_group(group):
		if parent.is_a_parent_of(member):
			child_members.append(member)
	return child_members



## Returns a new array containing the intersection of the given arrays.
static func intersection(a: Array, b: Array) -> Array:
	var result := []
	var bag := {}
	for item in b:
		put_if_absent(bag, item, 0)
		bag[item] += 1
	for item in a:
		if bag.has(item):
			bag[item] -= 1
			if bag[item] == 0:
				bag.erase(item)
			result.append(item)
	return result


## Converts an Aseprite json region to a Rect2.
static func json_to_rect2(json: Dictionary) -> Rect2:
	return Rect2(json.x, json.y, json.w, json.h)


## Returns [0-9] for a number key event, or -1 if the event is not a number key event.
static func key_num(event: InputEvent) -> int:
	return NUM_SCANCODES.get(key_scancode(event), -1)


## Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
static func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode


## Invalidates a tween if it is already active.
##
## Killing a SceneTreeTween requires a null check, but this makes it a one-liner.
##
## Parameters:
## 	'tween': The tween to invalidate. Can be null.
##
## Returns:
## 	null
static func kill_tween(tween: SceneTreeTween) -> SceneTreeTween:
	if tween:
		tween.kill()
	return null


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
	return (tile_map.map_to_world(cell) + tile_map.map_to_world(cell + Vector2.ONE)) * 0.5


## Returns the maximum value of the specified array.
##
## Returns a default value of 0.0 if the array is empty.
static func max_value(values: Array, default := 0.0) -> float:
	if values.empty():
		return default
	
	var max_value: float = values[0]
	for value in range(1, len(values)):
		max_value = max(value, max_value)
	return max_value


## Returns the arithmetic mean (average) of the specified array.
##
## Returns a default value of 0.0 if the array is empty.
static func mean(values: Array, default := 0.0) -> float:
	if values.empty():
		return default
	
	var sum := 0.0
	for value in values:
		sum += value
	return sum / len(values)


static func print_json(value) -> String:
	return JSON.print(value, "  ")


## If the specified key does not exist, this method associates it with the given value.
static func put_if_absent(dict: Dictionary, key, value) -> void:
	dict[key] = dict.get(key, value)


## Returns a random value from the specified array.
static func rand_value(values: Array):
	return values[randi() % values.size()]


## Generates a pseudo-random 32-bit signed integer between from and to (inclusive).
static func randi_range(from: int, to: int) -> int:
	return randi() % (to + 1 - from) + from


## Creates/recreates a tween, invalidating it if it is already active.
##
## This is useful for SceneTreeTweens. These are designed to be created and thrown away, but tweening the same
## property with multiple tweens creates unpredictable behavior. This recreate_tween method lets us ensure each
## property is only being modified by a single tween.
##
## Parameters:
## 	'node': The scene tree node which the tween should be bound to. This affects details like whether the tween
## 		stops if the player pauses the game.
##
## 	'tween': The tween to invalidate. Can be null.
##
## Returns:
## 	A new SceneTreeTween bound to the specified node.
static func recreate_tween(node: Node, tween: SceneTreeTween) -> SceneTreeTween:
	kill_tween(tween)
	return node.create_tween()


## Removes all occurrences of the specified element from the specified array
static func remove_all(values: Array, value) -> Array:
	var index := 0
	while index < values.size():
		if values[index] == value:
			values.remove(index)
		else:
			index += 1
	return values


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


## Returns a new array containing a - b.
static func subtract(a: Array, b: Array) -> Array:
	var result := []
	var bag := {}
	for item in b:
		put_if_absent(bag, item, 0)
		bag[item] += 1
	for item in a:
		if bag.has(item):
			bag[item] -= 1
			if bag[item] == 0:
				bag.erase(item)
		else:
			result.append(item)
	return result


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


## Returns a transparent version of the specified color.
##
## Tweening from forest green to 'Color.transparent' results in some strange in-between frames which are grey or white.
## It's better to tween to a transparent forest green.
static func to_transparent(color: Color, alpha := 0.0) -> Color:
	return Color(color.r, color.g, color.b, alpha)


## Returns a unit vector corresponding to the direction the user is pressing.
##
## Parameters:
## 	'event': (Optional) Input event to be evaluated. If null, this method will evaluate all current inputs.
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
	return ui_dir.normalized()


## Returns a unit vector corresponding to the direction the user just released.
##
## Parameters:
## 	'event': (Optional) Input event to be evaluated. If null, this method will evaluate all current inputs.
static func ui_released_dir(event: InputEvent = null) -> Vector2:
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
	return ui_dir.normalized()


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
