class_name ScenarioSettings
"""
Contains settings for a scenario.

This includes information about how the player loses/wins, what kind of pieces they're given, whether they're given a
time limit, and any other special rules.
"""

# Current version for saved scenario data. Should be updated if and only if the scenario format changes.
# This version number follows a 'ymdh' hex date format which is documented in issue #234.
const SCENARIO_DATA_VERSION := "1922"

# Blocks/boxes which begin on the playfield.
var blocks_start := BlocksStartRules.new()

# Blocks/boxes which appear or disappear while the game is going on.
var blocks_during := BlocksDuringRules.new()

# Things that disrupt the player's combo.
var combo_break := ComboBreakRules.new()

# How the player finishes. When the player finishes, they can't play anymore, and the level just ends. It should be
# used for limits such as serving 5 creatures or clearing 10 lines. 
var finish_condition := Milestone.new()

# Array of Milestone objects representing the requirements to level up. This mostly applies to 'Marathon Mode' where
# clearing lines makes you level up.
var level_ups := []

# How the player loses. The player usually loses if they top out a certain number of times, but some scenarios might
# have different rules.
var lose_condition := LoseConditionRules.new()

# The scenario id used for saving/loading data.
var id := ""

# The scenario title shown in menus.
var title := ""

# The scenario description shown when selecting a scenario.
var description := ""

# (optional) The scenario difficulty shown when selecting a scenario.
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
	# avoid edge cases caused by absence of a speed level
	set_start_level("0")


"""
Adds criteria for leveling up, such as a time, score, or line limit.
"""
func add_level_up(type: int, value: int, level: String) -> void:
	var level_up := Milestone.new()
	level_up.set_milestone(type, value)
	level_up.set_meta("level", level)
	level_ups.append(level_up)


func set_start_level(new_start_level: String) -> void:
	level_ups.clear()
	add_level_up(Milestone.LINES, 0, new_start_level)


"""
Sets the criteria for finishing the scenario, such as a time, score, or line goal.
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
	'new_id': The scenario id used for saving statistics.
"""
func from_json_dict(new_id: String, json: Dictionary) -> void:
	id = new_id
	if json.get("version") != SCENARIO_DATA_VERSION:
		push_warning("Unrecognized scenario data version: '%s'" % json.get("version"))
	
	title = json.get("title", "")
	description = json.get("description", "")
	difficulty = json.get("difficulty", "")
	set_start_level(json.get("start_level", "0"))

	if json.has("blocks_start"):
		blocks_start.from_json_dict(json["blocks_start"])
	if json.has("blocks_during"):
		blocks_during.from_json_string_array(json["blocks_during"])
	if json.has("combo_break"):
		combo_break.from_json_string_array(json["combo_break"])
	if json.has("finish_condition"):
		finish_condition.from_json_dict(json["finish_condition"])
	if json.has("level_ups"):
		for json_level_up in json["level_ups"]:
			var level_up := Milestone.new()
			level_up.from_json_dict(json_level_up)
			level_ups.append(level_up)
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


func load_from_resource(new_id: String) -> void:
	load_from_text(new_id, FileUtils.get_file_as_text(scenario_path(new_id)))


func load_from_text(new_id: String, text: String) -> void:
	from_json_dict(new_id, parse_json(text))


"""
Loads a scenario based on the creature's chat selectors.

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
		result = _get_max_speed_level()
	return result


func _get_max_speed_level() -> String:
	var max_speed_level_index := 0
	var max_speed_level: String = PieceSpeeds.speed_levels[0]
	for milestone_obj in level_ups:
		var milestone: Milestone = milestone_obj
		var speed_level: String = milestone.get_meta("level")
		var speed_level_index := PieceSpeeds.speed_levels.find(speed_level)
		if speed_level_index > max_speed_level_index:
			max_speed_level_index = speed_level_index
			max_speed_level = speed_level
	return max_speed_level


static func scenario_path(scenario_name: String) -> String:
	return "res://assets/main/puzzle/scenarios/%s.json" % (scenario_name.replace("_", "-"))


static func scenario_name(path: String) -> String:
	return path.get_file().trim_suffix(".json").replace("_", "-")


static func scenario_filename(scenario_name: String) -> String:
	return "%s.json" % scenario_name.replace("_", "-")
