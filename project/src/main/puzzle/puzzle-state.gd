extends Node
## Stores the player's score for the current puzzle.
##
## This includes persistent data such as how long they survived, how many lines they cleared, and their score. This
## data is written eventually to the save file.
##
## This also includes transient data such as the current creature/bonus score. This is used visually, but never saved.

## emitted when the game will start soon. Everything should be erased and reset to zero.
signal game_prepared

## emitted after everything's been erased in preparation for a new game.
signal after_game_prepared

## emitter after the initial countdown finishes, when the player can start playing.
signal game_started

## emitted during tutorials, when changing from one tutorial section to the next
signal before_level_changed(new_level_id)

signal after_level_changed

## emitted when the player survives until the end the level.
signal finish_triggered

## emitted when the player reaches the end of a tutorial section
signal tutorial_section_finished

signal game_ended

## emitted several seconds after the game ends
signal after_game_ended

signal speed_index_changed(value)

signal added_line_score(combo_score, box_score)
signal added_pickup_score(pickup_score)
signal added_unusual_cell_score(cell, cell_score)

## emitted on the frame that the player drops and locks a new piece
signal before_piece_written

## emitted after the piece is written, and all boxes are made, and all lines are cleared
signal after_piece_written

## emitted when the current piece can't be placed in the playfield, before TopOutTracker applies other penalties
signal before_topped_out

signal score_changed

## emitted when a combo value changes, when building or ending a combo
signal combo_changed(value)

## emitted when a combo ends -- this will usually coincide with the combo resetting to zero, but at the end of a level
## it's possible for a combo to end without being reset to zero.
signal combo_ended

## emitted when the current piece can't be placed in the playfield
signal topped_out

## emitted when the player enters or exits the non-terminal top out state -- the process where lines are deleted and
## re-filled
signal topping_out_changed(value)

const READY_DURATION := 1.4

## Number of points deducted from the player's score if they top out.
const TOP_OUT_PENALTY := 100

## current input frame for recording/replaying the player's inputs. a value of '-1' indicates that no input should
## be recorded or replayed yet.
var input_frame := -1

## Player's performance on the current level
var level_performance := PuzzlePerformance.new()

## Scores for each creature in the current level (bonuses and line clears)
var customer_scores := [0]

## Number of lines the player has cleared without dropping their combo
var combo := 0 setget set_combo

## Bonus points awarded during the current combo. This only includes bonuses
## and should be a round number like +55 or +130 for visual aesthetics.
var bonus_score := 0

## Points which contribute to the current customer's fatness. This is usually the same as
## bonus_score except for some edge cases at the end of the level.
var fatness_score := 0

## 'true' if the player has started a game which is still running.
var game_active: bool

## 'true' if the player finished this tutorial section.
var tutorial_section_finished: bool

## 'true' if the player survived until the end the level.
var finish_triggered: bool

## 'true' if the end has been triggered by dying or meeting a finish condition
var game_ended: bool

## speed the player is currently on, if the level has different speeds.
var speed_index: int setget set_speed_index

## This is true if the final customer has been fed and we shouldn't rotate to any other customers. It also gets used
## for tutorials to prevent the sensei from leaving.
var no_more_customers: bool

## Temporarily set to 'true' when the player retries a puzzle. This lets the music listener know not to stop the
## music, even though a puzzle is ending.
var retrying: bool

## 'True' if the player is going through the non-terminal top out process where lines are deleted and re-filled
var topping_out: bool setget set_topping_out

## Holds all temporary timers. These timers are not created by get_tree().create_timer() because we need to clean them
## up if the puzzle is interrupted. Otherwise for example, we might schedule a victory screen to appear 3 seconds from
## now, but then the player restarts the level, and the victory screen is shown after they've restarted.
onready var _timers: TimerGroup = $Timers

func _physics_process(_delta: float) -> void:
	if input_frame < 0:
		# if input_frame is negative, we preserve its value. a negative value indicates that no input should be
		# recorded or replayed yet.
		pass
	else:
		input_frame += 1


