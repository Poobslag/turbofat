extends Node
"""
Stores the player's score for the current puzzle.

This includes persistent data such as how long they survived, how many lines they cleared, and their score. This data
is written eventually to the save file.

This also includes transient data such as the current creature/bonus score. This is used visually, but never saved.
"""

# emitted when the game will start soon. Everything should be erased and reset to zero.
signal game_prepared

# emitted after everything's been erased in preparation for a new game.
signal after_game_prepared

signal game_started

# emitted when the player survives until the end the level.
signal finish_triggered

signal game_ended

# emitted several seconds after the game ends
signal after_game_ended

signal level_index_changed(value)

signal score_changed

signal combo_ended

enum EndResult {
	WON, # The player succeeded.
	FINISHED, # The player survived until the end.
	LOST, # The player gave up or failed.
}

const LOST := EndResult.LOST
const FINISHED := EndResult.FINISHED
const WON := EndResult.WON

# Player's performance on the current scenario
var scenario_performance := PuzzlePerformance.new()

# The scores for each creature in the current scenario (bonuses and line clears)
var creature_scores := [0]

# Bonus points awarded during the current combo. This only includes bonuses
# and should be a round number like +55 or +130 for visual aesthetics.
var bonus_score := 0

# 'true' if the player has started a game which is still running.
var game_active: bool

# 'true' if the player has started a game, or the countdown is currently active.
var game_prepared: bool

# the level the player is currently on, if the scenario has different levels.
var level_index: int setget set_level_index

"""
Resets all score data, and starts a new game after a brief pause.
"""
func prepare_and_start_game() -> void:
	_prepare_game()
	yield(get_tree().create_timer(1.4), "timeout")
	_start_game()


func set_level_index(new_level_index: int) -> void:
	if new_level_index == level_index:
		return
	level_index = new_level_index
	emit_signal("level_index_changed", level_index)


func end_game() -> void:
	game_prepared = false
	game_active = false
	end_combo()
	emit_signal("game_ended")
	yield(get_tree().create_timer(4.2 if PuzzleScore.WON else 2.2), "timeout")
	emit_signal("after_game_ended")


"""
Triggers the 'finish' phase of the game when the player clears the level.

Remaining lines are cleared and the player's awarded points. These points count towards their score, but don't
help/hurt things like their box rank or combo rank. It's mostly to put on a show and help them feel like their work
wasn't wasted, if they built a lot of boxes they didn't clear.
"""
func trigger_finish() -> void:
	game_active = false
	emit_signal("finish_triggered")


"""
Adds points for clearing a line.

Increments persistent data for the current scenario and transient data displayed on the screen.

Parameters:
	'combo_score': Bonus points for the current combo.
	'box_score': Bonus points for any boxes in the line.
"""
func add_line_score(combo_score: int, box_score: int) -> void:
	if Scenario.settings.other.tutorial:
		# no money earned during tutorial
		return
	
	if game_active:
		scenario_performance.combo_score += combo_score
		scenario_performance.box_score += box_score
		_add_line()
	else:
		# boxes left on the screen count towards a 'finish_score'
		scenario_performance.leftover_score += combo_score + box_score + 1
	
	_add_creature_score(1 + combo_score + box_score)
	_add_bonus_score(combo_score + box_score)
	_add_score(1)

	emit_signal("score_changed")


"""
Ends the current combo, incrementing the score and resetting the bonus/creature scores to zero.
"""
func end_combo() -> void:
	if Scenario.settings.other.tutorial:
		# tutorial only has one creature
		pass
	elif get_creature_score() == 0:
		# don't add $0 creatures. creatures don't pay if they owe $0
		pass
	else:
		creature_scores.append(0)
	
	_add_score(bonus_score)
	bonus_score = 0
		
	emit_signal("score_changed")
	emit_signal("combo_ended")


"""
Reset all score data, such as when starting a scenario over.
"""
func reset() -> void:
	creature_scores = [0]
	bonus_score = 0
	scenario_performance = PuzzlePerformance.new()
	level_index = 0
	
	emit_signal("score_changed")
	emit_signal("level_index_changed", 0)


func get_score() -> int:
	return scenario_performance.score


func get_lines() -> int:
	return scenario_performance.lines


func get_bonus_score() -> int:
	return bonus_score


func get_creature_score() -> int:
	return creature_scores[creature_scores.size() - 1]


func end_result() -> int:
	if scenario_performance.lost:
		return LOST
	elif MilestoneManager.milestone_met(Scenario.settings.success_condition):
		return WON
	else:
		return FINISHED


func _prepare_game() -> void:
	if game_prepared:
		return
	
	if Scenario.settings.other.start_scenario_name:
		# Load a different scenario to start (used for tutorials)
		var new_settings := ScenarioSettings.new()
		new_settings.load_from_resource(Scenario.settings.other.start_scenario_name)
		Scenario.start_scenario(new_settings)
	
	game_prepared = true
	reset()
	emit_signal("game_prepared")
	emit_signal("after_game_prepared")


func _start_game() -> void:
	if game_active:
		return
	
	game_active = true
	emit_signal("game_started")


func _add_score(delta: int) -> void:
	scenario_performance.score += delta


func _add_bonus_score(delta: int) -> void:
	bonus_score += delta


func _add_line() -> void:
	scenario_performance.lines += 1


func _add_creature_score(delta: int) -> void:
	creature_scores[creature_scores.size() - 1] += delta
