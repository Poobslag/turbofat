extends Node
## Maintains a queue of pending cutscenes and levels.
##
## When the game plays cutscenes, it plays one or more cutscenes and sometimes plays a level or returns to a different
## overworld scene. This script maintains a queue of the pending cutscenes and levels.

## List of positions the sensei should spawn following a cutscene where the sensei was absent.
##
## In most cutscenes, the player and sensei will spawn at their position in the cutscene. For cutscenes where the
## sensei was absent, we spawn them near the player. This dictionary contains a list of those spawn locations keyed by
## the player's location in the cutscene, in the format '<location_id>/<spawn_id>'
const SENSEI_SPAWN_IDS_BY_PLAYER_LOCATION := {
	"marsh/restaurant_1": "restaurant_11",
	"marsh/restaurant_4": "restaurant_11",
	"marsh/restaurant_8": "restaurant_1",
	"marsh/restaurant_11": "restaurant_1",
	
	"marsh/inside_turbo_fat/kitchen_1": "kitchen_7",
	"marsh/inside_turbo_fat/kitchen_3": "kitchen_7",
	"marsh/inside_turbo_fat/kitchen_5": "kitchen_7",
	"marsh/inside_turbo_fat/kitchen_7": "kitchen_5",
	"marsh/inside_turbo_fat/kitchen_9": "kitchen_5",
	"marsh/inside_turbo_fat/kitchen_11": "kitchen_5",
}

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
	_queue.push_back({
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
	_queue.push_back({
		"type": "level",
		"value": level_properties
	})


## Returns 'true' if there is a pending cutscene/level in the queue.
func is_queue_empty() -> bool:
	return _queue.empty()


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
	if level_properties.has("cutscene_force"):
		CurrentLevel.cutscene_force = level_properties["cutscene_force"]
	if level_properties.has("puzzle_environment_name"):
		CurrentLevel.puzzle_environment_name = level_properties["puzzle_environment_name"]
	PlayerData.creature_queue.pop_secondary_creatures(CurrentLevel.get_creature_ids())


## Assign the player and sensei spawn IDs based on the specified chat tree.
##
## This makes it so they'll spawn in appopriate positions after the cutscene is over.
func assign_player_spawn_ids(chat_tree: ChatTree) -> void:
	PlayerData.free_roam.player_spawn_id = ""
	PlayerData.free_roam.sensei_spawn_id = ""
	
	for creature_id in chat_tree.spawn_locations:
		if creature_id == CreatureLibrary.PLAYER_ID:
			PlayerData.free_roam.player_spawn_id = chat_tree.spawn_locations[creature_id]
		elif creature_id == CreatureLibrary.SENSEI_ID:
			PlayerData.free_roam.sensei_spawn_id = chat_tree.spawn_locations[creature_id]
	
	# if the player wasn't in the cutscene (?!) unset the spawn ids
	if PlayerData.free_roam.sensei_spawn_id and not PlayerData.free_roam.player_spawn_id:
		PlayerData.free_roam.sensei_spawn_id = ""
	
	# if the sensei wasn't in the cutscene, move them near the player
	if PlayerData.free_roam.player_spawn_id and not PlayerData.free_roam.sensei_spawn_id:
		var player_location_key := "%s/%s" % [chat_tree.location_id, PlayerData.free_roam.player_spawn_id]
		PlayerData.free_roam.sensei_spawn_id = SENSEI_SPAWN_IDS_BY_PLAYER_LOCATION.get(player_location_key)
		if not PlayerData.free_roam.sensei_spawn_id:
			push_warning("SENSEI_SPAWN_IDS_BY_PLAYER_SPAWN_ID did not have an entry for '%s'"
					% [PlayerData.free_roam.player_spawn_id])
