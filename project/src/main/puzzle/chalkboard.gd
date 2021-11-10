extends TextureRect
## Chalkboard which displays the player's score and progress during a puzzle.

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	visible = not CurrentLevel.settings.other.tutorial


func _on_Level_settings_changed() -> void:
	visible = not CurrentLevel.settings.other.tutorial
