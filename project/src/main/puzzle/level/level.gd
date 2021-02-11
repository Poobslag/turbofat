extends Node
"""
Loads levels from files.

Levels are stored as a set of json resources. This class parses those json resources into LevelSettings so they
can be used by the puzzle code.

This class needs to be a node because it provides utility methods which utilize the scene tree.
"""

# emitted after the level has customized the puzzle's settings.
signal settings_changed

# emitted when the 'level_state' field changes, such as when starting or clearing a level.
signal level_state_changed

enum LevelState {
	NONE, # the level hasn't been launched
	BEFORE, # the level has been launched, but the hasn't yet been finished successfully
	AFTER # the level has been finished successfully. The player didn't lose or give up
}

# The mandatory tutorial the player must complete before playing the game
const BEGINNER_TUTORIAL := "tutorial/basics_0"
const TUTORIAL_WORLD_ID := "tutorial"

# If 'true' then the level is one which the player might keep retrying, even after clearing it.
# This is especially true for practice levels such as the 3 minute sprint level.
var keep_retrying := false

# The settings for the level currently being launched or played
var settings := LevelSettings.new() setget switch_level

# The level which was originally launched. Some tutorial levels transition
# into other levels, so this keeps track of the original.
var launched_level_id: String

# The creature who launched the level.
var launched_creature_id: String

# The customers to queue up at the start of the level. If absent, random customers will be queued.
var launched_customer_ids: Array

# The creature who will be the chef for the level. If absent, the player will be the chef.
var launched_chef_id: String

# Tracks whether or not the player has started or cleared the level.
var level_state: int = LevelState.NONE setget set_level_state

"""
Unsets all of the 'launched level' data.

This ensures the overworld will allow free roam and not try to play a cutscene.
"""
func clear_launched_level() -> void:
	set_launched_level("")


"""
Sets the launched level data.

Some tutorial levels transition into other levels, so this keeps track of the original. These properties also
used on the overworld to track whether or not it should play a cutscene or allow free roam.

Parameters:
	'level_id': The level to launch
"""
func set_launched_level(level_id: String) -> void:
	launched_level_id = level_id
	var level_lock: LevelLock
	if level_id:
		level_lock = LevelLibrary.level_lock(level_id)
	
	if level_lock:
		set_level_state(LevelState.BEFORE)
		launched_creature_id = level_lock.creature_id
		launched_customer_ids = level_lock.customer_ids
		launched_chef_id = level_lock.chef_id
	else:
		set_level_state(LevelState.NONE)
		launched_creature_id = ""
		launched_customer_ids = []
		launched_chef_id = ""


func start_level(new_settings: LevelSettings) -> void:
	launched_level_id = new_settings.id
	PuzzleScore.reset()
	switch_level(new_settings)


func switch_level(new_settings: LevelSettings) -> void:
	settings = new_settings
	emit_signal("settings_changed")


"""
Launches a cutscene for the previously specified 'launched level' settings.

A 'cutscene' is a set of dialog and actions, which sometimes need to take place at a specific location. By default,
the cutscene will only be launched if the level's dialog specifies a location_id, because it's otherwise assumed that
the level's dialog could just take place wherever the player is currently standing. However, the cutscene can be forced
to activate with the optional 'force' parameter.

Parameters:
	'force': (Optional) If true, the cutscene will play even if it does not specify a location_id

Returns:
	'true' if the cutscene was launched, or 'false' if the cutscene was not found or did not specify a location id
"""
func push_cutscene_trail(force: bool = false) -> bool:
	if not launched_creature_id:
		return false
	
	var result := false
	var chat_tree: ChatTree = ChatLibrary.chat_tree_for_creature_id(launched_creature_id, launched_level_id)
	if chat_tree and (chat_tree.location_id or force):
		Breadcrumb.push_trail(chat_tree.cutscene_scene_path())
		result = true
	
	return result


"""
Launches a puzzle scene with the previously specified 'launched level' settings.
"""
func push_level_trail() -> void:
	var level_settings := LevelSettings.new()
	level_settings.load_from_resource(launched_level_id)
	
	# When the player first launches the game and does the tutorial, we skip the typical puzzle intro.
	if launched_level_id == Level.BEGINNER_TUTORIAL \
			and not PlayerData.level_history.finished_levels.has(Level.BEGINNER_TUTORIAL):
		level_settings.other.skip_intro = true
	
	start_level(level_settings)
	for launched_customer_id_obj in launched_customer_ids:
		var launched_customer_id: String = launched_customer_id_obj
		var creature_def: CreatureDef = PlayerData.creature_library.get_creature_def(launched_customer_id)
		PlayerData.creature_queue.primary_queue.push_front(creature_def)
	Breadcrumb.push_trail(Global.SCENE_PUZZLE)


func set_level_state(new_level_state: int) -> void:
	level_state = new_level_state
	emit_signal("level_state_changed")
