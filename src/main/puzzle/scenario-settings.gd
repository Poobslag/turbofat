class_name ScenarioSettings
"""
Contains settings for a 'scenario', such as trying to survive until level 100, or getting the highest score you can
get in 90 seconds.
"""

# The requirements to level up and make the game harder. This mostly applies to 'Marathon Mode' where clearing
# lines makes you level up.
var level_up_conditions := []

# The requirements to 'win'. This can be a line, score, or time requirement.
var win_condition: Dictionary

# The scenario name, used internally for saving/loading data.
var name := ""

func _init() -> void:
	set_start_level(PieceSpeeds.beginner_level_0)
	set_win_condition("none", 0)


"""
Sets the scenario name, used internally for saving/loading data.
"""
func set_name(new_name: String) -> void:
	name = new_name


"""
Sets how fast the pieces move when the player begins the scenario.
"""
func set_start_level(pieceSpeed) -> void:
	level_up_conditions.clear()
	level_up_conditions.append({"type": "lines", "value": 0, "piece_speed": pieceSpeed})


"""
Adds criteria for when the player 'levels up' and makes the pieces move faster.
"""
func add_level_up(type: String, value: int, pieceSpeed) -> void:
	level_up_conditions.append({"type": type, "value": value, "piece_speed": pieceSpeed})


"""
Sets the criteria for 'winning' which might be a time, score, or line limit.
"""
func set_win_condition(type: String, value: int, lenient_value: int = -1) -> void:
	if lenient_value == -1:
		lenient_value = value
	win_condition = {"type": type, "value": value, "lenient_value": lenient_value}
