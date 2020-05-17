extends Node
"""
Stores the player's score for the current puzzle.

This includes persistent data such as how long they survived, how many lines they cleared, and their score. This data
is written eventually to the save file.

This also includes transient data such as the current customer/bonus score. This is used visually, but never saved.
"""

signal score_changed(value)
signal bonus_score_changed(value)
signal customer_score_changed(value)

# Player's performance on the current scenario
var scenario_performance := ScenarioPerformance.new()

# Bonus points awarded during the current combo. This only includes bonuses
# and should be a round number like +55 or +130 for visual aesthetics.
var bonus_score := 0

# The scores for each customer in the current scenario (bonuses and line clears)
var customer_scores := [0]

"""
Adds points for clearing a line.

Increments persistent data for the current scenario and transient data displayed on the screen.

Parameters:
	'combo_score': Bonus points for the current combo.
	'box_score': Bonus points for any boxes in the line.
"""
func add_line_score(combo_score: int, box_score: int) -> void:
	scenario_performance.lines += 1
	scenario_performance.combo_score += combo_score
	scenario_performance.box_score += box_score
	
	_add_score(1)
	_add_bonus_score(combo_score + box_score)
	_add_customer_score(1 + combo_score + box_score)


"""
Ends the current combo, incrementing the score and resetting the bonus/customer scores to zero.
"""
func end_combo() -> void:
	_add_score(bonus_score)
	
	bonus_score = 0
	emit_signal("bonus_score_changed", 0)
	
	customer_scores.append(0)
	emit_signal("customer_score_changed", 0)


"""
Reset all score data, such as when starting a scenario over.
"""
func reset() -> void:
	scenario_performance = ScenarioPerformance.new()
	emit_signal("score_changed", 0)
	
	bonus_score = 0
	emit_signal("bonus_score_changed", 0)
	
	customer_scores = [0]


func get_score() -> int:
	return scenario_performance.score


func get_bonus_score() -> int:
	return bonus_score


func get_customer_score() -> int:
	return customer_scores[customer_scores.size() - 1]


func _add_score(delta: int) -> void:
	scenario_performance.score += delta
	emit_signal("score_changed", get_score())


func _add_bonus_score(delta: int) -> void:
	bonus_score += delta
	emit_signal("bonus_score_changed", bonus_score)


func _add_customer_score(delta: int) -> void:
	customer_scores[customer_scores.size() - 1] += delta
	emit_signal("customer_score_changed", get_customer_score())