## Creates and starts a one-shot timer.
##
## This timer is freed when it times out or when the puzzle is interrupted.
##
## Parameters:
## 	'wait_time': The amount of time to wait. A value of '0.0' will result in an error.
##
## Returns:
## 	Timer which has been added to the scene tree, and is currently active.
func start_timer(wait_time: float) -> Timer:
	return _timers.start_timer(wait_time)


## Creates a one-shot timer, but does not start it.
##
## This timer is freed when it times out or when the puzzle is interrupted.
##
## Parameters:
## 	'wait_time': The amount of time to wait. A value of '0.0' will result in an error.
##
## Returns:
## 	Timer which has been added to the scene tree, but is not yet active.
func add_timer(wait_time: float) -> Timer:
	return _timers.add_timer(wait_time)


## Frees all timers.
func clear_timers() -> void:
	_timers.clear()


## Resets all score data, and starts a new game after a brief pause.
func prepare_and_start_game() -> void:
	_prepare_game()
	
	if CurrentLevel.settings.other.skip_intro:
		# when skipping the intro, we don't pause between preparing/starting the game
		_start_game()
	else:
		start_timer(READY_DURATION).connect("timeout", self, "_on_Timer_timeout_start_game")


func set_speed_index(new_speed_index: int) -> void:
	if new_speed_index == speed_index:
		return
	speed_index = new_speed_index
	emit_signal("speed_index_changed", speed_index)


func set_topping_out(new_topping_out: bool) -> void:
	if topping_out == new_topping_out:
		return
	topping_out = new_topping_out
	emit_signal("topping_out_changed", new_topping_out)


## Updates the player's score and statistics as a result of topping out.
##
## This ends the player's combo to account for the case where their score is less than the top-out penalty, but they
## have accumulated a large untabulated score on the current customer.
func apply_top_out_score_penalty() -> void:
	end_combo()
	level_performance.score = max(level_performance.score - TOP_OUT_PENALTY, 0)
	PuzzleState.level_performance.top_out_count += 1


## Makes the player top out, triggering any top out effects and score penalty.
##
## If the player is not out of lives, the game will still continue.
func top_out() -> void:
	var lost_last_life := false
	
	var new_top_out_count := level_performance.top_out_count + 1
	var max_top_out_count := CurrentLevel.settings.lose_condition.top_out
	
	if PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0:
		if not CurrentLevel.hardcore:
			max_top_out_count += PlayerData.career.extra_life_count
		new_top_out_count += PlayerData.career.top_out_count
	
	lost_last_life = new_top_out_count >= max_top_out_count
	
	if lost_last_life:
		PuzzleState.level_performance.top_out_count += 1
		make_player_lose()
	else:
		set_topping_out(true)
		apply_top_out_score_penalty()
		emit_signal("before_topped_out")
		emit_signal("topped_out")
		emit_signal("score_changed")


## Immediately ends the game, triggering any top out effects and score penalty. This is triggered when the player
## gives up or runs out of lives.
##
## For most levels, this sets the 'LevelPerformance.lost' flag -- the only exception being sandbox levels where it
## counts as finishing the level, even if the player quits.
func make_player_lose() -> void:
	if not game_active:
		return
	if not CurrentLevel.settings.lose_condition.finish_on_lose:
		# set the game inactive before ending combo/topping out, to avoid triggering gameplay and visual effects
		level_performance.lost = true
		game_active = false
		game_ended = true
		
		# trigger the visual effects for topping out, such as making the player go swirly eyed
		apply_top_out_score_penalty()
		# use up all of the players lives; especially for career mode, we don't want to reward players who give up
		PuzzleState.level_performance.top_out_count = CurrentLevel.settings.lose_condition.top_out
		emit_signal("before_topped_out")
		emit_signal("topped_out")
		emit_signal("score_changed")
	end_game()


