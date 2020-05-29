extends Panel
"""
User interface element which shows daily and all-time high scores.
"""

func set_scenario(scenario: ScenarioSettings) -> void:
	$Tables/DailyTable.set_scenario(scenario)
	$Tables/AllTimeTable.set_scenario(scenario)
