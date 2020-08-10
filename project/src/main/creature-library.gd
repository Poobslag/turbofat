class_name CreatureLibrary
"""
Manages data for all creatures in the world, including the player.

This includes their appearance, name and weight.
"""

# default chat theme when starting a new game
const DEFAULT_CHAT_THEME_DEF := {
	"accent_scale": 1.33,
	"accent_swapped": true,
	"accent_texture": 13,
	"color": "b23823"
}

# default creature appearance when starting a new game
const DEFAULT_DNA := {
	"line_rgb": "6c4331",
	"body_rgb": "b23823",
	"belly": "1",
	"belly_rgb": "c9442a",
	"ear": "1",
	"eye": "1",
	"eye_rgb": "282828 dedede",
	"horn": "1",
	"horn_rgb": "f1e398",
	"mouth": "2",
	"nose": "0",
	"cheek": "3"
}

# default name when starting a new game
const DEFAULT_NAME := "Spira"

var player_def: CreatureDef

func reset() -> void:
	# default player appearance and name
	player_def = CreatureDef.new()
	player_def.creature_name = DEFAULT_NAME
	player_def.creature_short_name = NameUtils.sanitize_short_name(player_def.creature_name)
	player_def.dna = DEFAULT_DNA.duplicate()
	player_def.fatness = 1.0
	player_def.chat_theme_def = DEFAULT_CHAT_THEME_DEF.duplicate()


func to_json_dict() -> Dictionary:
	return {
		"#player#": player_def.to_json_dict(),
	}


func from_json_dict(json: Dictionary) -> void:
	reset()
	if json.has("#player#"):
		player_def.from_json_dict(json.get("#player#", {}))
