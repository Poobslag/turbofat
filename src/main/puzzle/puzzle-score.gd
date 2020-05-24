extends Node
"""
Stores the player's score for the current puzzle.

This includes persistent data such as how long they survived, how many lines they cleared, and their score. This data
is written eventually to the save file.

This also includes transient data such as the current customer/bonus score. This is used visually, but never saved.
"""

# Signal emitted when the game will start soon. Everything should be erased and reset to zero.
signal game_prepared
# Signal emitted after everything's been erased in preparation for a new game.
signal after_game_prepared
signal game_started
signal game_ended
signal score_changed(value)
signal bonus_score_changed(value)
signal customer_score_changed(value)
signal combo_ended

# Player's performance on the current scenario
var scenario_performance := ScenarioPerformance.new()

# Bonus points awarded during the current combo. This only includes bonuses
# and should be a round number like +55 or +130 for visual aesthetics.
var bonus_score := 0

# The scores for each customer in the current scenario (bonuses and line clears)
var customer_scores := [0]

# 'true' if the player has started a game which is still running.
var game_active: bool

# 'true' if the player has started a game, or the countdown is currently active.
var game_prepared: bool

"""
Resets all score data to prepare for a new game.
"""
func prepare_game() -> void:
	if game_prepared:
		return
	
	var new_scenario_name := Global.scenario_settings.other.start_scenario_name
	if new_scenario_name:
		# Load a different scenario to start (used for tutorials)
		Global.scenario_settings = ScenarioLibrary.load_scenario_from_name(new_scenario_name)
		Global.launched_scenario_name = Global.scenario_settings.name
	
	game_prepared = true
	scenario_performance = ScenarioPerformance.new()
	emit_signal("score_changed", 0)

	bonus_score = 0
	emit_signal("bonus_score_changed", 0)

	customer_scores = [0]
	emit_signal("game_prepared")
	emit_signal("after_game_prepared")


func start_game() -> void:
	if game_active:
		return
	game_active = true
	emit_signal("game_started")


func end_game() -> void:
	if not game_active:
		return
	game_prepared = false
	game_active = false
	end_combo()
	emit_signal("game_ended")


"""
Adds points for clearing a line.

Increments persistent data for the current scenario and transient data displayed on the screen.

Parameters:
	'combo_score': Bonus points for the current combo.
	'box_score': Bonus points for any boxes in the line.
"""
func add_line_score(combo_score: int, box_score: int) -> void:
	if not game_active:
		return
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
	
	if get_customer_score() == 0:
		# don't add $0 customers. customers don't pay if they owe $0
		pass
	elif Global.scenario_settings.other.tutorial:
		# tutorial only has one customer
		pass
	else:
		customer_scores.append(0)
		emit_signal("customer_score_changed", 0)
		emit_signal("combo_ended")


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
