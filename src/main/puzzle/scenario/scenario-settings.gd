class_name ScenarioSettings
"""
Contains settings for a scenario.

This includes information about how the player loses/wins, what kind of pieces they're given, whether they're given a
time limit, and any other special rules.
"""

# Blocks/boxes which begin on the playfield.
var blocks_start := BlocksStart.new()

# Things that disrupt the player's combo.
var combo_break := ComboBreakRules.new()

# How the player finishes. When the player finishes, they can't play anymore, and the level just ends. It should be
# used for limits such as serving 5 customers or clearing 10 lines. 
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

# How the player wins. When the player wins, there's a big fanfare and celebration, it should be used for
# accomplishments such as surviving 10 minutes or getting 1,000 points. 
var win_condition := Milestone.new()

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
	win_condition = Milestone.new()
	finish_condition = Milestone.new()
	name = ""


func set_start_level(level: String) -> void:
	level_ups.clear()
	add_level_up(Milestone.LINES, 0, level)


"""
Sets the criteria for finishing the scenario, such as a time, score, or line goal.
"""
func set_finish_condition(type: int, value: int) -> void:
	finish_condition = Milestone.new()
	finish_condition.type = type
	finish_condition.value = value


"""
Sets the criteria for winning the scenario, such as a time, score, or line goal.
"""
func set_win_condition(type: int, value: int, lenient_value: int = -1) -> void:
	win_condition = Milestone.new()
	win_condition.type = type
	win_condition.value = value
	if lenient_value > -1:
		win_condition.set_meta("lenient_value", lenient_value)


"""
Returns either the win or finish condition, whichever is defined.

If both are defined, the win condition takes precedence.
"""
func get_winish_condition() -> Milestone:
	return win_condition if win_condition.type != Milestone.NONE else finish_condition


"""
Populates this object with json data.

Parameters:
	'new_name': The scenario name used for saving statistics.
"""
func from_json_dict(new_name: String, json: Dictionary) -> void:
	name = new_name
	set_start_level(json["start-level"])
	if json.has("blocks-start"):
		blocks_start.from_json_dict(json["blocks-start"])
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
	if json.has("win-condition"):
		win_condition.from_json_dict(json["win-condition"])
