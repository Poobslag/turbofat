extends Node
## Monitors the player's progress towards milestones.
##
## Milestones can involve reaching a certain score, clearing a certain number of lines or surviving a certain number of
## seconds.
##
## Reaching a milestone can increase the speed, end the level, or trigger a success condition.

func _ready() -> void:
	PuzzleState.connect("before_piece_written", self, "_on_PuzzleState_before_piece_written")
	PuzzleState.connect("after_piece_written", self, "_on_PuzzleState_after_piece_written")
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
	PuzzleState.connect("combo_ended", self, "_on_PuzzleState_combo_ended")


func _physics_process(_delta: float) -> void:
	if CurrentLevel.settings.finish_condition.type == Milestone.TIME_OVER:
		# only check for 'time over' milestones; other milestones only trigger after a piece is finished locking
		_check_for_finish()


func is_met(milestone: Milestone) -> bool:
	var result := false
	var progress := progress_value(milestone)
	match milestone.type:
		Milestone.NONE:
			result = false
		Milestone.TIME_UNDER:
			result = progress <= milestone.value
		_:
			result = progress >= milestone.value
	return result


## Returns the player's current progress toward the specified milestone as a percentage.
func progress_percent(milestone: Milestone) -> float:
	return progress_value(milestone) / milestone.value


## Returns the player's current progress toward the specified milestone as a number ranged [0, inf].
##
## Depending on the milestone type, the returned progress value could be the current score, number of lines cleared or
## something else.
func progress_value(milestone: Milestone) -> float:
	var progress: float
	match milestone.type:
		Milestone.CUSTOMERS:
			progress = PuzzleState.customer_scores.size()
			if not PuzzleState.no_more_customers:
				progress -= 0.5
				if PuzzleState.get_customer_score() == 0:
					progress -= 0.5
		Milestone.LINES:
			progress = PuzzleState.level_performance.lines
		Milestone.PIECES:
			progress = PuzzleState.level_performance.pieces
		Milestone.SCORE:
			progress = PuzzleState.get_score() + PuzzleState.get_bonus_score()
		Milestone.TIME_OVER, Milestone.TIME_UNDER:
			progress = PuzzleState.level_performance.seconds
	return progress


## Returns the previously completed milestone.
##
## This controls the speed at which the pieces move.
func prev_milestone() -> Milestone:
	var milestone: Milestone
	if PuzzleState.speed_index < CurrentLevel.settings.speed.speed_ups.size():
		milestone = CurrentLevel.settings.speed.speed_ups[PuzzleState.speed_index]
	else:
		milestone = CurrentLevel.settings.speed.speed_ups.back()
	return milestone


## Returns the next upcoming milestone. This is reflected in the UI.
##
## The next upcoming milestone could be a 'speed up' if this level has multiple speeds, or it could be the level's
## finish condition.
func next_milestone() -> Milestone:
	var milestone: Milestone
	if PuzzleState.speed_index + 1 < CurrentLevel.settings.speed.speed_ups.size():
		milestone = CurrentLevel.settings.speed.speed_ups[PuzzleState.speed_index + 1]
	else:
		milestone = CurrentLevel.settings.finish_condition
	return milestone


## If the player reached a milestone, we increase the speed.
func _check_for_speed_up() -> void:
	var new_speed_index: int = PuzzleState.speed_index
	
	while new_speed_index + 1 < CurrentLevel.settings.speed.speed_ups.size() \
			and is_met(CurrentLevel.settings.speed.speed_ups[new_speed_index + 1]):
		new_speed_index += 1
	
	if PuzzleState.speed_index != new_speed_index:
		PuzzleState.speed_index = new_speed_index


## If the player reached the finish milestone, we end the level.
func _check_for_finish() -> void:
	if PuzzleState.game_active and is_met(CurrentLevel.settings.finish_condition):
		PuzzleState.trigger_finish()


func _on_PuzzleState_before_piece_written() -> void:
	_check_for_speed_up()


func _on_PuzzleState_after_piece_written() -> void:
	_check_for_speed_up()
	_check_for_finish()


func _on_PuzzleState_score_changed() -> void:
	_check_for_speed_up()


func _on_PuzzleState_combo_ended() -> void:
	# most milestones end when the piece is written; but customer milestones end when the combo ends
	if CurrentLevel.settings.finish_condition.type == Milestone.CUSTOMERS:
		_check_for_finish()
