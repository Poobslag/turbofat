extends Creature3D
"""
Script for showing a creature 'Boatricia' in the 3D overworld.
"""

func _ready() -> void:
	set_meta("chat_id", "boatricia")
	set_meta("chat_name", "Boatricia")
	set_meta("chat_theme_def", {"accent_scale":0.33, "accent_swapped": true,
			"accent_texture": 1, "color": "0b45a6", "dark": true})
	
	# Boatricia is dark blue with short stubby horns.
	set_creature_def({
		"line_rgb": "41281e", "body_rgb": "0b45a6", "eye_rgb": "fad541 ffffff", "horn_rgb": "282828",
		"ear": "2", "horn": "0", "mouth": "1", "eye": "3"})
