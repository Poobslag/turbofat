class_name WorldLocks
"""
Keeps tracks of which levels unlock other levels.

This is used to determine if a player can play a level, and to communicate this information to the player with
descriptive messages like 'Clear four more levels to unlock this!'
"""

# Ordered list of all level IDs
var level_ids: Array

# Tracks the unlock requirements for the different levels
#
# key: level id
# value: LevelLock instance
var level_locks: Dictionary

# Tracks which levels are in each group
#
# key: group id
# value: dictionary whose keys are level IDs in the group
var _level_groups: Dictionary

"""
Loads the list of levels from JSON, and parses it to figure out which levels are locked.
"""
func initialize() -> void:
	_load_raw_json_data()
	_update_locked_levels()
	_update_unlockable_levels()


"""
Returns true if the level cannot be played, because it is locked.
"""
func is_locked(scenario_id: String) -> bool:
	return level_locks[scenario_id].status in [LevelLock.STATUS_SOFT_LOCK, LevelLock.STATUS_HARD_LOCK]


"""
Loads the list of levels from JSON.
"""
func _load_raw_json_data() -> void:
	var worlds_text := FileUtils.get_file_as_text("res://assets/main/puzzle/worlds.json")
	var worlds_json: Dictionary = parse_json(worlds_text)
	
	var worlds_array: Array = worlds_json.get("worlds", [])
	for world_obj in worlds_array:
		var world: Dictionary = world_obj
		var levels_array: Array = world.get("levels", [])
		for level_obj in levels_array:
			var level: Dictionary = level_obj
			var level_lock := LevelLock.new()
			level_lock.from_json_dict(level)
			
			level_ids.append(level_lock.scenario_id)
			level_locks[level_lock.scenario_id] = level_lock
			
			for group_id in level_lock.groups:
				if not _level_groups.has(group_id):
					_level_groups[group_id] = {}
				_level_groups[group_id][level_lock.scenario_id] = true


"""
Update the lock status to 'hard lock' for locked levels.
"""
func _update_locked_levels() -> void:
	for level_lock_obj in level_locks.values():
		var level_lock: LevelLock = level_lock_obj
		if level_lock.locked_until_type == LevelLock.ALWAYS_UNLOCKED:
			continue
		
		var unlock_level_ids := _unlock_level_ids(level_lock)
		var allowed_skips := _allowed_skips(level_lock)
		var skip_count := 0
		for unlock_level_id in unlock_level_ids:
			if not PlayerData.scenario_history.finished_scenarios.has(unlock_level_id):
				skip_count += 1
		if skip_count > allowed_skips:
			level_lock.status = LevelLock.STATUS_HARD_LOCK
			level_lock.keys_needed = skip_count - allowed_skips


"""
Returns the list of level IDs which contribute to unlocking this level.
"""
func _unlock_level_ids(level_lock: LevelLock) -> Array:
	var unlock_level_ids := []
	if level_lock.locked_until_type == LevelLock.UNTIL_LEVEL_FINISHED:
		unlock_level_ids = level_lock.locked_until_value
	elif level_lock.locked_until_type == LevelLock.UNTIL_GROUP_FINISHED:
		var group_id: String = level_lock.locked_until_value[0]
		unlock_level_ids = _level_groups.get(group_id, {}).keys()
	return unlock_level_ids


"""
Returns the number of skips which are allowed when unlocking this level.

A level may have fifteen levels which unlock it, but the player only needs to clear ten of them. This would be
represented as allowing 'five skips'.
"""
func _allowed_skips(level_lock: LevelLock) -> int:
	var allowed_skips := 0
	if level_lock.locked_until_type == LevelLock.UNTIL_GROUP_FINISHED:
		if level_lock.locked_until_value.size() >= 2:
			allowed_skips = int(level_lock.locked_until_value[1])
	return allowed_skips


"""
Update the lock status to 'soft lock' for unlockable levels
"""
func _update_unlockable_levels() -> void:
	for level_lock_obj in level_locks.values():
		var level_lock: LevelLock = level_lock_obj
		if level_lock.status != LevelLock.STATUS_HARD_LOCK:
			continue
		
		# calculate the number of available, uncollected keys
		var available_key_ids := []
		var unlock_level_ids := _unlock_level_ids(level_lock)
		for unlock_level_id in unlock_level_ids:
			var other_level_lock: LevelLock = level_locks[unlock_level_id]
			if PlayerData.scenario_history.finished_scenarios.has(other_level_lock.scenario_id):
				# key already collected
				continue
			if is_locked(unlock_level_id):
				# level is locked
				continue
			available_key_ids.append(unlock_level_id)
		
		# if there's enough keys available to unlock the level, update its status to 'soft lock'
		if available_key_ids.size() >= level_lock.keys_needed:
			level_lock.status = LevelLock.STATUS_SOFT_LOCK
			
			# and, update all the levels which can unlock it to 'key' status
			for unlock_level_id in available_key_ids:
				var other_level_lock: LevelLock = level_locks[unlock_level_id]
				if other_level_lock.status == LevelLock.STATUS_NONE:
					other_level_lock.status = LevelLock.STATUS_KEY
