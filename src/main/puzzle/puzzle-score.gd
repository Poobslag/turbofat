extends Node
"""
Stores the player's score for the current puzzle.

This includes persistent data such as how long they survived, how many lines they cleared, and their score. This data
is written eventually to the save file.

This also includes transient data such as the current customer/combo score. This is used visually, but never saved.
"""

signal score_changed(new_score)
signal combo_score_changed(new_combo_score)
signal customer_score_changed(new_customer_score)

# The player's performance on the current scenario
var scenario_performance := ScenarioPerformance.new()

# Bonus points awarded during the current combo. This only includes bonuses
# and should be a round number like +55 or +130 for visual aesthetics.
var combo_score := 0

# The scores for each customer in the current scenario (bonuses and line clears)
var customer_scores := [0]

func add_score(delta: int) -> void:
	scenario_performance.score += delta
	emit_signal("score_changed", get_score())


func add_combo_score(delta: int) -> void:
	combo_score += delta
	emit_signal("combo_score_changed", combo_score)


func add_customer_score(delta: int) -> void:
	customer_scores[customer_scores.size() - 1] += delta
	emit_signal("customer_score_changed", get_customer_score())


"""
Ends the current combo, incrementing the score and resetting the combo/customer scores to zero.
"""
func end_combo() -> void:
	add_score(combo_score)
	
	combo_score = 0
	emit_signal("combo_score_changed", 0)
	
	customer_scores.append(0)
	emit_signal("customer_score_changed", 0)


"""
Reset all score data, such as when starting a scenario over.
"""
func reset() -> void:
	scenario_performance = ScenarioPerformance.new()
	emit_signal("score_changed", 0)
	
	combo_score = 0
	emit_signal("combo_score_changed", 0)
	
	customer_scores = [0]


func get_score() -> int:
	return scenario_performance.score


func get_combo_score() -> int:
	return combo_score


func get_customer_score() -> int:
	return customer_scores[customer_scores.size() - 1]
