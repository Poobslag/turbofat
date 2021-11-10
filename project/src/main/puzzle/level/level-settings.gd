class_name LevelSettings
## Contains settings for a level.
##
## This includes information about how the player loses/wins, what kind of pieces they're given, whether they're given
## a time limit, and any other special rules.

## The level description shown when selecting a level.
var description := ""

## (optional) The level difficulty shown when selecting a level.
var difficulty := "" setget ,get_difficulty

## Blocks/boxes which appear or disappear while the game is going on.
var blocks_during := BlocksDuringRules.new()

## Things that disrupt the player's combo.
var combo_break := ComboBreakRules.new()

## How the player finishes. When the player finishes, they can't play anymore, and the level just ends. It should be
## used for limits such as serving 5 creatures or clearing 10 lines.
var finish_condition := Milestone.new()

## The level id used for saving/loading data.
var id := ""

## Sequence of puzzle inputs to be replayed for things such as tutorials.
var input_replay := InputReplay.new()

## How the player loses. The player usually loses if they top out a certain number of times, but some levels might
## have different rules.
var lose_condition := LoseConditionRules.new()

## Rules which are unique enough that it doesn't make sense to put them in their own groups.
var other := OtherRules.new()

## The selection of pieces provided to the player.
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

## The level title shown in menus.
var title := ""

## Triggers which cause strange things to happen during a level.
var triggers := LevelTriggers.new()

var _upgrader := LevelSettingsUpgrader.new()


## Sets the criteria for finishing the level, such as a time, score, or line goal.
func set_finish_condition(type: int, value: int, lenient_value: int = -1) -> void:
	finish_condition = Milestone.new()
	finish_condition.set_milestone(type, value)
	if lenient_value > -1:
		finish_condition.set_meta("lenient_value", lenient_value)


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
	if json.has("combo_break"):
		combo_break.from_json_array(json["combo_break"])
	if json.has("description"):
		description = json["description"]
	if json.has("difficulty"):
		difficulty = json["difficulty"]
	if json.has("finish_condition"):
		finish_condition.from_json_dict(json["finish_condition"])
	if json.has("input_replay"):
		input_replay.from_json_array(json["input_replay"])
	if json.has("lose_condition"):
		lose_condition.from_json_array(json["lose_condition"])
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
	if json.has("title"):
		title = json["title"]
	if json.has("timers"):
		timers.from_json_array(json["timers"])
	if json.has("triggers"):
		triggers.from_json_array(json["triggers"])


func to_json_dict() -> Dictionary:
	var result := {}
	if title: result["title"] = title
	if description: result["description"] = description
	if difficulty: result["difficulty"] = difficulty
	if not speed.start_speed_is_default(): result["start_speed"] = speed.start_speed_to_json_string()
	if not speed.speed_ups_is_default(): result["speed_ups"] = speed.speed_ups_to_json_array()
	if not blocks_during.is_default(): result["blocks_during"] = blocks_during.to_json_array()
	if not combo_break.is_default(): result["combo_break"] = combo_break.to_json_array()
	if not finish_condition.is_default(): result["finish_condition"] = finish_condition.to_json_dict()
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
	load_from_text(new_id, FileUtils.get_file_as_text(path_from_level_key(new_id)))


func load_from_text(new_id: String, text: String) -> void:
	from_json_dict(new_id, parse_json(text))


func get_difficulty() -> String:
	var result: String
	if difficulty:
		result = difficulty
	else:
		result = _get_max_speed_id()
	return result


func _get_max_speed_id() -> String:
	var max_speed_id_index := 0
	var max_speed_id: String = PieceSpeeds.speed_ids[0]
	for milestone_obj in speed.speed_ups:
		var milestone: Milestone = milestone_obj
		var speed_id: String = milestone.get_meta("speed")
		var speed_id_index: int = PieceSpeeds.speed_ids.find(speed_id)
		if speed_id_index > max_speed_id_index:
			max_speed_id_index = speed_id_index
			max_speed_id = speed_id
	return max_speed_id


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
