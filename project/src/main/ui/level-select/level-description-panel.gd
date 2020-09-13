extends Panel
"""
A panel on the level select screen which shows level descriptions.
"""

"""
Updates the description panel when a new level is selected.
"""
func _on_LevelButtons_level_selected(settings: ScenarioSettings) -> void:
	$MarginContainer/Label.text = settings.description
