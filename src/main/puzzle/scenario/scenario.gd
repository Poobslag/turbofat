extends Node
"""
Loads scenarios from files.

Scenarios are stored as a set of json resources. This class parses those json resources into ScenarioSettings so they
can be used by the puzzle code.

This class needs to be a node because it provides utility methods which utilize the scene tree.
"""

# emitted after the scenario has customized the puzzle's settings.
signal settings_changed

# The settings for the scenario currently being launched or played
var settings := ScenarioSettings.new() setget set_settings

# The scenario which was initially launched. Some tutorial scenarios transition
# into other scenarios, so this keeps track of the original.
var launched_scenario_name

# 'true' if launching a puzzle from the overworld. This changes the menus and disallows restarting.
var overworld_puzzle := false

func load_scenario_from_name(name: String) -> ScenarioSettings:
	var text := FileUtils.get_file_as_text(scenario_path(name))
	return load_scenario(name, text)


func load_scenario(name: String, text: String) -> ScenarioSettings:
	var scenario_settings := ScenarioSettings.new()
	scenario_settings.from_json_dict(name, parse_json(text))
	return scenario_settings


func scenario_name(path: String) -> String:
	return path.get_file().trim_suffix(".json")


func scenario_path(name: String) -> String:
	return "res://assets/main/puzzle/scenario/%s.json" % name


func scenario_filename(name: String) -> String:
	return "%s.json" % name


func set_settings(new_settings: ScenarioSettings) -> void:
	settings = new_settings
	emit_signal("settings_changed")


"""
Launches a puzzle scene with the specified scenario settings.

Parameters:
	'scenario_settings': Defines the scenario's difficulty and win condition
	
	'overworld_puzzle': True if the player should return to the overworld when the puzzle is done
	
	'creature_def': Creatures who should appear in the restaurant.
"""
func push_scenario_trail(scenario_settings: ScenarioSettings, creature_def: Dictionary = {}) -> void:
	Scenario.settings = scenario_settings
	PuzzleScore.reset()
	Scenario.launched_scenario_name = scenario_settings.name
	Global.creature_queue.push_front(creature_def)
	Breadcrumb.push_trail("res://src/main/puzzle/Puzzle.tscn")
