extends ScenarioButton
"""
Button which launches a 'sprint' scenario.
"""

"""
Calculates the label text for displaying a player's high score for sprint mode.
"""
func get_best_text(scenario_name: String) -> String:
	var text := ""
	var best_result := PlayerData.get_best_scenario_result(scenario_name)
	if best_result:
		text = "Top: %s (%s)" % [best_result.score, Global.grade(best_result.score_rank)]
	return text
