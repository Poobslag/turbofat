class_name WorldLock
"""
Keeps track of whether a world is unlocked, and the requirements to unlock it.
"""

# the requirements to unlock a world
enum UnlockedIf {
	ALWAYS_UNLOCKED, # never locked
	IF_WORLD_FINISHED, # unlocked if the player finishes a specific world(s)
}

# the status whether or not a world is locked/unlocked
enum LockStatus {
	NONE, # not locked
	LOCK, # locked
}

const ALWAYS_UNLOCKED := UnlockedIf.ALWAYS_UNLOCKED
const IF_WORLD_FINISHED := UnlockedIf.IF_WORLD_FINISHED

const STATUS_NONE := LockStatus.NONE
const STATUS_LOCK := LockStatus.LOCK

var world_id: String
var world_name: String
var prologue_chat_key: String
var epilogue_chat_key: String

# the requirements to unlock this level
var unlocked_if_type := ALWAYS_UNLOCKED

# The final level in the world. Finishing this level counts as finishing the entire world.
var last_level: String

"""
An array of strings representing unlock criteria.

For IF_WORLD_FINISHED locks, this is an array of world IDs.
"""
var unlocked_if_values := []

var level_ids: Array

# the status whether or not this level is locked/unlocked
var status := STATUS_NONE

func from_json_dict(json: Dictionary) -> void:
	world_id = json.get("id", "")
	world_name = json.get("name", "")
	last_level = json.get("last_level", "")
	prologue_chat_key = json.get("prologue_chat_key", "")
	epilogue_chat_key = json.get("epilogue_chat_key", "")
	
	var levels: Array = json.get("levels", [])
	if levels:
		for level_obj in levels:
			var level: Dictionary = level_obj
			level_ids.append(level["id"])
	
	var unlocked_if_string: String = json.get("unlocked_if", "")
	if unlocked_if_string:
		var unlocked_if_array: Array = unlocked_if_string.split(" ")
		match unlocked_if_array[0]:
			"world_finished": unlocked_if_type = IF_WORLD_FINISHED
			_: push_warning("Unrecognized unlocked_if: %s" % [unlocked_if_string])
		unlocked_if_values = unlocked_if_array.slice(1, unlocked_if_array.size() - 1)
