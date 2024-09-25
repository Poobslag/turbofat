class_name LevelSettings
## Contains settings for a level.
##
## This includes information about how the player loses/wins, what kind of pieces they're given, whether they're given
## a time limit, and any other special rules.

## Icons shown when selecting a level which warn the player about gimmicks.
enum LevelIcon {
	# critters
	CARROT,
	MOLE,
	SHARK,
	ONION,
	SPEAR,

	# pieces
	PIECE_J,
	PIECE_L,
	PIECE_O,
	PIECE_P,
	PIECE_Q,
	PIECE_T,
	PIECE_U,
	PIECE_V,
	PIECE_S,
	PIECE_Z,
	PIECE_C,
	PIECE_K,

	# related to pieces
	SNACK_BOX,
	CAKE_BOX,
	VEGGIE,

	# qualities
	BASIC, # levels which reward normal play (building and clearing boxes)
	SLOW, # levels with no time pressure
	FAST, # levels which reward or force fast play
	DIG, # levels which require 'digging down' rather than 'building up'
	SURPRISING, # levels with a surprising gimmick, which are mitigated if you play them a second time
	ANNOYING, # levels with an annoying gimmick, which are difficult to mitigate even with experience
	CONFUSING, # levels with a confusing gimmick, which require conscious planning or clever strategy
	SNEAKY, # levels with a sneaky way to score a lot of points, which you might look up on the internet
	NARROW, # levels with a narrow playfield
	BLIND, # Levels which reward memorizing the playfield. Technically all carrot and onion levels reward memorizing
		# the playfield, but this icon is used for the more egregious levels.
	STOP, # Levels which make you wait for something (most commonly, waiting for lines to clear)
	TURN, # Levels with special rotation rules
}

## Level description shown when selecting a level.
var description := ""

## (optional) Level difficulty shown when selecting a level.
var difficulty := "" setget ,get_difficulty

## Blocks/boxes which appear or disappear while the game is going on.
var blocks_during := BlocksDuringRules.new()

## Level button color. This is usually random, but for rank mode we use specific colors.
var color_string := ""

## Things that disrupt the player's combo.
var combo_break := ComboBreakRules.new()

## How the player finishes. When the player finishes, they can't play anymore, and the level just ends. It should be
## used for limits such as serving 5 creatures or clearing 10 lines.
var finish_condition := Milestone.new()

## Icons shown when selecting a level which warn the player about gimmicks.
var icons := []

## Level id used for saving/loading data.
var id := ""

## Sequence of puzzle inputs to be replayed for things such as tutorials.
var input_replay := InputReplay.new()

## How the player loses. The player usually loses if they top out a certain number of times, but some levels might
## have different rules.
var lose_condition := LoseConditionRules.new()

## Level name shown in menus.
var name := ""

## Rules which are unique enough that it doesn't make sense to put them in their own groups.
var other := OtherRules.new()

## Selection of pieces provided to the player.
var piece_types := PieceTypeRules.new()

## Tweaks to rank calculation.
var rank := RankRules.new()

## Rules for scoring points.
var score := ScoreRules.new()

var speed := SpeedRules.new()

## How the player succeeds. When the player succeeds, there's a big fanfare and celebration, it should be used for
## accomplishments such as surviving 10 minutes or getting 1,000 points.
var success_condition := Milestone.new()

## Sets of blocks which are shown initially, or appear during the game.
var tiles := LevelTiles.new()

## Timers which cause strange things to happen during a level.
var timers := LevelTimers.new()

## Triggers which cause strange things to happen during a level.
var triggers := LevelTriggers.new()

var _upgrader := LevelSettingsUpgrader.new()


## Sets the criteria for finishing the level, such as a time, score, or line goal.
func set_finish_condition(type: int, value: int, lenient_value: int = -1) -> void:
	finish_condition = Milestone.new()
	finish_condition.set_milestone(type, value)
	if lenient_value > -1:
		finish_condition.set_meta("lenient_value", str(lenient_value))


## Sets the criteria for succeeding, such as a time or score goal.
func set_success_condition(type: int, value: int) -> void:
	success_condition = Milestone.new()
	success_condition.set_milestone(type, value)


