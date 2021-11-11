class_name LevelLock
## Keeps track of whether a level is unlocked, and the requirements to unlock it.

## the requirements to unlock a level
enum UnlockedIf {
	ALWAYS_UNLOCKED, # never locked
	IF_LEVEL_FINISHED, # unlocked if the player finishes a specific level(s)
	IF_GROUP_FINISHED, # unlocked if the player finishes some levels in a group
}

## the status whether or not a level is locked/unlocked
enum LockStatus {
	NONE, # not locked
	CLEARED, # cleared without any rank; used for tutorials
	KEY, # not locked, and can unlock another level
	CROWN, # not locked, and can unlock another world
	SOFT_LOCK, # locked, but the player can unlock it by clearing more levels
	HARD_LOCK, # locked, and the required levels to unlock it are themselves locked
}

const ALWAYS_UNLOCKED := UnlockedIf.ALWAYS_UNLOCKED
const IF_LEVEL_FINISHED := UnlockedIf.IF_LEVEL_FINISHED
const IF_GROUP_FINISHED := UnlockedIf.IF_GROUP_FINISHED

const STATUS_NONE := LockStatus.NONE
const STATUS_KEY := LockStatus.KEY
const STATUS_CROWN := LockStatus.CROWN
const STATUS_CLEARED := LockStatus.CLEARED
const STATUS_SOFT_LOCK := LockStatus.SOFT_LOCK
const STATUS_HARD_LOCK := LockStatus.HARD_LOCK

var level_id: String

## Some levels activate chat sequences. This field specifies which character's chat should activate.
var creature_id: String

## Some levels involve specific customers or a specific chef.
var customer_ids: Array
var chef_id: String

## the requirements to unlock this level
var unlocked_if_type := ALWAYS_UNLOCKED

## An array of strings representing unlock criteria.
##
## For IF_LEVEL_FINISHED locks, this is an array of level IDs.
## For IF_GROUP_FINISHED locks, this is a group ID and (optionally) a number of levels which can be skipped.
var unlocked_if_values := []

## the condition required to make this level high priority
var prioritized_if: String

## the status whether or not this level is locked/unlocked
var status := STATUS_NONE

## the number of remaining levels the player needs to play to unlock this level
var keys_needed := -1

## array of string group IDs for groups this level belongs to
var groups := []

func from_json_dict(json: Dictionary) -> void:
	level_id = json.get("id", "")
	creature_id = json.get("creature_id", "")
	chef_id = json.get("chef_id", "")
	customer_ids = json.get("customer_ids", [])
	
	var unlocked_if_string: String = json.get("unlocked_if", "")
	if unlocked_if_string:
		var unlocked_if_array: Array = unlocked_if_string.split(" ")
		match unlocked_if_array[0]:
			"level_finished": unlocked_if_type = IF_LEVEL_FINISHED
			"group_finished": unlocked_if_type = IF_GROUP_FINISHED
			_: push_warning("Unrecognized unlocked_if: %s" % [unlocked_if_string])
		unlocked_if_values = unlocked_if_array.slice(1, unlocked_if_array.size() - 1)
	
	prioritized_if = json.get("prioritized_if", "")
	
	var groups_string: String = json.get("groups", "")
	if groups_string:
		groups = groups_string.split(" ")


func is_locked() -> bool:
	return status in [STATUS_SOFT_LOCK, STATUS_HARD_LOCK]
