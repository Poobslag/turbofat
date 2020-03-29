extends Node

var _rank_calculator = preload("res://scenes/RankCalculator.gd").new()

# filename to use when saving/loading scenario history. can be changed for tests
var scenario_history_filename := "user://scenario_history.save"

# 'true' if the scenario history has been loaded. we only need to load it once
var loaded_scenario_history := false

"""
Stores every RankResult the player has received for different scenarios. This is currently used for calculating high
scores, but could eventually be used for displaying statistics or calculating rewards.

key: (String) Scenario name 
value: (Array) All RankResults for the specified scenario
"""
var scenario_history := {}

# how many records we can store before we start deleting old ones
var history_size := 1000

"""
Records the current scenario performance to the player's history.
"""
func add_scenario_history(scenario_name, rank_result) -> void:
	if scenario_name == "":
		# can't store history without a scenario name
		return
	if !scenario_history.has(scenario_name):
		scenario_history[scenario_name] = []
	scenario_history[scenario_name].push_front(rank_result)
	if scenario_history[scenario_name].size() > history_size:
		scenario_history[scenario_name].resize(history_size)

"""
Writes the scenario_history to a save file, where it can be loaded next the the player starts the game.
"""
func save_scenario_history() -> void:
	var save_game := File.new()
	save_game.open(scenario_history_filename, File.WRITE)
	for key in scenario_history.keys():
		var rank_results_json = []
		for rank_result in scenario_history[key]:
			rank_results_json.append(rank_result.to_dict())
		save_game.store_line(to_json({
			"scenario_name" : key,
			"scenario_history" : rank_results_json
		}))
	save_game.close()

"""
Loads the scenario_history from a save file.
"""
func load_scenario_history() -> void:
	loaded_scenario_history = true
	
	var save_game := File.new()
	if !save_game.file_exists(scenario_history_filename):
		return
	
	save_game.open(scenario_history_filename, File.READ)
	while !save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		if current_line == null:
			continue
		for rank_result_json in current_line["scenario_history"]:
			var rank_result = _rank_calculator.RankResult.new()
			rank_result.from_dict(rank_result_json)
			add_scenario_history(current_line["scenario_name"], rank_result)
	save_game.close()
