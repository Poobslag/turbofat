"""
Contains global variables for preserving state when loading different scenes.
"""
extends Node

# String to display if the player scored worse than the lowest grade
const NO_GRADE := "-"

# The scenario currently being launched or played
var scenario := Scenario.new()

# The player's performance on the current scenario
var scenario_performance := ScenarioPerformance.new()

# Stores all of the benchmarks which have been started
var _benchmark_start_times := Dictionary()

"""
Contains settings for a 'scenario', such as trying to survive until level 100, or getting the highest score you can
get in 90 seconds.
"""
class Scenario:
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

"""
Stores statistics for how well the player performed in their current game. This includes how long they survived, how
many lines they cleared, and their score.
"""
class ScenarioPerformance:
	# number of seconds until the player won or lost
	var seconds := 0.0
	
	# raw number of cleared lines, not including bonus points
	var lines := 0
	
	# bonus points awarded for clearing boxes
	var box_score := 0
	
	# bonus points awarded for combos
	var combo_score := 0
	
	# overall score
	var score := 0
	
	# did the player die?
	var died := false

"""
Converts a numeric grade such as '12.6' into a grade string such as 'A+'.
"""
func grade(rank: float) -> String:
	if   rank <= 0:  return "M"
	elif rank <= 2:  return "S++"
	elif rank <= 3:  return "S+"
	elif rank <= 9:  return "S"
	elif rank <= 10: return "S-"
	elif rank <= 13: return "A+"
	elif rank <= 22: return "A"
	elif rank <= 23: return "A-"
	elif rank <= 26: return "B+"
	elif rank <= 33: return "B"
	elif rank <= 34: return "B-"
	elif rank <= 37: return "C+"
	elif rank <= 44: return "C"
	elif rank <= 45: return "C-"
	elif rank <= 48: return "D+"
	elif rank <= 58: return "D"
	elif rank <= 64: return "D-"
	else: return NO_GRADE

"""
Sets the start time for a benchmark. Calling 'benchmark_start(foo)' and 'benchmark_finish(foo)' will display a message
like 'foo took 123 milliseconds'.
"""
func benchmark_start(key: String = "") -> void:
	_benchmark_start_times[key] = OS.get_ticks_usec()

"""
Prints the amount of time which has passed since a benchmark was started. Calling 'benchmark_start(foo)' and
'benchmark_finish(foo)' will display a message like 'foo took 123 milliseconds'.
"""
func benchmark_end(key: String = "") -> void:
	if !_benchmark_start_times.has(key):
		print("Invalid benchmark: %s" % key)
		return
	print("benchmark %s: %.3f msec" % [key, (OS.get_ticks_usec() - _benchmark_start_times[key]) / 1000.0])
