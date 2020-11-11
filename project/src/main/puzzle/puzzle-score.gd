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

# emitter after the initial countdown finishes, when the player can start playing.
signal game_started

# emitted during tutorials, when changing from one tutorial section to the next
signal before_level_changed(new_level_id)
signal after_level_changed

# emitted when the player survives until the end the level.
signal finish_triggered

# emitted when the player reaches the end of a tutorial section
signal tutorial_section_finished

signal game_ended

# emitted several seconds after the game ends
signal after_game_ended

signal speed_index_changed(value)

signal added_line_score(combo_score, box_score)

# emitted on the frame that the player drops and locks a new piece
signal before_piece_written

# emitted after the piece is written, and all boxes are made, and all lines are cleared
signal after_piece_written

signal score_changed

# emitted when a combo value changes, when building or ending a combo
signal combo_changed(value)

# emitted when a combo ends -- this will usually coincide with the combo resetting to zero, but at the end of a level
# it's possible for a combo to end without being reset to zero.
signal combo_ended

# emitted when the current piece can't be placed in the _playfield
signal topped_out

enum EndResult {
	WON, # The player was successful.
	FINISHED, # The player survived until the end.
	LOST, # The player gave up or failed.
}

const DELAY_NONE := 0.00
const DELAY_SHORT := 2.35
const DELAY_LONG := 4.70

const LOST := EndResult.LOST
const FINISHED := EndResult.FINISHED
const WON := EndResult.WON

const READY_DURATION := 1.4

# the current input frame for recording/replaying the player's inputs. a value of '-1' indicates that no input should
# be recorded or replayed yet.
var input_frame := -1

# Player's performance on the current level
var level_performance := PuzzlePerformance.new()

# The scores for each creature in the current level (bonuses and line clears)
var creature_scores := [0]

# The number of lines the player has cleared without dropping their combo
var combo := 0 setget set_combo

# Bonus points awarded during the current combo. This only includes bonuses
# and should be a round number like +55 or +130 for visual aesthetics.
var bonus_score := 0

# 'true' if the player has started a game which is still running.
var game_active: bool

# 'true' if the player survived until the end the level.
var finish_triggered: bool

# 'true' if the end has been triggered by dying or meeting a finish condition
var game_ended: bool

# the speed the player is currently on, if the level has different speeds.
var speed_index: int setget set_speed_index

# This is true if the final customer has been fed and we shouldn't rotate to any other customers. It also gets used
# for tutorials to prevent the instructor from leaving.
var no_more_customers: bool

func _physics_process(_delta: float) -> void:
	if input_frame < 0:
		# if input_frame is negative, we preserve its value. a negative value indicates that no input should be
		# recorded or replayed yet.
		pass
	else:
		input_frame += 1


"""
Resets all score data, and starts a new game after a brief pause.
"""
func prepare_and_start_game() -> void:
	_prepare_game()
	
	if Level.settings.other.skip_intro:
		# when skipping the intro, we don't pause between preparing/starting the game
		pass
	else:
		yield(get_tree().create_timer(READY_DURATION), "timeout")
		if get_tree().paused:
			# If the player pauses during the initial countdown, we wait to start until the game is unpaused.
			yield(Pauser, "paused_changed")
	
	_start_game()


func set_speed_index(new_speed_index: int) -> void:
	if new_speed_index == speed_index:
		return
	speed_index = new_speed_index
	emit_signal("speed_index_changed", speed_index)


func top_out() -> void:
	level_performance.top_out_count += 1
	if level_performance.top_out_count >= Level.settings.lose_condition.top_out:
		make_player_lose()
	emit_signal("topped_out")


func make_player_lose() -> void:
	if not game_active:
		return
	if not Level.settings.lose_condition.finish_on_lose:
		level_performance.lost = true
	end_game()


func end_game() -> void:
	game_active = false
	game_ended = true
	
	end_combo()
	if not level_performance.lost:
		level_performance.success = MilestoneManager.milestone_met(Level.settings.success_condition)
	emit_signal("game_ended")
	yield(get_tree().create_timer(4.2 if WON else 2.2), "timeout")
	emit_signal("after_game_ended")


func change_level(level_id: String, delay_between_levels: float = DELAY_SHORT) -> void:
	emit_signal("before_level_changed", level_id)
	
	if delay_between_levels:
		yield(get_tree().create_timer(delay_between_levels), "timeout")
	
	var settings := LevelSettings.new()
	settings.load_from_resource(level_id)
	Level.switch_level(settings)
	# initialize input_frame to allow for recording/replaying inputs
	input_frame = 0
	emit_signal("after_level_changed")


