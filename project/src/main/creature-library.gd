class_name CreatureLibrary
"""
Manages data for all creatures in the world, including the player.

This includes their appearance, name and weight.
"""

var player_def: CreatureDef

func reset() -> void:
	# default player appearance and name
	player_def = CreatureDef.new()
	player_def.creature_name = "Spira"
	player_def.dna = {
		"body_rgb": "b23823",
		"belly": "1",
		"belly_rgb": "c9442a",
		"ear": "1",
		"eye": "1",
		"eye_rgb": "282828 dedede",
		"horn": "1",
		"horn_rgb": "f1e398",
		"line_rgb": "6c4331",
		"mouth": "2",
		"nose": "0",
		"cheek": "3"
	}
	player_def.fatness = 1.0
	player_def.chat_theme_def = {
		"accent_scale": 1.33,
		"accent_swapped": true,
		"accent_texture": 13,
		"color": "b23823"
	}


func to_json_dict() -> Dictionary:
	return {
		"#player#": player_def.to_json_dict(),
	}


func from_json_dict(json: Dictionary) -> void:
	reset()
	if json.has("#player#"):
		player_def.from_json_dict(json.get("#player#", {}))
