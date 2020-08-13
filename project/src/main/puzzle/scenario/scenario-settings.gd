class_name ScenarioSettings
"""
Contains settings for a scenario.

This includes information about how the player loses/wins, what kind of pieces they're given, whether they're given a
time limit, and any other special rules.
"""

# Current version for saved scenario data. Should be updated if and only if the scenario format changes.
# This version number follows a 'ymdh' hex date format which is documented in issue #234.
const SCENARIO_DATA_VERSION := "15d2"

# Blocks/boxes which begin on the playfield.
var blocks_start := BlocksStartRules.new()

# Blocks/boxes which appear or disappear while the game is going on.
var blocks_during := BlocksDuringRules.new()

# Things that disrupt the player's combo.
var combo_break := ComboBreakRules.new()

# How the player finishes. When the player finishes, they can't play anymore, and the level just ends. It should be
# used for limits such as serving 5 creatures or clearing 10 lines. 
var finish_condition := Milestone.new()

# The requirements to level up and make the game harder. This mostly applies to 'Marathon Mode' where clearing lines
# makes you level up.
var level_ups := []

# How the player loses. The player usually loses if they top out a certain number of times, but some scenarios might
# have different rules.
var lose_condition := LoseConditionRules.new()

# The scenario name, used internally for saving/loading data.
var name := ""

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
	level_up.type = type
	level_up.value = value
	level_up.set_meta("level", level)
	level_ups.append(level_up)


func reset() -> void:
	level_ups.clear()
	success_condition = Milestone.new()
	finish_condition = Milestone.new()
	name = ""


func set_start_level(new_start_level: String) -> void:
	level_ups.clear()
	add_level_up(Milestone.LINES, 0, new_start_level)


"""
Sets the criteria for finishing the scenario, such as a time, score, or line goal.
"""
func set_finish_condition(type: int, value: int, lenient_value: int = -1) -> void:
	finish_condition = Milestone.new()
	finish_condition.type = type
	finish_condition.value = value
	if lenient_value > -1:
		finish_condition.set_meta("lenient_value", lenient_value)


"""
Sets the criteria for succeeding, such as a time or score goal.
"""
func set_success_condition(type: int, value: int) -> void:
	success_condition = Milestone.new()
	success_condition.type = type
	success_condition.value = value


"""
Populates this object with json data.

Parameters:
	'new_name': The scenario name used for saving statistics.
"""
func from_json_dict(new_name: String, json: Dictionary) -> void:
	name = new_name
	if json.get("version") != SCENARIO_DATA_VERSION:
		push_warning("Unrecognized scenario data version: '%s'" % json.get("version"))
	
	set_start_level(json["start-level"])
	if json.has("blocks-start"):
		blocks_start.from_json_dict(json["blocks-start"])
	if json.has("blocks-during"):
		blocks_during.from_json_string_array(json["blocks-during"])
	if json.has("combo-break"):
		combo_break.from_json_string_array(json["combo-break"])
	if json.has("finish-condition"):
		finish_condition.from_json_dict(json["finish-condition"])
	if json.has("level-ups"):
		for json_level_up in json["level-ups"]:
			var level_up := Milestone.new()
			level_up.from_json_dict(json_level_up)
			level_ups.append(level_up)
	if json.has("lose-condition"):
		lose_condition.from_json_string_array(json["lose-condition"])
	if json.has("other"):
		other.from_json_string_array(json["other"])
	if json.has("piece-types"):
		piece_types.from_json_string_array(json["piece-types"])
	if json.has("rank"):
		rank.from_json_string_array(json["rank"])
	if json.has("score"):
		score.from_json_string_array(json["score"])
	if json.has("success-condition"):
		success_condition.from_json_dict(json["success-condition"])


func load_from_resource(new_name: String) -> void:
	load_from_text(new_name, FileUtils.get_file_as_text(scenario_path(new_name)))


func load_from_text(new_name: String, text: String) -> void:
	from_json_dict(new_name, parse_json(text))


"""
Loads a scenario based on the creature's chat selectors.

Parameters:
	'creature': The creature whose level should be loaded.
	
	'level_int': Which level should be loaded; '1' is the first level.
"""
func load_from_creature(creature: Creature, level_int: int) -> void:
	var level_names := creature.get_level_names()
	var level_name: String = level_names[level_int - 1]
	load_from_resource(level_name)


static func scenario_path(scenario_name: String) -> String:
	return "res://assets/main/puzzle/scenario/%s.json" % scenario_name


static func scenario_name(path: String) -> String:
	return path.get_file().trim_suffix(".json")


static func scenario_filename(scenario_name: String) -> String:
	return "%s.json" % scenario_name
