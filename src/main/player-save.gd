extends Node
"""
Reads and writes data about the player's progress from a file.

This data includes how well they've done on each level and how much money they've earned.

Save data is stored as a series of lines. Each line contains a 4-character string followed by json data:
	'plyr{...}': Player data; how much money they have
	'scen{...}': Scenario data; how many points they scored, how long they took
"""

# filename to use when saving/loading player data. can be changed for tests
var player_data_filename := "user://turbofat.save"

func _ready() -> void:
	load_player_data()


"""
Writes the scenario history to a save file, where it can be loaded next the the player starts the game.
"""
func save_player_data() -> void:
	var save_game := File.new()
	save_game.open(player_data_filename, File.WRITE)
	save_game.store_line("plyr%s" % to_json({
		"money": PlayerData.money
	}))
	for key in PlayerData.scenario_history.keys():
		var rank_results_json := []
		for rank_result in PlayerData.scenario_history[key]:
			rank_results_json.append(rank_result.to_dict())
		save_game.store_line("scen%s" % to_json({
			"scenario_name": key,
			"scenario_history": rank_results_json
		}))
	save_game.close()


"""
Loads the scenario history from a save file.
"""
func load_player_data() -> void:
	var save_game := File.new()
	if save_game.file_exists(player_data_filename):
		save_game.open(player_data_filename, File.READ)
		while not save_game.eof_reached():
			var line_string := save_game.get_line()
			if not line_string:
				continue
			var line_prefix := line_string.substr(0, 4)
			var line_json = parse_json(line_string.substr(4))
			if not line_json:
				continue
			var line_dict: Dictionary = line_json
			match line_prefix:
				"plyr":
					PlayerData.money = line_dict["money"]
				"scen":
					for rank_result_json in line_dict["scenario_history"]:
						var rank_result := RankResult.new()
						rank_result.from_dict(rank_result_json)
						PlayerData.add_scenario_history(line_dict["scenario_name"], rank_result)
		save_game.close()
