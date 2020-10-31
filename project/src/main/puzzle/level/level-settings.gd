class_name LevelSettings
"""
Contains settings for a level.

This includes information about how the player loses/wins, what kind of pieces they're given, whether they're given a
time limit, and any other special rules.
"""

# Current version for saved level data. Should be updated if and only if the level format changes.
# This version number follows a 'ymdh' hex date format which is documented in issue #234.
const LEVEL_DATA_VERSION := "19c5"

# Blocks/boxes which begin on the playfield.
var blocks_start := BlocksStartRules.new()

# Blocks/boxes which appear or disappear while the game is going on.
var blocks_during := BlocksDuringRules.new()

# Things that disrupt the player's combo.
var combo_break := ComboBreakRules.new()

# How the player finishes. When the player finishes, they can't play anymore, and the level just ends. It should be
# used for limits such as serving 5 creatures or clearing 10 lines. 
var finish_condition := Milestone.new()

# Sequence of puzzle inputs to be replayed for things such as tutorials.
var input_replay := InputReplay.new()

# Array of Milestone objects representing the requirements to speed up. This mostly applies to 'Marathon Mode' where
# clearing lines makes you speed up.
var speed_ups := []

# How the player loses. The player usually loses if they top out a certain number of times, but some levels might
# have different rules.
var lose_condition := LoseConditionRules.new()

# The level id used for saving/loading data.
var id := ""

# The level title shown in menus.
var title := ""

# The level description shown when selecting a level.
var description := ""

# (optional) The level difficulty shown when selecting a level.
var difficulty := "" setget ,get_difficulty

# Rules which are unique enough that it doesn't make sense to put them in their own groups.
var other := OtherRules.new()

# The selection of pieces provided to the player.
var piece_types := PieceTypeRules.new()

# Tweaks to rank calculation.
var rank := RankRules.new()

# Rules for scoring points.
var score := ScoreRules.new()

# How the player succeeds. When the player succeeds, there's a big fanfare and celebration, it should be used for
# accomplishments such as surviving 10 minutes or getting 1,000 points.
var success_condition := Milestone.new()

func _init() -> void:
	# avoid edge cases caused by absence of a piece speed
	set_start_speed("0")


"""
Adds criteria for speeding up, such as a time, score, or line limit.
"""
func add_speed_up(type: int, value: int, speed_id: String) -> void:
	var speed_up := Milestone.new()
	speed_up.set_milestone(type, value)
	speed_up.set_meta("speed", speed_id)
	speed_ups.append(speed_up)


func set_start_speed(new_start_speed: String) -> void:
	speed_ups.clear()
	add_speed_up(Milestone.LINES, 0, new_start_speed)


"""
Sets the criteria for finishing the level, such as a time, score, or line goal.
"""
func set_finish_condition(type: int, value: int, lenient_value: int = -1) -> void:
	finish_condition = Milestone.new()
	finish_condition.set_milestone(type, value)
	if lenient_value > -1:
		finish_condition.set_meta("lenient_value", lenient_value)


"""
Sets the criteria for succeeding, such as a time or score goal.
"""
func set_success_condition(type: int, value: int) -> void:
	success_condition = Milestone.new()
	success_condition.set_milestone(type, value)


"""
Populates this object with json data.

Parameters:
	'new_id': The level id used for saving statistics.
"""
func from_json_dict(new_id: String, json: Dictionary) -> void:
	id = new_id
	match json.get("version"):
		LEVEL_DATA_VERSION:
			pass
		"1922":
			json = _convert_1922(json)
		_:
			push_warning("Unrecognized save data version: '%s'" % json.get("version"))
	
	title = json.get("title", "")
	description = json.get("description", "")
	difficulty = json.get("difficulty", "")
	set_start_speed(json.get("start_speed", "0"))

	if json.has("blocks_start"):
		blocks_start.from_json_dict(json["blocks_start"])
	if json.has("blocks_during"):
		blocks_during.from_json_string_array(json["blocks_during"])
	if json.has("combo_break"):
		combo_break.from_json_string_array(json["combo_break"])
	if json.has("finish_condition"):
		finish_condition.from_json_dict(json["finish_condition"])
	if json.has("speed_ups"):
		for json_speed_up in json["speed_ups"]:
			var speed_up := Milestone.new()
			speed_up.from_json_dict(json_speed_up)
			speed_ups.append(speed_up)
	if json.has("lose_condition"):
		lose_condition.from_json_string_array(json["lose_condition"])
	if json.has("other"):
		other.from_json_string_array(json["other"])
	if json.has("piece_types"):
		piece_types.from_json_string_array(json["piece_types"])
	if json.has("rank"):
		rank.from_json_string_array(json["rank"])
	if json.has("score"):
		score.from_json_string_array(json["score"])
	if json.has("success_condition"):
		success_condition.from_json_dict(json["success_condition"])
	if json.has("input_replay"):
		input_replay.from_json_string_array(json["input_replay"])


func load_from_resource(new_id: String) -> void:
	load_from_text(new_id, FileUtils.get_file_as_text(level_path(new_id)))


func load_from_text(new_id: String, text: String) -> void:
	from_json_dict(new_id, parse_json(text))


"""
Loads a level based on the creature's chat selectors.

Parameters:
	'creature': The creature whose level should be loaded.
	
	'level_num': Which level should be loaded; '1' is the first level.
"""
func load_from_creature(creature: Creature, level_num: int) -> void:
	var level_ids := creature.get_level_ids()
	var level_id: String = level_ids[level_num - 1]
	load_from_resource(level_id)


func get_difficulty() -> String:
	var result: String
	if difficulty:
		result = difficulty
	else:
		result = _get_max_speed_id()
	return result


func _convert_1922(json: Dictionary) -> Dictionary:
	var new_json := {}
	for old_key in json.keys():
		var old_value = json[old_key]
		var new_key: String = old_key
		var new_value = old_value
		match old_key:
			"version":
				new_value = "19c5"
			"start_level":
				new_key = "start_speed"
			"level_ups":
				new_key = "speed_ups"
				new_value = []
				for old_level_up in old_value:
					var new_level_up: Dictionary = old_level_up.duplicate()
					new_level_up["speed"] = new_level_up.get("level")
					new_level_up.erase("level")
					new_value.append(new_level_up)
		new_json[new_key] = new_value
	return new_json


func _get_max_speed_id() -> String:
	var max_speed_id_index := 0
	var max_speed_id: String = PieceSpeeds.speed_ids[0]
	for milestone_obj in speed_ups:
		var milestone: Milestone = milestone_obj
		var speed_id: String = milestone.get_meta("speed")
		var speed_id_index := PieceSpeeds.speed_ids.find(speed_id)
		if speed_id_index > max_speed_id_index:
			max_speed_id_index = speed_id_index
			max_speed_id = speed_id
	return max_speed_id


static func level_path(level_name: String) -> String:
	return "res://assets/main/puzzle/levels/%s.json" % (level_name.replace("_", "-"))


static func level_name(path: String) -> String:
	return path.get_file().trim_suffix(".json").replace("_", "-")


static func level_filename(level_name: String) -> String:
	return "%s.json" % level_name.replace("_", "-")
