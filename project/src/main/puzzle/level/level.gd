extends Node
"""
Loads levels from files.

Levels are stored as a set of json resources. This class parses those json resources into LevelSettings so they
can be used by the puzzle code.

This class needs to be a node because it provides utility methods which utilize the scene tree.
"""

# emitted after the level has customized the puzzle's settings.
signal settings_changed

# The mandatory tutorial the player must complete before playing the game
const BEGINNER_TUTORIAL := "tutorial_basics_0"
const TUTORIAL_WORLD_ID := "tutorial"

# The settings for the level currently being launched or played
var settings := LevelSettings.new() setget switch_level

# The level which was originally launched. Some tutorial levels transition
# into other levels, so this keeps track of the original.
var launched_level_id: String

# The creature who launched the level. This creature is always the first customer.
var launched_creature_id: String

# The number of the creature's launched level, '1' being their first level.
var launched_level_num: int = -1

"""
Unsets all of the 'launched level' data.

This ensures the overworld will allow free roam and not try to play a cutscene.
"""
func clear_launched_level() -> void:
	set_launched_level("", "", -1)


"""
Sets the launched level data.

Some tutorial levels transition into other levels, so this keeps track of the original. These properties also
used on the overworld to track whether or not it should play a cutscene or allow free roam.

Parameters:
	'level_id': The level to launch
	
	'creature_id': The creature who shows up in the level or participates in the cutscene.
	
	'level_num': The number of the creature's launched level, '1' being their first level.
"""
func set_launched_level(level_id: String, creature_id: String = "", level_num: int = -1) -> void:
	launched_level_id = level_id
	launched_creature_id = creature_id
	launched_level_num = level_num


func start_level(new_settings: LevelSettings) -> void:
	launched_level_id = new_settings.id
	PuzzleScore.reset()
	switch_level(new_settings)


func switch_level(new_settings: LevelSettings) -> void:
	settings = new_settings
	emit_signal("settings_changed")


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
	if Level.launched_creature_id:
		var creature_def := CreatureLoader.load_creature_def_by_id(Level.launched_creature_id)
		PlayerData.creature_queue.primary_queue.push_front(creature_def)
	Breadcrumb.push_trail(Global.SCENE_PUZZLE)
