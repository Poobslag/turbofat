extends Node
"""
Loads scenarios from files.

Scenarios are stored as a set of json resources. This class parses those json resources into ScenarioSettings so they
can be used by the puzzle code.

This class needs to be a node because it provides utility methods which utilize the scene tree.
"""

"""
Loads a scenario from a json file.
"""
func load_scenario_from_file(name: String) -> ScenarioSettings:
	var file := File.new()
	file.open("res://assets/puzzle/scenario/%s.json" % name, File.READ)
	var scenario_settings := ScenarioSettings.new()
	scenario_settings.from_dict(name, parse_json(file.get_as_text()))
	return scenario_settings


"""
Launches a scenario scene with the specified puzzle settings.

Parameters:
	'scenario_settings': Defines the scenario's difficulty and win condition
	
	'overworld_puzzle': True if the player should return to the overworld when the puzzle is done
	
	'customer_def': Customers who should appear in the restaurant.
"""
func change_scenario_scene(scenario_settings: ScenarioSettings, overworld_puzzle: bool,
		customer_def: Dictionary = {}) -> void:
	Global.scenario_settings = scenario_settings
	Global.customer_queue.push_back(customer_def)
	Global.overworld_puzzle = overworld_puzzle
	get_tree().change_scene("res://src/main/puzzle/Scenario.tscn")
