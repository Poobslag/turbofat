extends Node
## Maintains a queue of pending cutscenes.
##
## When the game plays cutscenes, it plays one or more cutscenes and sometimes plays a level or returns to a different
## overworld scene. This script maintains a queue of the pending cutscenes and levels.

## List of positions the sensei should spawn following a cutscene where the sensei was absent.
#
## In most cutscenes, the player and sensei will spawn at their position in the cutscene. For cutscenes where the
## sensei was absent, we spawn them near the player. This dictionary contains a list of those spawn locations keyed by
## the player's location in the cutscene, in the format '<location_id>/<spawn_id>'
const SENSEI_SPAWN_IDS_BY_PLAYER_LOCATION := {
	"outdoors/restaurant_1": "restaurant_11",
	"outdoors/restaurant_4": "restaurant_11",
	"outdoors/restaurant_8": "restaurant_1",
	"outdoors/restaurant_11": "restaurant_1",
	
	"indoors/kitchen_1": "kitchen_7",
	"indoors/kitchen_3": "kitchen_7",
	"indoors/kitchen_5": "kitchen_7",
	"indoors/kitchen_7": "kitchen_5",
	"indoors/kitchen_9": "kitchen_5",
	"indoors/kitchen_11": "kitchen_5",
}

## Queue of ChatTree and String instances. ChatTrees represent cutscenes, and strings represent level IDs.
var _queue := []

func reset() -> void:
	_queue.clear()


## Adds a cutscene to the back of the queue.
func enqueue_cutscene(chat_tree: ChatTree) -> void:
	_queue.push_back(chat_tree)


## Inserts a cutscene in the given position in the queue.
func insert_cutscene(position: int, chat_tree: ChatTree) -> void:
	_queue.insert(position, chat_tree)


## Adds a level to the back of the queue.
func enqueue_level(level_id: String) -> void:
	_queue.push_back(level_id)


## Returns 'true' if the first item in the queue represents a cutscene.
func is_front_chat_tree() -> bool:
	return _queue and _queue.front() is ChatTree


## Returns 'true' if the first item in the queue represents a level.
func is_front_level_id() -> bool:
	return _queue and _queue.front() is String


## Removes and returns the cutscene at the front of the queue.
func pop_chat_tree() -> ChatTree:
	return _queue.pop_front() as ChatTree


## Removes and returns the level at the front of the queue.
func pop_level_id() -> String:
	return _queue.pop_front() as String


## Transitions to the cutscene at the front of the queue, staying at the current level in the breadcrumb trail.
func replace_cutscene_trail() -> void:
	if not is_front_chat_tree():
		push_error("CutsceneManager._queue.front (%s) is not a cutscene" % [_queue.front()])
		return
	
	var chat_tree: ChatTree = _queue.front()
	SceneTransition.replace_trail(chat_tree.chat_scene_path())


## Transitions to the cutscene at the front of the queue, extending the breadcrumb trail.
func push_cutscene_trail() -> void:
	if not is_front_chat_tree():
		push_error("CutsceneManager._queue.front (%s) is not a cutscene" % [_queue.front()])
		return
	
	var chat_tree: ChatTree = _queue.front()
	SceneTransition.push_trail(chat_tree.chat_scene_path())


## Transitions to the level at the front of the queue, extending the breadcrumb trail.
func push_level_trail() -> void:
	if not is_front_level_id():
		push_error("CutsceneManager._queue.front (%s) is not a level id" % [_queue.front()])
		return
	
	CurrentLevel.level_id = _queue.front()
	CurrentLevel.push_level_trail()


## Assign the player and sensei spawn IDs based on the specified chat tree.
##
## This makes it so they'll spawn in appopriate positions after the cutscene is over.
func assign_player_spawn_ids(chat_tree: ChatTree) -> void:
	Global.player_spawn_id = ""
	Global.sensei_spawn_id = ""
	
	for creature_id in chat_tree.spawn_locations:
		if creature_id == CreatureLibrary.PLAYER_ID:
			Global.player_spawn_id = chat_tree.spawn_locations[creature_id]
		elif creature_id == CreatureLibrary.SENSEI_ID:
			Global.sensei_spawn_id = chat_tree.spawn_locations[creature_id]
	
	# if the player wasn't in the cutscene (?!) unset the spawn ids
	if Global.sensei_spawn_id and not Global.player_spawn_id:
		Global.sensei_spawn_id = ""
	
	# if the sensei wasn't in the cutscene, move them near the player
	if Global.player_spawn_id and not Global.sensei_spawn_id:
		var player_location_key := "%s/%s" % [chat_tree.location_id, Global.player_spawn_id]
		Global.sensei_spawn_id = SENSEI_SPAWN_IDS_BY_PLAYER_LOCATION.get(player_location_key)
		if not Global.sensei_spawn_id:
			push_warning("SENSEI_SPAWN_IDS_BY_PLAYER_SPAWN_ID did not have an entry for '%s'" % [Global.player_spawn_id])
