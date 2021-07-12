extends Node
"""
Maintains a queue of pending cutscenes.

When the game plays cutscenes, it plays one or more cutscenes and sometimes plays a level or returns to a different
overworld scene. This script maintains a queue of the pending cutscenes and levels.
"""

# List of positions the sensei should spawn following a cutscene where the sensei was absent.
#
# In most cutscenes, the player and sensei will spawn at their position in the cutscene. For cutscenes where the sensei
# was absent, we spawn them near the player. This dictionary contains a list of those spawn locations keyed by the
# player's location in the cutscene, in the format '<location_id>/<spawn_id>'
const SENSEI_SPAWN_IDS_BY_PLAYER_LOCATION := {
	"outdoors/restaurant-1": "restaurant-11",
	"outdoors/restaurant-4": "restaurant-11",
	"outdoors/restaurant-8": "restaurant-1",
	"outdoors/restaurant-11": "restaurant-1",
	
	"indoors/kitchen-1": "kitchen-7",
	"indoors/kitchen-3": "kitchen-7",
	"indoors/kitchen-5": "kitchen-7",
	"indoors/kitchen-7": "kitchen-5",
	"indoors/kitchen-9": "kitchen-5",
	"indoors/kitchen-11": "kitchen-5",
}

# Queue of ChatTree and String instances. ChatTrees represent cutscenes, and strings represent level IDs.
var _queue := []

"""
Adds a cutscene to the back of the queue.
"""
func enqueue_chat_tree(chat_tree: ChatTree) -> void:
	_queue.push_back(chat_tree)


"""
Adds a level to the back of the queue.
"""
func enqueue_level(level_id: String) -> void:
	_queue.push_back(level_id)


"""
Returns 'true' if the first item in the queue represents a cutscene.
"""
func is_front_chat_tree() -> bool:
	return _queue and _queue.front() is ChatTree


"""
Returns 'true' if the first item in the queue represents a level.
"""
func is_front_level_id() -> bool:
	return _queue and _queue.front() is String


"""
Removes and returns the cutscene at the front of the queue.
"""
func pop_chat_tree() -> ChatTree:
	return _queue.pop_front() as ChatTree


"""
Removes and returns the level at the front of the queue.
"""
func pop_level_id() -> String:
	return _queue.pop_front() as String


"""
Transitions to the cutscene at the front of the queue, staying at the current level in the breadcrumb trail.
"""
func replace_cutscene_trail() -> void:
	if not is_front_chat_tree():
		push_error("CutsceneManager._queue.front (%s) is not a cutscene" % [_queue.front()])
		return
	
	var chat_tree: ChatTree = _queue.front()
	SceneTransition.replace_trail(chat_tree.cutscene_scene_path())


"""
Transitions to the cutscene at the front of the queue, extending the breadcrumb trail.
"""
func push_cutscene_trail() -> void:
	if not is_front_chat_tree():
		push_error("CutsceneManager._queue.front (%s) is not a cutscene" % [_queue.front()])
		return
	
	var chat_tree: ChatTree = _queue.front()
	SceneTransition.push_trail(chat_tree.cutscene_scene_path())


"""
Transitions to the level at the front of the queue, extending the breadcrumb trail.
"""
func push_level_trail() -> void:
	if not is_front_level_id():
		push_error("CutsceneManager._queue.front (%s) is not a level id" % [_queue.front()])
		return
	
	CurrentLevel.level_id = _queue.front()
	CurrentLevel.push_level_trail()


"""
Assign the player and sensei spawn IDs based on the specified chat tree.

This makes it so they'll spawn in appopriate positions after the cutscene is over.
"""
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
