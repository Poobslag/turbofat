extends TextureRect
"""
Chalkboard which displays the player's score and progress during a puzzle.
"""

func _ready() -> void:
	Scenario.connect("settings_changed", self, "_on_Scenario_settings_changed")
	visible = !Scenario.settings.other.tutorial


func _on_Scenario_settings_changed() -> void:
	visible = !Scenario.settings.other.tutorial
