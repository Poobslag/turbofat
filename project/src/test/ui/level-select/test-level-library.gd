extends "res://addons/gut/test.gd"

const LEVEL_NONE := LevelLock.STATUS_NONE
const LEVEL_KEY := LevelLock.STATUS_KEY
const LEVEL_CROWN := LevelLock.STATUS_CROWN
const LEVEL_CLEARED := LevelLock.STATUS_CLEARED
const LEVEL_SOFT_LOCK := LevelLock.STATUS_SOFT_LOCK
const LEVEL_HARD_LOCK := LevelLock.STATUS_HARD_LOCK

const WORLD_NONE := WorldLock.STATUS_NONE
const WORLD_LOCK := WorldLock.STATUS_LOCK

func before_each() -> void:
	PlayerData.level_history.reset()
	LevelLibrary.refresh_cleared_levels()


func after_each() -> void:
	LevelLibrary.worlds_path = LevelLibrary.DEFAULT_WORLDS_PATH


func add_level_history_item(level_id: String, cleared: bool = true) -> void:
	var result := RankResult.new()
	result.lost = not cleared
	PlayerData.level_history.add_result(level_id, result)


func assert_level_lock_status(level_id: String, expected_status: int) -> void:
	var expected_str: String = LevelLock.LockStatus.keys()[expected_status]
	var actual_str: String = LevelLock.LockStatus.keys()[LevelLibrary.level_lock(level_id).status]
	assert_eq(actual_str, expected_str)


func assert_world_lock_status(world_id: String, expected_status: int) -> void:
	var expected_str: String = WorldLock.LockStatus.keys()[expected_status]
	var actual_str: String = WorldLock.LockStatus.keys()[LevelLibrary.world_lock(world_id).status]
	assert_eq(actual_str, expected_str)


func test_level_lock_group_finished() -> void:
	# this level has a 'group_finished' condition
	var level_id := "marsh/pulling_for_everyone"
	
	# by default, the level is hard locked because enough keys aren't available
	assert_level_lock_status(level_id, LEVEL_HARD_LOCK)
	
	# once enough keys are available, the level becomes soft locked
	add_level_history_item("marsh/hello_everyone")
	LevelLibrary.refresh_cleared_levels()
	assert_level_lock_status(level_id, LEVEL_SOFT_LOCK)
	assert_eq(LevelLibrary.level_lock(level_id).keys_needed, 2)
	
	# these three levels are required to unlock it
	assert_level_lock_status("marsh/hello_bones", LEVEL_KEY)
	assert_level_lock_status("marsh/hello_shirts", LEVEL_KEY)
	assert_level_lock_status("marsh/hello_skins", LEVEL_KEY)
	
	# if only one level is cleared, the level remains locked
	add_level_history_item("marsh/hello_bones")
	LevelLibrary.refresh_cleared_levels()
	assert_level_lock_status(level_id, LEVEL_SOFT_LOCK)
	assert_eq(LevelLibrary.level_lock(level_id).keys_needed, 1)
	
	# once the last required level is cleared, the level unlocks
	add_level_history_item("marsh/hello_shirts")
	LevelLibrary.refresh_cleared_levels()
	assert_level_lock_status(level_id, LEVEL_KEY)


func test_level_lock_level_finished() -> void:
	# this level has a 'level_finished' condition
	var level_id := "marsh/hello_bones"
	
	# by default, the level is soft locked
	assert_level_lock_status(level_id, LEVEL_SOFT_LOCK)
	
	# once the prerequisite level is cleared, the level unlocks
	add_level_history_item("marsh/hello_everyone")
	LevelLibrary.refresh_cleared_levels()
	assert_level_lock_status(level_id, LEVEL_KEY)


func test_level_lock_crown() -> void:
	# this level is the last in its world
	var level_id := "marsh/goodbye_everyone"
	
	assert_level_lock_status(level_id, LEVEL_HARD_LOCK)
	
	# once the required levels are cleared, the level changes to a crown
	add_level_history_item("marsh/goodbye_bones")
	add_level_history_item("marsh/goodbye_shirts")
	add_level_history_item("marsh/goodbye_skins")
	LevelLibrary.refresh_cleared_levels()
	assert_level_lock_status(level_id, LEVEL_CROWN)
	
	# once cleared, the level does not have a key/crown/lock anymore
	add_level_history_item(level_id)
	LevelLibrary.refresh_cleared_levels()
	assert_level_lock_status(level_id, LEVEL_NONE)


func test_level_lock_level_cleared() -> void:
	# this is a regular level
	var level_id := "marsh/hello_everyone"
	
	assert_level_lock_status(level_id, LEVEL_KEY)
	
	# once cleared, the level does not have a key/crown/lock anymore
	add_level_history_item(level_id)
	LevelLibrary.refresh_cleared_levels()
	assert_level_lock_status(level_id, LEVEL_NONE)


func test_level_lock_tutorial_cleared() -> void:
	# this level is a tutorial, we do not track the player's scores
	var level_id := "tutorial/basics_0"
	
	assert_level_lock_status(level_id, LEVEL_NONE)
	
	# once cleared, a tutorial has a checkmark
	add_level_history_item(level_id)
	LevelLibrary.refresh_cleared_levels()
	assert_level_lock_status(level_id, LEVEL_CLEARED)


func test_world_lock() -> void:
	# this world has a 'world_finished' condition
	var world_id := "world1"
	
	# by default, the world is locked
	assert_world_lock_status(world_id, WORLD_LOCK)
	
	# once the last level in the prerequisite world is cleared, the level unlocks
	add_level_history_item("marsh/goodbye_everyone")
	LevelLibrary.refresh_cleared_levels()
	assert_world_lock_status(world_id, WORLD_NONE)


func test_next_creature_level() -> void:
	# by default, the creature has no level available
	assert_eq(LevelLibrary.next_creature_level("bones"), "")
	
	# once the prerequisite level is cleared, the creature has a level available
	add_level_history_item("marsh/hello_everyone")
	LevelLibrary.refresh_cleared_levels()
	assert_eq(LevelLibrary.next_creature_level("bones"), "marsh/hello_bones")
	
	# if multiple levels are available, the earliest prioritized level is returned
	add_level_history_item("marsh/pulling_for_everyone")
	add_level_history_item("marsh/hello_bones")
	LevelLibrary.refresh_cleared_levels()
	assert_eq(LevelLibrary.next_creature_level("bones"), "marsh/pulling_for_bones")


func test_next_creature_level_prioritized() -> void:
	LevelLibrary.worlds_path = "res://assets/test/ui/level-select/worlds-priority.json"

	# if any levels are prioritized, the next prioritized level is selected
	assert_eq(LevelLibrary.next_creature_level("bones"), "marsh/pulling_for_bones")
