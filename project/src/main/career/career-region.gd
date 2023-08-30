class_name CareerRegion
## Stores information about a group of levels for career mode.

## Flag for regions where Fat Sensei is not following the player
const FLAG_NO_SENSEI := "no_sensei"

## Flag for regions where the player does not operate a restaurant.
const FLAG_NO_RESTAURANT := "no_restaurant"

## Chat key containing each region's prologue cutscene, which plays before any other cutscenes/levels
const PROLOGUE_CHAT_KEY_NAME := "prologue"

## Chat key containing each region's intro level cutscene, which plays before/after the intro level
const INTRO_LEVEL_CHAT_KEY_NAME := "intro_level"

## Chat key containing each region's boss level cutscene, which plays before/after the boss level
const BOSS_LEVEL_CHAT_KEY_NAME := "boss_level"

## Chat key containing each region's epilogue cutscene, which plays after all other cutscenes/levels
const EPILOGUE_CHAT_KEY_NAME := "epilogue"

## Region id used for identifying regions in source code and save data
var id: String

## Human-readable region name, such as 'Lemony Thickets'
##
## Note that while Cannoli Sandbar changes its name during Career mode, this variable always stores the name 'Cannoli
## Sandbar'. The CareerData.obfuscated_region_name() method should be called to conditionally display a different name.
var name: String

## Smallest distance the player must travel to enter this region.
var start := 0

## Smallest distance the player must travel to exit this region.
##
## If the length is Careers.MAX_DISTANCE_TRAVELLED, this region cannot be exited.
var length := 0

## Furthest distance the player can travel while remaining within this region.
##
## Immutable value. Calculated by combining 'start' and 'length'
var end := 0 setget ,get_end

## Final level which must be cleared to advance past this region.
var boss_level: CareerLevel

## Resource chat key prefix for cutscenes for this region, such as 'chat/career/marsh'
var cutscene_path: String

## Describes the creatures in this region.
var population := Population.new()

## Human-readable tagline describing this career region.
var description: String

## Returns 'true' if this region has the specified flag.
##
## Regions can have flags for unusual qualities, such as regions where Fat Sensei is not following the player, or
## where the player does not operate a restaurant.
var flags: Dictionary = {}

## Human-readable icon name, such as 'forest' or 'cactus'
var icon_name: String

## First level which must be cleared before any other levels in this region.
var intro_level: CareerLevel

## List of CareerLevel instances which store career-mode-specific information about this region's levels.
var levels := []

## Minimum/maximum piece speeds for this region. Levels are adjusted to these piece speeds, if possible.
var min_piece_speed := "0"
var max_piece_speed := "0"

## Human-readable environment name, such as 'lemon' or 'marsh' for the overworld environment
var overworld_environment_name: String

## Human-readable environment name, such as 'lemon' or 'marsh' for the puzzle environment
var puzzle_environment_name: String

## Human-readable name, such as 'lemon' or 'marsh' for the button on the region select screen
var region_button_name: String

func from_json_dict(json: Dictionary) -> void:
	id = json.get("id", "")
	name = tr(json.get("name", ""))
	start = int(json.get("start", 0))
	
	if json.has("boss_level"):
		boss_level = CareerLevel.new()
		boss_level.from_json_dict(json.get("boss_level"))
	cutscene_path = json.get("cutscene_path", "")
	if json.has("population"):
		population.from_json_dict(json.get("population"))
	description = tr(json.get("description", ""))
	for flags_string in json.get("flags", []):
		flags[flags_string] = true
	icon_name = json.get("icon", "")
	if json.has("intro_level"):
		intro_level = CareerLevel.new()
		intro_level.from_json_dict(json.get("intro_level"))
	for level_json in json.get("levels", []):
		var level: CareerLevel = CareerLevel.new()
		level.from_json_dict(level_json)
		levels.append(level)
	overworld_environment_name = json.get("overworld_environment", "")
	region_button_name = json.get("region_button", "")
	var piece_speed_string: String = json.get("piece_speed", "0")
	if "-" in piece_speed_string:
		min_piece_speed = StringUtils.substring_before(piece_speed_string, "-")
		max_piece_speed = StringUtils.substring_after(piece_speed_string, "-")
	else:
		min_piece_speed = piece_speed_string
		max_piece_speed = piece_speed_string
	puzzle_environment_name = json.get("puzzle_environment", "")


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


func get_end() -> int:
	return start + length - 1


## Returns 'true' if the region has an end, or 'false' for the final endless region.
func has_end() -> bool:
	return length < Careers.MAX_DISTANCE_TRAVELLED


## Returns 'true' if this region has the specified flag.
##
## Regions can have flags for unusual qualities, such as regions where Fat Sensei is not following the player, or
## where the player does not operate a restaurant.
func has_flag(key: String) -> bool:
	return flags.has(key)
