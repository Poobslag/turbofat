extends Panel
"""
UI control which shows daily and all-time high scores.
"""

func set_scenario(new_scenario: ScenarioSettings) -> void:
	$Tables/DailyTable.set_scenario(new_scenario)
	$Tables/AllTimeTable.set_scenario(new_scenario)
