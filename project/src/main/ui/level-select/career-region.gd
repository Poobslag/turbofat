class_name CareerRegion
## Stores information about a block of levels for career mode.

## A human-readable region name, such as 'Lemony Thickets'
var name: String

## A human-readable icon name, such as 'forest' or 'cactus'
var icon_name: String

## The smallest distance the player must travel to enter this region.
var distance := 0

## The smallest distance the player must travel to exit this region.
var length := 0

## List of CareerLevel instances which store career-mode-specific information about this region's levels.
var levels := []

## Final level which must be cleared to advance past this region.
var boss_level: CareerLevel

## The minimum/maximum piece speeds for this region. Levels are adjusted to these piece speeds, if possible.
var min_piece_speed := "0"
var max_piece_speed := "0"

func from_json_dict(json: Dictionary) -> void:
	name = json.get("name", "")
	icon_name = json.get("icon", "")
	distance = int(json.get("distance", 0))
	var piece_speed_string: String = json.get("piece_speed", "0")
	if "-" in piece_speed_string:
		min_piece_speed = StringUtils.substring_before(piece_speed_string, "-")
		max_piece_speed = StringUtils.substring_after(piece_speed_string, "-")
	else:
		min_piece_speed = piece_speed_string
		max_piece_speed = piece_speed_string
	for level_json in json.get("levels", []):
		var level: CareerLevel = CareerLevel.new()
		level.from_json_dict(level_json)
		levels.append(level)
	if json.has("boss_level"):
		boss_level = CareerLevel.new()
		boss_level.from_json_dict(json.get("boss_level"))
