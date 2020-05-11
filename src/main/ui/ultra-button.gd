extends ScenarioButton
"""
Button which launches an 'ultra' scenario.
"""

"""
Calculates the label text for displaying a player's fastest time for ultra mode.
"""
func get_best_text(scenario_name: String) -> String:
	var text := ""
	var best_result := PlayerData.get_best_scenario_result(scenario_name, "seconds")
	if best_result:
		var seconds := int(ceil(best_result.seconds))
		text = "Top: %01d:%02d (%s)" % [seconds / 60, seconds % 60, Global.grade(best_result.seconds_rank)]
	return text
