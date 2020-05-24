extends Node
"""
Loads scenarios from files.

Scenarios are stored as a set of json resources. This class parses those json resources into ScenarioSettings so they
can be used by the puzzle code.

This class needs to be a node because it provides utility methods which utilize the scene tree.
"""

func load_scenario_from_name(name: String) -> ScenarioSettings:
	var text := Global.get_file_as_text(scenario_path(name))
	return load_scenario(name, text)


func load_scenario(name: String, text: String) -> ScenarioSettings:
	var scenario_settings := ScenarioSettings.new()
	scenario_settings.from_dict(name, parse_json(text))
	return scenario_settings


func scenario_name(path: String) -> String:
	return path.get_file().trim_suffix(".json")


func scenario_path(name: String) -> String:
	return "res://assets/puzzle/scenario/%s.json" % name


func scenario_filename(name: String) -> String:
	return "%s.json" % name


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
	Global.launched_scenario_name = scenario_settings.name
	Global.customer_queue.push_back(customer_def)
	Global.overworld_puzzle = overworld_puzzle
	if overworld_puzzle:
		Global.post_puzzle_target = "res://src/main/world/Overworld.tscn"
	else:
		Global.post_puzzle_target = "res://src/main/ui/ScenarioMenu.tscn"
	get_tree().change_scene("res://src/main/puzzle/scenario/Scenario.tscn")
