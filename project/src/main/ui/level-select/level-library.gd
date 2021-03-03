extends Node
"""
Manages data for all levels in the game. This includes their rules, unlock criteria, and whether the player's unlocked
them yet.

Levels are stored as json resources. This class parses those json resources into LevelSettings so they can be used by
the puzzle code.
"""

# The mandatory tutorial the player must complete before playing the game
const BEGINNER_TUTORIAL := "tutorial/basics_0"
const TUTORIAL_WORLD_ID := "tutorial"

# Ordered list of all world IDs
var world_ids: Array

# key: group id
# value: level IDs belonging to the group
var _level_groups: Dictionary

# key: level id
# value: LevelLock with the specified id
var _level_locks: Dictionary

# ley: level id
# value: LevelSettings for the specified level
var _level_settings_by_id: Dictionary

# key: world id
# value: WorldLock with the specified id
var _world_locks: Dictionary

# key: level id
# value: WorldLock containing the specified level
var _world_locks_by_level_id: Dictionary

"""
Loads the list of levels from JSON, processing it to determine which levels are locked.
"""
func _ready() -> void:
	_load_raw_json_data()
	refresh_cleared_levels()
	PlayerData.connect("level_history_changed", self, "_on_PlayerData_level_history_changed")


"""
Recalculates which worlds and levels are available to the player and how to unlock them.
"""
func refresh_cleared_levels() -> void:
	_reset_cleared_worlds_and_levels()
	_update_locked_worlds()
	_update_locked_levels()
	_update_unlockable_levels()
	_update_cleared_tutorials()


func is_locked(level_id: String) -> bool:
	return _level_locks.get(level_id).is_locked() if _level_locks.has(level_id) else false


func world_lock(world_id: String) -> WorldLock:
	return _world_locks.get(world_id)


func world_lock_for_level(level_id: String) -> WorldLock:
	return _world_locks_by_level_id.get(level_id)


func level_lock(level_id: String) -> LevelLock:
	return _level_locks.get(level_id)


func level_settings(level_id: String) -> LevelSettings:
	return _level_settings_by_id.get(level_id)


"""
Returns the first unfinished, unlocked level id for a creature.

This is the level which will be played if the player talks to them on the overworld. Finished levels can be played
through the cell phone. Locked levels cannot be played; they must be unlocked first.
"""
func first_unfinished_level_id_for_creature(creature_id: String) -> String:
	for world_lock_obj in _world_locks.values():
		var world_lock: WorldLock = world_lock_obj
		for level_id in world_lock.level_ids:
			var level_lock: LevelLock = _level_locks[level_id]
			if level_lock.creature_id == creature_id and not level_lock.is_locked() \
					and not PlayerData.level_history.finished_levels.has(level_lock.level_id):
				return level_lock.level_id
	
	return ""


"""
Returns a list of IDs for levels shown to the player.

Many levels are hidden from the player at the beginning of the game. They become visible as the player progresses.
"""
func shown_level_ids(world_id: String) -> Array:
	var shown_level_ids := []
	for level_id in world_lock(world_id).level_ids:
		var level_lock: LevelLock =  _level_locks[level_id]
		if level_lock.status != LevelLock.STATUS_HARD_LOCK:
			shown_level_ids.append(level_id)
	return shown_level_ids


func all_level_ids() -> Array:
	var all_level_ids := []
	for world_id in world_ids:
		for level_id in world_lock(world_id).level_ids:
			all_level_ids.append(level_id)
	return all_level_ids


"""
Loads the list of levels from JSON.
"""
func _load_raw_json_data() -> void:
	var worlds_text := FileUtils.get_file_as_text("res://assets/main/puzzle/worlds.json")
	var worlds_json: Dictionary = parse_json(worlds_text)
	
	# calculate included_worlds based on _levels_to_include
	var worlds_array: Array = worlds_json.get("worlds", [])
	
	# populate _world_locks, world_ids
	for world_obj in worlds_array:
		var world: Dictionary = world_obj
		var world_lock := WorldLock.new()
		world_lock.from_json_dict(world)
		world_ids.append(world_lock.world_id)
		_world_locks[world_lock.world_id] = world_lock
	
	# populate _world_locks_by_level_id
	for world_lock_obj in _world_locks.values():
		var world_lock: WorldLock = world_lock_obj
		for level_id in world_lock.level_ids:
			_world_locks_by_level_id[level_id] = world_lock
	
	# populate _level_locks, _level_settings_by_id
	for world_obj in worlds_array:
		var world: Dictionary = world_obj
		var levels_array: Array = world.get("levels", [])
		for level_obj in levels_array:
			var level: Dictionary = level_obj
			var level_lock := LevelLock.new()
			level_lock.from_json_dict(level)
			
			_level_locks[level_lock.level_id] = level_lock
			
			for group_id in level_lock.groups:
				if not _level_groups.has(group_id):
					_level_groups[group_id] = {}
				_level_groups[group_id][level_lock.level_id] = true
			
			var level_settings := LevelSettings.new()
			level_settings.load_from_resource(level_lock.level_id)
			_level_settings_by_id[level_lock.level_id] = level_settings


