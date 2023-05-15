class_name CutsceneQueue
## Maintains a queue of pending cutscenes and levels.
##
## When the game plays cutscenes, it plays one or more cutscenes and sometimes plays a level or returns to a different
## overworld scene. This script maintains a queue of the pending cutscenes and levels.

## Queue of ChatTree and String instances. ChatTrees represent cutscenes, and strings represent level IDs.
var _queue := []

## Flags for the current set of cutscenes, indicating things like whether they're for a boss level.
var _cutscene_flags := {}

func reset() -> void:
	_queue.clear()
	_cutscene_flags.clear()


## Sets a flag for the current set of cutscenes, indicating something like whether they're for a boss level.
func set_cutscene_flag(flag: String) -> void:
	_cutscene_flags[flag] = true


## Returns 'true' if the specified flag has been enabled for the current set of cutscenes.
##
## These flags can indicate things like whether the cutscenes are for a boss level.
func has_cutscene_flag(flag: String) -> bool:
	return _cutscene_flags.has(flag)


## Adds a cutscene to the back of the queue.
func enqueue_cutscene(chat_tree: ChatTree) -> void:
	_queue.append({
		"type": "cutscene",
		"value": chat_tree,
	})


## Inserts a cutscene in the given position in the queue.
func insert_cutscene(position: int, chat_tree: ChatTree) -> void:
	_queue.insert(position, {
		"type": "cutscene",
		"value": chat_tree,
	})


## Adds a level to the back of the queue.
func enqueue_level(level_properties: Dictionary) -> void:
	_queue.append({
		"type": "level",
		"value": level_properties
	})


## Returns 'true' if there is a pending cutscene/level in the queue.
func is_queue_empty() -> bool:
	return _queue.is_empty()


## Returns 'true' if the first item in the queue represents a cutscene.
func is_front_cutscene() -> bool:
	return _queue and _queue.front().get("type") == "cutscene"


## Returns 'true' if the first item in the queue represents a level.
func is_front_level() -> bool:
	return _queue and _queue.front().get("type") == "level"


## Removes the next scene from the queue and transitions to it, staying at the current level in the breadcrumb trail.
func replace_trail() -> void:
	if is_front_cutscene():
		_pop_cutscene()
		CurrentCutscene.replace_cutscene_trail()
	elif is_front_level():
		_pop_level()
		CurrentLevel.replace_level_trail()
	else:
		push_error("Cannot transition to next item in queue: %s" % [_queue])


## Removes the next scene from the queue and transitions to it, extending the breadcrumb trail.
func push_trail() -> void:
	if is_front_cutscene():
		_pop_cutscene()
		CurrentCutscene.push_cutscene_trail()
	elif is_front_level():
		_pop_level()
		CurrentLevel.push_level_trail()
	else:
		push_error("Cannot transition to next item in queue: %s" % [_queue])


## Removes the next cutscene from the queue and assigns it as the current cutscene.
func _pop_cutscene() -> void:
	var chat_tree: ChatTree = _queue.pop_front()["value"]
	CurrentCutscene.set_launched_cutscene(chat_tree.chat_key)


## Removes the next level from the queue and assigns it as the current level.
func _pop_level() -> void:
	var level_properties: Dictionary = _queue.pop_front()["value"]
	CurrentLevel.set_launched_level(level_properties["level_id"])
	if level_properties.has("piece_speed"):
		CurrentLevel.piece_speed = level_properties["piece_speed"]
	if level_properties.has("chef_id"):
		CurrentLevel.chef_id = level_properties["chef_id"]
	if level_properties.has("customers"):
		CurrentLevel.customers = level_properties["customers"]
	if level_properties.has("puzzle_environment_name"):
		CurrentLevel.puzzle_environment_name = level_properties["puzzle_environment_name"]
	PlayerData.customer_queue.pop_standard_customers(CurrentLevel.get_creature_ids())
