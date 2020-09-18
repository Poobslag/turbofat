extends Node
"""
Loads scenarios from files.

Scenarios are stored as a set of json resources. This class parses those json resources into ScenarioSettings so they
can be used by the puzzle code.

This class needs to be a node because it provides utility methods which utilize the scene tree.
"""

# emitted after the scenario has customized the puzzle's settings.
signal settings_changed

# The mandatory tutorial the player must complete before playing the game
const BEGINNER_TUTORIAL := "tutorial_beginner_0"

# The settings for the scenario currently being launched or played
var settings := ScenarioSettings.new() setget switch_scenario

# The scenario which was originally launched. Some tutorial scenarios transition
# into other scenarios, so this keeps track of the original.
var launched_scenario_id: String

# The creature who launched the scenario. This creature is always the first customer.
var launched_creature_id: String

# The number of the creature's launched level, '1' being their first level.
var launched_level_num: int = -1

"""
Unsets all of the 'launched scenario' data.

This ensures the overworld will allow free roam and not try to play a cutscene.
"""
func clear_launched_scenario() -> void:
	set_launched_scenario("", "", -1)


"""
Sets the launched scenario data.

Some tutorial scenarios transition into other scenarios, so this keeps track of the original. These properties also
used on the overworld to track whether or not it should play a cutscene or allow free roam.

Parameters:
	'scenario_id': The scenario to launch
	
	'creature_id': The creature who shows up in the scenario or participates in the cutscene.
	
	'level_num': The number of the creature's launched level, '1' being their first level.
"""
func set_launched_scenario(scenario_id: String, creature_id: String = "", level_num: int = -1) -> void:
	launched_scenario_id = scenario_id
	launched_creature_id = creature_id
	launched_level_num = level_num


func start_scenario(new_settings: ScenarioSettings) -> void:
	launched_scenario_id = new_settings.id
	PuzzleScore.reset()
	switch_scenario(new_settings)


func switch_scenario(new_settings: ScenarioSettings) -> void:
	settings = new_settings
	emit_signal("settings_changed")


"""
Launches a puzzle scene with the previously specified 'launched scenario' settings.
"""
func push_scenario_trail() -> void:
	var scenario_settings := ScenarioSettings.new()
	scenario_settings.load_from_resource(launched_scenario_id)
	start_scenario(scenario_settings)
	if Scenario.launched_creature_id:
		var creature_def := CreatureLoader.load_creature_def_by_id(Scenario.launched_creature_id)
		Global.creature_queue.push_front(creature_def)
	Breadcrumb.push_trail(Global.SCENE_PUZZLE)
