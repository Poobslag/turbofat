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
	
	func _init():
		set_start_level(PieceSpeeds.beginner_level_0)
		set_win_condition("none", 0)
	
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
	# total number of seconds for the current game
	var seconds := 0.0
	
	# raw number of cleared lines for the current game, not counting any bonus points
	var lines := 0
	
	# total number of bonus points awarded in the current game by clearing boxes
	var box_score := 0
	
	# total number of bonus points awarded in the current game for combos
	var combo_score := 0
	
	# overall score
	var score := 0
	
	func clear() -> void:
		seconds = 0
		lines = 0
		box_score = 0
		combo_score = 0
		score = 0

var scenario := Scenario.new()
var scenario_performance := ScenarioPerformance.new()