## Immediately ends the game, triggering any other end-of-game effects.
##
## End-of-game effects include calculating the player's final score, restoring the menu background music and
## triggering the chef's reaction. End-of-game effects do not include clearing the player's remaining boxes -- this
## occurs before the game ends.
func end_game() -> void:
	# set the game inactive before ending combo/topping out, to avoid triggering gameplay and visual effects
	game_active = false
	game_ended = true
	end_combo()
	if not level_performance.lost:
		level_performance.success = MilestoneManager.is_met(CurrentLevel.settings.success_condition)
	_timers.clear()
	emit_signal("game_ended")
	var wait_time: float
	match end_result():
		Levels.Result.FINISHED, Levels.Result.LOST:
			wait_time = 2.2
		Levels.Result.WON:
			wait_time = 4.2
		Levels.Result.NONE:
			wait_time = 0.0
	
	if wait_time > 0.0:
		start_timer(wait_time).connect("timeout", self, "_on_Timer_timeout_emit_after_game_ended")
	else:
		emit_signal("after_game_ended")


## Signals a level transition.
##
## During tutorials, this notifies the player that this section is over. It also pauses time-sensitive puzzle logic.
func prepare_level_change(level_id: String) -> void:
	emit_signal("before_level_changed", level_id)


func change_level(level_id: String) -> void:
	var settings := LevelSettings.new()
	settings.load_from_resource(level_id)
	GameplayDifficultyAdjustments.adjust_milestones(settings)
	CurrentLevel.switch_level(settings)
	# initialize input_frame to allow for recording/replaying inputs
	input_frame = 0
	emit_signal("after_level_changed")


## Triggers the 'finish' phase of the game when the player clears the level.
##
## Remaining lines are cleared and the player's awarded points. These points count towards their score, but don't
## help/hurt things like their box rank or combo rank. It's mostly to put on a show and help them feel like their work
## wasn't wasted, if they built a lot of boxes they didn't clear.
func trigger_finish() -> void:
	if CurrentLevel.is_tutorial():
		tutorial_section_finished = true
		emit_signal("tutorial_section_finished")
	else:
		game_active = false
		finish_triggered = true
		emit_signal("finish_triggered")


## Adds points for clearing a line.
##
## Increments persistent data for the current level and transient data displayed on the screen.
##
## Parameters:
## 	'combo_score': Bonus points for the current combo.
## 	'box_score': Bonus points for any boxes in the line.
func add_line_score(combo_score: int, box_score: int) -> void:
	if game_active:
		level_performance.combo_score += combo_score
		level_performance.box_score += box_score
		_add_line()
	else:
		# boxes left on the screen count towards a 'leftover_score'
		level_performance.leftover_score += combo_score + box_score + 1
	
	combo += 1
	_add_customer_score(1 + combo_score + box_score)
	_add_bonus_score(combo_score + box_score)
	_add_score(1)
	
	emit_signal("added_line_score", combo_score, box_score)
	emit_signal("score_changed")
	emit_signal("combo_changed", combo)


## Adds points for collecting one or more pickups.
##
## Increments persistent data for the current level and transient data displayed on the screen.
func add_pickup_score(pickup_score: int) -> void:
	if game_active:
		level_performance.pickup_score += pickup_score
	
	_add_customer_score(pickup_score)
	_add_bonus_score(pickup_score)
	
	emit_signal("added_pickup_score", pickup_score)
	emit_signal("score_changed")


## Add points for clearing part of a box.
##
## This occurs during very specific levels with gimmicks like spears, which let you clear a part of a box without
## performing a line clear.
func add_box_score(box_score: int) -> void:
	if game_active:
		level_performance.box_score += box_score
	
	_add_customer_score(box_score)
	_add_bonus_score(box_score)
	
	emit_signal("score_changed")


## Adds points for doing something unusual in a cell.
##
## This occurs during very specific levels with gimmicks like sharks. It mostly gets treated the same way as pickups,
## but also triggers a money UI popup.
func add_unusual_cell_score(cell: Vector2, cell_score: int) -> void:
	PuzzleState.add_pickup_score(cell_score)
	emit_signal("added_unusual_cell_score", cell, cell_score)