"""
Reset the world/level status to a default state so that it can be recalculated.

When worlds and levels are first loaded from JSON, they're in a clean state. We restore them to this clean state later
before recalculating the player's current status.
"""
func _reset_cleared_worlds_and_levels() -> void:
	# reset unlocked worlds
	for world_lock_obj in _world_locks.values():
		var world_lock: WorldLock = world_lock_obj
		var unlock_world_ids := world_lock.locked_until_values
		for unlock_world_id in unlock_world_ids:
			world_lock.status = WorldLock.STATUS_NONE
	
	# reset unlocked levels
	for level_lock_obj in _level_locks.values():
		var level_lock: LevelLock = level_lock_obj
		level_lock.status = LevelLock.STATUS_NONE
		level_lock.keys_needed = -1

"""
Update the world lock status to 'lock' for locked worlds.
"""
func _update_locked_worlds() -> void:
	for world_lock_obj in _world_locks.values():
		var world_lock: WorldLock = world_lock_obj
		if world_lock.locked_until_type == WorldLock.ALWAYS_UNLOCKED:
			continue
		
		var unlock_world_ids := world_lock.locked_until_values
		for unlock_world_id in unlock_world_ids:
			var other_world_lock: WorldLock = _world_locks[unlock_world_id]
			if not PlayerData.level_history.finished_levels.has(other_world_lock.last_level):
				world_lock.status = WorldLock.STATUS_LOCK


"""
Update the level lock status to 'hard lock' for locked levels.
"""
func _update_locked_levels() -> void:
	for level_lock_obj in _level_locks.values():
		var level_lock: LevelLock = level_lock_obj
		
		# if the world's locked, set the level status to 'hard lock'
		var world_lock: WorldLock = _world_locks_by_level_id[level_lock.level_id]
		if world_lock.status == WorldLock.STATUS_LOCK:
			level_lock.status = LevelLock.STATUS_HARD_LOCK
			continue
		
		# if the level's always unlocked, set the level status to 'unlocked'
		if level_lock.locked_until_type == LevelLock.ALWAYS_UNLOCKED:
			continue
		
		# set the level status to 'hard lock' if the required levels aren't cleared
		var unlock_level_ids := _unlock_level_ids(level_lock)
		var allowed_skips := _allowed_skips(level_lock)
		var skip_count := 0
		for unlock_level_id in unlock_level_ids:
			if not PlayerData.level_history.finished_levels.has(unlock_level_id):
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
		unlock_level_ids = level_lock.locked_until_values
	elif level_lock.locked_until_type == LevelLock.UNTIL_GROUP_FINISHED:
		var group_id: String = level_lock.locked_until_values[0]
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
		if level_lock.locked_until_values.size() >= 2:
			allowed_skips = int(level_lock.locked_until_values[1])
	return allowed_skips


"""
Update the lock status to 'soft lock' for unlockable levels
"""
func _update_unlockable_levels() -> void:
	# update levels with locks/keys
	for level_lock_obj in _level_locks.values():
		var level_lock: LevelLock = level_lock_obj
		
		# if the level's not locked, don't worry about unlocking the level
		if level_lock.status != LevelLock.STATUS_HARD_LOCK:
			continue
		
		# if the level's world is locked, don't worry about unlocking the level
		var world_lock: WorldLock = _world_locks_by_level_id[level_lock.level_id]
		if world_lock.status == WorldLock.STATUS_LOCK:
			continue
		
		# calculate the number of available, uncollected keys
		var available_key_ids := []
		var unlock_level_ids := _unlock_level_ids(level_lock)
		for unlock_level_id in unlock_level_ids:
			var other_level_lock: LevelLock = _level_locks[unlock_level_id]
			if PlayerData.level_history.finished_levels.has(other_level_lock.level_id):
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
				var other_level_lock: LevelLock = _level_locks[unlock_level_id]
				if other_level_lock.status == LevelLock.STATUS_NONE:
					other_level_lock.status = LevelLock.STATUS_KEY
	
	# update the final level in a world with a crown if it hasn't been beaten
	for world_lock_obj in _world_locks.values():
		var world_lock: WorldLock = world_lock_obj
		if not world_lock.last_level:
			# world doesn't have a last level
			continue
		if PlayerData.level_history.finished_levels.has(world_lock.last_level):
			# crown already collected
			continue
		if is_locked(world_lock.last_level):
			# level is locked
			continue
		_level_locks[world_lock.last_level].status = LevelLock.STATUS_CROWN


func _update_cleared_tutorials() -> void:
	# update cleared tutorials with a checkmark
	for level_lock_obj in _level_locks.values():
		var level_lock: LevelLock = level_lock_obj
		var level_settings: LevelSettings = _level_settings_by_id[level_lock.level_id]
		
		if level_lock.status == LevelLock.STATUS_NONE and level_settings.other.tutorial \
				and PlayerData.level_history.finished_levels.has(level_lock.level_id):
			level_lock.status = LevelLock.STATUS_CLEARED


func _on_PlayerData_level_history_changed() -> void:
	refresh_cleared_levels()
