"""
Contains global variables for preserving state when loading different scenes.
"""
extends Node

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
	
	func _init():
		set_start_level(PieceSpeeds.beginner_level_0)
		set_win_condition("none", 0)
	
	"""
	Sets the scenario name, used internally for saving/loading data.
	"""
	func set_name(new_name: String):
		name = new_name
	
	"""
	Sets how fast the pieces move when the player begins the scenario.
	"""
	func set_start_level(pieceSpeed):
		level_up_conditions.clear()
		level_up_conditions.append({"type": "lines", "value": 0, "piece_speed": pieceSpeed})
	
	"""
	Adds criteria for when the player 'levels up' and makes the pieces move faster.
	"""
	func add_level_up(type: String, value: int, pieceSpeed):
		level_up_conditions.append({"type": type, "value": value, "piece_speed": pieceSpeed})
	
	"""
	Sets the criteria for 'winning' which might be a time, score, or line limit.
	"""
	func set_win_condition(type: String, value: int, lenient_value: int = -1):
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

var scenario := Scenario.new()
var scenario_performance := ScenarioPerformance.new()

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

# How long it takes a customer to grow to a new size
const CUSTOMER_GROWTH_SECONDS := 0.12

# How large customers can grow; 5.0 = 5x normal size
const MAX_FATNESS := 10.0

# String to display if the player scored worse than the lowest grade
const NO_GRADE := "-"

# Palettes used for recoloring customers
const CUSTOMER_DEFS := [
	{"line_rgb": "6c4331", "body_rgb": "b23823", "eye_rgb": "282828 dedede", "horn_rgb": "f1e398"}, # dark red
	{"line_rgb": "6c4331", "body_rgb": "eeda4d", "eye_rgb": "c0992f f1e398", "horn_rgb": "f1e398"}, # yellow
	{"line_rgb": "6c4331", "body_rgb": "41a740", "eye_rgb": "c09a2f f1e398", "horn_rgb": "f1e398"}, # dark green
	{"line_rgb": "6c4331", "body_rgb": "b47922", "eye_rgb": "7d4c21 e5cd7d", "horn_rgb": "f1e398"}, # brown
	{"line_rgb": "6c4331", "body_rgb": "6f83db", "eye_rgb": "374265 eaf2f4", "horn_rgb": "f1e398"}, # light blue
	{"line_rgb": "6c4331", "body_rgb": "a854cb", "eye_rgb": "4fa94e dbe28e", "horn_rgb": "f1e398"}, # purple
	{"line_rgb": "6c4331", "body_rgb": "f57e7d", "eye_rgb": "7ac252 e9f4dc", "horn_rgb": "f1e398"}, # light red
	{"line_rgb": "6c4331", "body_rgb": "f9bb4a", "eye_rgb": "f9a74c fff6df", "horn_rgb": "b47922"}, # orange
	{"line_rgb": "6c4331", "body_rgb": "8fea40", "eye_rgb": "f5d561 fcf3cd", "horn_rgb": "b47922"}, # light green
	{"line_rgb": "6c4331", "body_rgb": "feceef", "eye_rgb": "ffddf4 ffffff", "horn_rgb": "ffffff"}, # pink
	{"line_rgb": "6c4331", "body_rgb": "b1edee", "eye_rgb": "c1f1f2 ffffff", "horn_rgb": "ffffff"}, # cyan
	{"line_rgb": "6c4331", "body_rgb": "f9f7d9", "eye_rgb": "91e6ff ffffff", "horn_rgb": "ffffff"}, # white
	{"line_rgb": "3c3c3d", "body_rgb": "1a1a1e", "eye_rgb": "b8260b f45e40", "horn_rgb": "282828"}, # black
	{"line_rgb": "6c4331", "body_rgb": "7a8289", "eye_rgb": "f5f0d1 ffffff", "horn_rgb": "282828"}, # grey
	{"line_rgb": "41281e", "body_rgb": "0b45a6", "eye_rgb": "fad541 ffffff", "horn_rgb": "282828"}  # dark blue
]