## Populates this object with json data.
##
## Parameters:
## 	'new_id': The level id used for saving statistics.
func from_json_dict(new_id: String, json: Dictionary) -> void:
	id = new_id
	
	if _upgrader.needs_upgrade(json):
		json = _upgrader.upgrade(json)
	
	if json.has("blocks_during"):
		blocks_during.from_json_array(json["blocks_during"])
	if json.has("color"):
		color_string = json["color"]
	if json.has("combo_break"):
		combo_break.from_json_array(json["combo_break"])
	if json.has("description"):
		description = tr(json["description"])
	if json.has("difficulty"):
		difficulty = json["difficulty"]
	if json.has("finish_condition"):
		finish_condition.from_json_dict(json["finish_condition"])
	if json.has("icons"):
		icons = _icon_ints_from_strings(json["icons"])
	if json.has("input_replay"):
		input_replay.from_json_array(json["input_replay"])
	if json.has("lose_condition"):
		lose_condition.from_json_array(json["lose_condition"])
	if json.has("name"):
		name = tr(json["name"])
	if json.has("other"):
		other.from_json_array(json["other"])
	if json.has("piece_types"):
		piece_types.from_json_array(json["piece_types"])
	if json.has("rank"):
		rank.from_json_array(json["rank"])
	if json.has("score"):
		score.from_json_array(json["score"])
	if json.has("speed_ups"):
		speed.speed_ups_from_json_array(json["speed_ups"])
	if json.has("start_speed"):
		speed.start_speed_from_json_string(json["start_speed"])
	if json.has("success_condition"):
		success_condition.from_json_dict(json["success_condition"])
	if json.has("tiles"):
		tiles.from_json_dict(json["tiles"])
	if json.has("timers"):
		timers.from_json_array(json["timers"])
	if json.has("triggers"):
		triggers.from_json_array(json["triggers"])
	
	rank.rank_criteria.duration_criteria = finish_condition.type == Milestone.SCORE


func to_json_dict() -> Dictionary:
	var result := {}
	result["version"] = _upgrader.current_version
	if name: result["name"] = name
	if description: result["description"] = description
	if difficulty: result["difficulty"] = difficulty
	if color_string: result["color"] = color_string
	if not speed.start_speed_is_default(): result["start_speed"] = speed.start_speed_to_json_string()
	if not speed.speed_ups_is_default(): result["speed_ups"] = speed.speed_ups_to_json_array()
	if not blocks_during.is_default(): result["blocks_during"] = blocks_during.to_json_array()
	if not combo_break.is_default(): result["combo_break"] = combo_break.to_json_array()
	if not finish_condition.is_default(): result["finish_condition"] = finish_condition.to_json_dict()
	if icons: result["icons"] = _icon_strings_from_ints(icons)
	if not input_replay.is_default(): result["input_replay"] = input_replay.to_json_array()
	if not lose_condition.is_default(): result["lose_condition"] = lose_condition.to_json_array()
	if not other.is_default(): result["other"] = other.to_json_array()
	if not piece_types.is_default(): result["piece_types"] = piece_types.to_json_array()
	if not rank.is_default(): result["rank"] = rank.to_json_array()
	if not score.is_default(): result["score"] = score.to_json_array()
	if not success_condition.is_default(): result["success_condition"] = success_condition.to_json_dict()
	if not tiles.is_default(): result["tiles"] = tiles.to_json_dict()
	if not timers.is_default(): result["timers"] = timers.to_json_array()
	if not triggers.is_default(): result["triggers"] = triggers.to_json_array()
	return result


func load_from_resource(new_id: String) -> void:
	var text := FileUtils.get_file_as_text(path_from_level_key(new_id))
	
	if not text:
		push_error("Level not found: %s" % [new_id])
		return
	
	load_from_text(new_id, text)


func load_from_text(new_id: String, text: String) -> void:
	var json: Dictionary = parse_json(text)
	
	if not json:
		push_error("Level not found: %s" % [new_id])
		return
	
	from_json_dict(new_id, json)


func get_difficulty() -> String:
	return difficulty if difficulty else speed.get_max_speed()


## Parameters:
## 	'icon_strings': Lowercase strings corresponding to entries in LevelIcon, like 'shark' or 'cake_box'
##
## Returns:
## 	List of enums from LevelIcon, like SHARK or CAKE_BOX
func _icon_ints_from_strings(icon_strings: Array) -> Array:
	var result := []
	for icon_string in icon_strings:
		var icon_int: int = Utils.enum_from_snake_case(LevelIcon, icon_string, -1)
		if icon_int == -1:
			push_warning("Invalid level icon: %s" % [icon_string])
		else:
			result.append(icon_int)
	return result


## Parameters:
## 	'icon_strings': Enums from LevelIcon, like SHARK or CAKE_BOX
##
## Returns:
## 	Lowercase strings corresponding to entries in LevelIcon, like 'shark' or 'cake_box'
func _icon_strings_from_ints(icon_ints: Array) -> Array:
	var result := []
	for icon_int in icon_ints:
		var icon_string: String = Utils.enum_to_snake_case(LevelIcon, icon_int, "")
		if icon_string == "":
			push_warning("Invalid level icon: %s" % [icon_string])
		else:
			result.append(icon_string)
	return result


static func path_from_level_key(level_key: String) -> String:
	var level_path := StringUtils.underscores_to_hyphens(level_key)
	return "res://assets/main/puzzle/levels/%s.json" % level_path


static func level_key_from_path(level_path: String) -> String:
	var level_key := StringUtils.hyphens_to_underscores(level_path)
	level_key = level_key.trim_suffix(".json")
	if level_key.begins_with("res://"):
		# preserve part of the path, resulting in 'foo/bar/level_183'
		level_key = level_key.trim_prefix("res://assets/main/puzzle/levels/")
	else:
		# strip the entire path, resulting in 'level_183'
		level_key = StringUtils.substring_after_last(level_key, "/")
	return level_key


static func level_exists_with_key(level_key: String) -> bool:
	return FileUtils.file_exists(path_from_level_key(level_key))
