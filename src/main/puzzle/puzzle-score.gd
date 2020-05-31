extends Node
"""
Stores the player's score for the current puzzle.

This includes persistent data such as how long they survived, how many lines they cleared, and their score. This data
is written eventually to the save file.

This also includes transient data such as the current customer/bonus score. This is used visually, but never saved.
"""

# emitted when the game will start soon. Everything should be erased and reset to zero.
signal game_prepared

# emitted after everything's been erased in preparation for a new game.
signal after_game_prepared

# emitted after the scenario has customized the puzzle's settings.
signal after_scenario_prepared

signal game_started
signal game_ended
signal level_index_changed(value)

# These four signals are always emitted in this order: customer_score, bonus_score, score, lines
signal customer_score_changed(value)
signal bonus_score_changed(value)
signal score_changed(value)
signal lines_changed(value)

signal combo_ended

# Player's performance on the current scenario
var scenario_performance := ScenarioPerformance.new()

# The scores for each customer in the current scenario (bonuses and line clears)
var customer_scores := [0]

# Bonus points awarded during the current combo. This only includes bonuses
# and should be a round number like +55 or +130 for visual aesthetics.
var bonus_score := 0

# 'true' if the player has started a game which is still running.
var game_active: bool

# 'true' if the player has started a game, or the countdown is currently active.
var game_prepared: bool

var level_index: int setget set_level_index

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
	reset()
	emit_signal("game_prepared")
	emit_signal("after_game_prepared")
	emit_signal("after_scenario_prepared")


func set_level_index(new_level_index: int) -> void:
	if new_level_index == level_index:
		return
	level_index = new_level_index
	emit_signal("level_index_changed", level_index)


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
	if not game_active or Global.scenario_settings.other.tutorial:
		# no money earned during tutorial
		return
	
	scenario_performance.combo_score += combo_score
	scenario_performance.box_score += box_score
	
	_add_customer_score(1 + combo_score + box_score)
	_add_bonus_score(combo_score + box_score)
	_add_score(1)
	_add_line()

	emit_signal("customer_score_changed", get_customer_score())
	emit_signal("bonus_score_changed", get_bonus_score())
	emit_signal("score_changed", get_score())
	emit_signal("lines_changed", get_lines())


"""
Ends the current combo, incrementing the score and resetting the bonus/customer scores to zero.
"""
func end_combo() -> void:
	if Global.scenario_settings.other.tutorial:
		# tutorial only has one customer
		pass
	elif get_customer_score() == 0:
		# don't add $0 customers. customers don't pay if they owe $0
		pass
	else:
		customer_scores.append(0)
	
	_add_score(bonus_score)
	bonus_score = 0
		
	emit_signal("customer_score_changed", 0)
	emit_signal("bonus_score_changed", get_bonus_score())
	emit_signal("score_changed", get_score())
	emit_signal("combo_ended")


"""
Reset all score data, such as when starting a scenario over.
"""
func reset() -> void:
	customer_scores = [0]
	bonus_score = 0
	scenario_performance = ScenarioPerformance.new()
	level_index = 0
	
	emit_signal("customer_score_changed")
	emit_signal("bonus_score_changed", 0)
	emit_signal("score_changed", 0)
	emit_signal("lines_changed", 0)
	emit_signal("level_index_changed", 0)


func get_score() -> int:
	return scenario_performance.score


func get_lines() -> int:
	return scenario_performance.lines


func get_bonus_score() -> int:
	return bonus_score


func get_customer_score() -> int:
	return customer_scores[customer_scores.size() - 1]


"""
Returns 'true' if the player has met the specified milestone.
"""
func milestone_met(milestone: Milestone) -> bool:
	var result := false
	var progress := milestone_progress(milestone)
	match milestone.type:
		Milestone.NONE:
			result = false
		Milestone.TIME_UNDER:
			result = progress <= milestone.value
		_:
			result = progress >= milestone.value
	return result


"""
Returns the player's current progress toward the specified milestone.
"""
func milestone_progress(milestone: Milestone) -> float:
	var progress: float
	match milestone.type:
		Milestone.CUSTOMERS:
			progress = PuzzleScore.customer_scores.size() - 1
		Milestone.LINES:
			progress = PuzzleScore.scenario_performance.lines
		Milestone.SCORE:
			progress = PuzzleScore.get_score() + PuzzleScore.get_bonus_score()
		Milestone.TIME_OVER, Milestone.TIME_UNDER:
			progress = PuzzleScore.scenario_performance.seconds
	return progress


func _add_score(delta: int) -> void:
	scenario_performance.score += delta


func _add_bonus_score(delta: int) -> void:
	bonus_score += delta


func _add_line() -> void:
	scenario_performance.lines += 1


func _add_customer_score(delta: int) -> void:
	customer_scores[customer_scores.size() - 1] += delta
