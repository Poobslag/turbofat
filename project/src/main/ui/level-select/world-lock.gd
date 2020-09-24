class_name WorldLock
"""
Keeps track of whether a world is unlocked, and the requirements to unlock it.
"""

# the requirements to unlock a world
enum LockedUntil {
	ALWAYS_UNLOCKED, # never locked
	UNTIL_WORLD_FINISHED, # locked until the player finishes a specific world(s)
}

# the status whether or not a world is locked/unlocked
enum LockStatus {
	NONE, # not locked
	LOCK, # locked
}

const ALWAYS_UNLOCKED := LockedUntil.ALWAYS_UNLOCKED
const UNTIL_WORLD_FINISHED := LockedUntil.UNTIL_WORLD_FINISHED

const STATUS_NONE := LockStatus.NONE
const STATUS_LOCK := LockStatus.LOCK

var world_id: String
var world_name: String

# the requirements to unlock this level
var locked_until_type := ALWAYS_UNLOCKED

# The final level in the world. Finishing this level counts as finishing the entire world.
var last_level: String

"""
An array of strings representing unlock criteria.

For UNTIL_WORLD_FINISHED locks, this is an array of world IDs.
"""
var locked_until_values := []

var level_ids: Array

# the status whether or not this level is locked/unlocked
var status := STATUS_NONE

func from_json_dict(json: Dictionary) -> void:
	world_id = json.get("id", "")
	world_name = json.get("name", "")
	last_level = json.get("last_level", "")
	
	var levels: Array = json.get("levels", [])
	if levels:
		for level_obj in levels:
			var level: Dictionary = level_obj
			level_ids.append(level["id"])
	
	var locked_until_string: String = json.get("locked_until", "")
	if locked_until_string:
		var locked_until_array: Array = locked_until_string.split(" ")
		match locked_until_array[0]:
			"world_finished": locked_until_type = UNTIL_WORLD_FINISHED
			_: push_warning("Unrecognized locked_until: %s" % [locked_until_string])
		locked_until_values = locked_until_array.slice(1, locked_until_array.size() - 1)