## Ends the current combo, incrementing the score and resetting the bonus/creature scores to zero.
func end_combo() -> void:
	var old_combo := combo
	if CurrentLevel.is_tutorial():
		# during tutorials, reset the combo and line clears
		customer_scores[customer_scores.size() - 1] = 0
		combo = 0
	elif no_more_customers or game_ended:
		pass
	elif get_customer_score() == 0:
		# don't add $0 creatures. creatures don't pay if they owe $0
		pass
	elif CurrentLevel.settings.finish_condition.type == Milestone.CUSTOMERS \
			and customer_scores.size() >= CurrentLevel.settings.finish_condition.value:
		# some levels have a limited number of customers
		no_more_customers = true
	else:
		customer_scores.append(0)
		combo = 0
	
	_add_score(bonus_score)
	bonus_score = 0
	if no_more_customers:
		# For levels with limited customers, don't reset the fatness score. Otherwise creatures suddenly lose weight
		# during end-of-level line clears.
		pass
	else:
		fatness_score = 0
	
	emit_signal("score_changed")
	if old_combo != combo:
		emit_signal("combo_changed", combo)
	emit_signal("combo_ended")


## Reset all score data, such as when starting a level over.
func reset() -> void:
	customer_scores = [0]
	combo = 0
	bonus_score = 0
	fatness_score = 0
	level_performance = PuzzlePerformance.new()
	game_active = false
	finish_triggered = false
	tutorial_section_finished = false
	game_ended = false
	topping_out = false
	speed_index = 0
	no_more_customers = CurrentLevel.is_tutorial()
	input_frame = -1
	
	emit_signal("topping_out_changed", false)
	emit_signal("score_changed")
	emit_signal("speed_index_changed", 0)


func get_score() -> int:
	return level_performance.score


func get_lines() -> int:
	return level_performance.lines


func get_bonus_score() -> int:
	return bonus_score


func get_customer_score() -> int:
	return customer_scores[customer_scores.size() - 1]


func set_combo(new_combo: int) -> void:
	if combo == new_combo:
		# don't emit a signal if the combo doesn't change
		return
	
	combo = new_combo
	emit_signal("combo_changed", combo)


func end_result() -> int:
	if level_performance.pieces == 0:
		return Levels.Result.NONE
	elif level_performance.lost:
		return Levels.Result.LOST
	elif MilestoneManager.is_met(CurrentLevel.settings.success_condition):
		return Levels.Result.WON
	else:
		return Levels.Result.FINISHED


func before_piece_written() -> void:
	emit_signal("before_piece_written")


func after_piece_written() -> void:
	if finish_triggered and not game_ended:
		end_game()
	emit_signal("after_piece_written")


func _prepare_game() -> void:
	game_active = false
	finish_triggered = false
	tutorial_section_finished = false
	game_ended = false
	topping_out = false
	
	if CurrentLevel.settings.other.start_level:
		# Load a different level to start (used for tutorials)
		var new_settings := LevelSettings.new()
		new_settings.load_from_resource(CurrentLevel.settings.other.start_level)
		new_settings.adjust_milestones()
		CurrentLevel.start_level(new_settings)
	
	reset()
	_timers.clear()
	emit_signal("game_prepared")
	emit_signal("after_game_prepared")
	CurrentLevel.settings.triggers.run_triggers(LevelTrigger.BEFORE_START)


func _start_game() -> void:
	if game_active:
		return
	
	game_active = true
	# initialize input_frame to allow for recording/replaying inputs
	input_frame = 0
	emit_signal("game_started")
	CurrentLevel.settings.triggers.run_triggers(LevelTrigger.START)


func _add_score(delta: int) -> void:
	level_performance.score += delta


func _add_bonus_score(delta: int) -> void:
	bonus_score += delta
	fatness_score += delta


func _add_line() -> void:
	level_performance.lines += 1


func _add_customer_score(delta: int) -> void:
	customer_scores[customer_scores.size() - 1] += delta


func _on_Timer_timeout_start_game() -> void:
	_start_game()


func _on_Timer_timeout_emit_after_game_ended() -> void:
	emit_signal("after_game_ended")
