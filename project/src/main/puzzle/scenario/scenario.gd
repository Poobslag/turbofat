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
var settings := ScenarioSettings.new() setget switch_scenario

# The scenario which was initially launched. Some tutorial scenarios transition
# into other scenarios, so this keeps track of the original.
var launched_scenario_name

# 'true' if launching a puzzle from the overworld. This changes the menus and disallows restarting.
var overworld_puzzle := false

func start_scenario(new_settings: ScenarioSettings) -> void:
	Scenario.launched_scenario_name = new_settings.name
	PuzzleScore.reset()
	switch_scenario(new_settings)


func switch_scenario(new_settings: ScenarioSettings) -> void:
	settings = new_settings
	emit_signal("settings_changed")


"""
Launches a puzzle scene with the specified scenario settings.

Parameters:
	'scenario_settings': Defines the scenario's difficulty and win condition
	
	'overworld_puzzle': True if the player should return to the overworld when the puzzle is done
	
	'dna': Creature who should appear in the restaurant.
"""
func push_scenario_trail(scenario_settings: ScenarioSettings, dna: Dictionary = {}) -> void:
	start_scenario(scenario_settings)
	if dna:
		Global.creature_queue.push_front(dna)
	Breadcrumb.push_trail("res://src/main/puzzle/Puzzle.tscn")
