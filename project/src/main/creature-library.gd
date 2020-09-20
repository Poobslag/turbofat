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
	"belly": "1",
	"belly_rgb": "c9442a",
	"bellybutton": "0",
	"body": "1",
	"body_rgb": "b23823",
	"cheek": "3",
	"cloth_rgb": "282828",
	"collar": "0",
	"ear": "1",
	"eye": "1",
	"eye_rgb": "282828 dedede",
	"hair": "0",
	"hair_rgb": "f1e398",
	"head": "1",
	"horn": "1",
	"horn_rgb": "f1e398",
	"line_rgb": "6c4331",
	"mouth": "2",
	"nose": "0",
	"tail": "0",
}

# default name when starting a new game
const DEFAULT_NAME := "Spira"

var player_def: CreatureDef

# fatnesses by creature id
var _fatnesses: Dictionary

# fatnesses saved to roll the tile map back to a previous state
var _saved_fatnesses: Dictionary

func reset() -> void:
	# default player appearance and name
	player_def = CreatureDef.new()
	player_def.creature_name = DEFAULT_NAME
	player_def.creature_short_name = NameUtils.sanitize_short_name(player_def.creature_name)
	player_def.dna = DEFAULT_DNA.duplicate()
	player_def.fatness = 1.0
	player_def.chat_theme_def = DEFAULT_CHAT_THEME_DEF.duplicate()


"""
Saves the current fatness state so that we can roll back later.
"""
func save_fatness_state() -> void:
	_saved_fatnesses = _fatnesses.duplicate()


"""
Restores the previously saved fatness state.

This prevents a creature from gaining weight when retrying a level over and over.
Thematically, we're turning back time.
"""
func restore_fatness_state() -> void:
	_fatnesses = _saved_fatnesses.duplicate()


func has_fatness(creature_id: String) -> bool:
	if not creature_id:
		return false
	
	return _fatnesses.has(creature_id)


func get_fatness(creature_id: String) -> float:
	return _fatnesses[creature_id]


func set_fatness(creature_id: String, fatness: float) -> void:
	if not creature_id:
		return
	
	_fatnesses[creature_id] = fatness


func to_json_dict() -> Dictionary:
	return {
		"#player#": player_def.to_json_dict(),
		"fatnesses": _fatnesses,
	}


func from_json_dict(json: Dictionary) -> void:
	reset()
	if json.has("#player#"):
		player_def.from_json_dict(json.get("#player#", {}))
	if json.has("fatnesses"):
		_fatnesses = json.get("fatnesses")
