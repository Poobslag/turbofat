extends Panel
"""
UI control which shows daily and all-time high scores.
"""

func set_level(new_level: LevelSettings) -> void:
	$Tables/DailyTable.set_level(new_level)
	$Tables/AllTimeTable.set_level(new_level)
