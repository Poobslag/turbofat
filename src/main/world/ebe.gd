extends Creature3D
"""
Script for showing a creature 'Ebe' in the 3D overworld.
"""

func _ready() -> void:
	set_meta("chat_id", "ebe")
	set_meta("chat_name", "Ebe")
	set_meta("chat_theme_def", {"accent_scale":0.87,"accent_swapped":true,"accent_texture":15,"color":"b47922"})

"""
Ebe is brown with a beak mouth.
"""
func get_creature_def() -> Dictionary:
	return {
		"line_rgb": "6c4331", "body_rgb": "b47922", "eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398",
		"ear": "1", "horn": "2", "mouth": "1", "eye": "2"
	}