"""
Triggers the 'finish' phase of the game when the player clears the level.

Remaining lines are cleared and the player's awarded points. These points count towards their score, but don't
help/hurt things like their box rank or combo rank. It's mostly to put on a show and help them feel like their work
wasn't wasted, if they built a lot of boxes they didn't clear.
"""
func trigger_finish() -> void:
	if Level.settings.other.tutorial:
		emit_signal("tutorial_section_finished")
	else:
		game_active = false
		finish_triggered = true
		emit_signal("finish_triggered")


"""
Adds points for clearing a line.

Increments persistent data for the current level and transient data displayed on the screen.

Parameters:
	'combo_score': Bonus points for the current combo.
	'box_score': Bonus points for any boxes in the line.
"""
func add_line_score(combo_score: int, box_score: int) -> void:
	if game_active:
		level_performance.combo_score += combo_score
		level_performance.box_score += box_score
		_add_line()
	else:
		# boxes left on the screen count towards a 'finish_score'
		level_performance.leftover_score += combo_score + box_score + 1
	
	combo += 1
	_add_creature_score(1 + combo_score + box_score)
	_add_bonus_score(combo_score + box_score)
	_add_score(1)
	
	emit_signal("added_line_score", combo_score, box_score)
	emit_signal("score_changed")
	emit_signal("combo_changed", combo)


"""
Ends the current combo, incrementing the score and resetting the bonus/creature scores to zero.
"""
func end_combo() -> void:
	var old_combo := combo
	if Level.settings.other.tutorial:
		# during tutorials, reset the combo and line clears
		creature_scores[creature_scores.size() - 1] = 0
		combo = 0
	elif no_more_customers:
		pass
	elif get_creature_score() == 0:
		# don't add $0 creatures. creatures don't pay if they owe $0
		pass
	elif Level.settings.finish_condition.type == Milestone.CUSTOMERS \
			and PuzzleScore.creature_scores.size() >= Level.settings.finish_condition.value:
		# some levels have a limited number of customers
		no_more_customers = true
	else:
		creature_scores.append(0)
		combo = 0
	
	_add_score(bonus_score)
	bonus_score = 0
	
	emit_signal("score_changed")
	if old_combo != combo:
		emit_signal("combo_changed", combo)
	emit_signal("combo_ended")


"""
Reset all score data, such as when starting a level over.
"""
func reset() -> void:
	creature_scores = [0]
	combo = 0
	bonus_score = 0
	level_performance = PuzzlePerformance.new()
	speed_index = 0
	no_more_customers = Level.settings.other.tutorial
	input_frame = -1
	
	emit_signal("score_changed")
	emit_signal("speed_index_changed", 0)


func get_score() -> int:
	return level_performance.score


func get_lines() -> int:
	return level_performance.lines


func get_bonus_score() -> int:
	return bonus_score


func get_creature_score() -> int:
	return creature_scores[creature_scores.size() - 1]


func set_combo(new_combo: int) -> void:
	if combo == new_combo:
		# don't emit a signal if the combo doesn't change
		return
	
	combo = new_combo
	emit_signal("combo_changed", combo)


func end_result() -> int:
	if level_performance.lost:
		return LOST
	elif MilestoneManager.milestone_met(Level.settings.success_condition):
		return WON
	else:
		return FINISHED


func before_piece_written() -> void:
	level_performance.pieces += 1
	emit_signal("before_piece_written")


func after_piece_written() -> void:
	if finish_triggered and not game_ended:
		end_game()
	emit_signal("after_piece_written")


func _prepare_game() -> void:
	game_active = false
	finish_triggered = false
	game_ended = false
	
	if Level.settings.other.start_level:
		# Load a different level to start (used for tutorials)
		var new_settings := LevelSettings.new()
		new_settings.load_from_resource(Level.settings.other.start_level)
		Level.start_level(new_settings)
	
	reset()
	emit_signal("game_prepared")
	emit_signal("after_game_prepared")


func _start_game() -> void:
	if game_active:
		return
	
	game_active = true
	# initialize input_frame to allow for recording/replaying inputs
	input_frame = 0
	emit_signal("game_started")


func _add_score(delta: int) -> void:
	level_performance.score += delta


func _add_bonus_score(delta: int) -> void:
	bonus_score += delta


func _add_line() -> void:
	level_performance.lines += 1


func _add_creature_score(delta: int) -> void:
	creature_scores[creature_scores.size() - 1] += delta
