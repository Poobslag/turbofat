class_name CareerRegion
## Stores information about a block of levels for career mode.

## Chat key containing each region's prologue cutscene, which plays before any other cutscenes/levels
const PROLOGUE_CHAT_KEY_NAME := "prologue"

## Chat key containing each region's intro level cutscene, which plays before/after the intro level
const INTRO_LEVEL_CHAT_KEY_NAME := "intro_level"

## Chat key containing each region's boss level cutscene, which plays before/after the boss level
const BOSS_LEVEL_CHAT_KEY_NAME := "boss_level"

## Chat key containing each region's epilogue cutscene, which plays after all other cutscenes/levels
const EPILOGUE_CHAT_KEY_NAME := "epilogue"

## A human-readable region name, such as 'Lemony Thickets'
var name: String

## A resource chat key prefix for cutscenes for this region, such as 'chat/career/marsh'
var cutscene_path: String

## The smallest distance the player must travel to enter this region.
var distance := 0

## A human-readable icon name, such as 'forest' or 'cactus'
var icon_name: String

## A human-readable environment name, such as 'lemon' or 'marsh' for the overworld environment
var overworld_environment_name: String

## A human-readable environment name, such as 'lemon' or 'marsh' for the puzzle environment
var puzzle_environment_name: String

## The smallest distance the player must travel to exit this region.
##
## If the length is CareerData.MAX_DISTANCE_TRAVELLED, this region cannot be exited.
var length := 0

## List of CareerLevel instances which store career-mode-specific information about this region's levels.
var levels := []

## Final level which must be cleared to advance past this region.
var boss_level: CareerLevel

## First level which must be cleared before any other levels in this region.
var intro_level: CareerLevel

## The minimum/maximum piece speeds for this region. Levels are adjusted to these piece speeds, if possible.
var min_piece_speed := "0"
var max_piece_speed := "0"

func from_json_dict(json: Dictionary) -> void:
	name = json.get("name", "")
	cutscene_path = json.get("cutscene_path", "")
	distance = int(json.get("distance", 0))
	icon_name = json.get("icon", "")
	overworld_environment_name = json.get("overworld_environment", "")
	puzzle_environment_name = json.get("puzzle_environment", "")
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
	if json.has("intro_level"):
		intro_level = CareerLevel.new()
		intro_level.from_json_dict(json.get("intro_level"))


func get_prologue_chat_key() -> String:
	return "%s/%s" % [cutscene_path, PROLOGUE_CHAT_KEY_NAME] if cutscene_path else ""


func get_intro_level_preroll_chat_key() -> String:
	return "%s/%s" % [cutscene_path, INTRO_LEVEL_CHAT_KEY_NAME] if cutscene_path else ""


func get_intro_level_postroll_chat_key() -> String:
	return "%s/%s_end" % [cutscene_path, INTRO_LEVEL_CHAT_KEY_NAME] if cutscene_path else ""


func get_boss_level_preroll_chat_key() -> String:
	return "%s/%s" % [cutscene_path, BOSS_LEVEL_CHAT_KEY_NAME] if cutscene_path else ""


func get_boss_level_postroll_chat_key() -> String:
	return "%s/%s_end" % [cutscene_path, BOSS_LEVEL_CHAT_KEY_NAME] if cutscene_path else ""


func get_epilogue_chat_key() -> String:
	return "%s/%s" % [cutscene_path, EPILOGUE_CHAT_KEY_NAME] if cutscene_path else ""
