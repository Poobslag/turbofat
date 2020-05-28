extends PracticeButton
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
		var duration := StringUtils.format_duration(best_result.seconds)
		text = "Top: %s (%s)" % [duration, Global.grade(best_result.seconds_rank)]
	return text
