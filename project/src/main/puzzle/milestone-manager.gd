extends Node
"""
Tracks the player's progress towards milestones.

Milestones can involve reaching a certain score, clearing a certain number of lines or surviving a certain number of
seconds.

Reaching a milestone can increase the speed, end the level, or trigger a success condition.
"""

func _ready() -> void:
	PuzzleScore.connect("before_piece_written", self, "_on_PuzzleScore_before_piece_written")
	PuzzleScore.connect("after_piece_written", self, "_on_PuzzleScore_after_piece_written")
	PuzzleScore.connect("score_changed", self, "_on_PuzzleScore_score_changed")
	PuzzleScore.connect("combo_ended", self, "_on_PuzzleScore_combo_ended")


func _physics_process(_delta: float) -> void:
	if CurrentLevel.settings.finish_condition.type == Milestone.TIME_OVER:
		# only check for 'time over' milestones; other milestones only trigger after a piece is finished locking
		_check_for_finish()


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

Depending on the milestone type, the returned progress value could be the current score, number of lines cleared or
something else.
"""
func milestone_progress(milestone: Milestone) -> float:
	var progress: float
	match milestone.type:
		Milestone.CUSTOMERS:
			progress = PuzzleScore.creature_scores.size()
			if not PuzzleScore.no_more_customers:
				progress -= 0.5
				if PuzzleScore.get_creature_score() == 0:
					progress -= 0.5
		Milestone.LINES:
			progress = PuzzleScore.level_performance.lines
		Milestone.PIECES:
			progress = PuzzleScore.level_performance.pieces
		Milestone.SCORE:
			progress = PuzzleScore.get_score() + PuzzleScore.get_bonus_score()
		Milestone.TIME_OVER, Milestone.TIME_UNDER:
			progress = PuzzleScore.level_performance.seconds
	return progress


"""
Returns the previously completed milestone.

This controls the speed at which the pieces move.
"""
func prev_milestone() -> Milestone:
	return CurrentLevel.settings.speed_ups[PuzzleScore.speed_index]


"""
Returns the next upcoming milestone. This is reflected in the UI.

The next upcoming milestone could be a 'speed up' if this level has multiple speeds, or it could be the level's
finish condition.
"""
func next_milestone() -> Milestone:
	var milestone: Milestone
	if PuzzleScore.speed_index + 1 < CurrentLevel.settings.speed_ups.size():
		milestone = CurrentLevel.settings.speed_ups[PuzzleScore.speed_index + 1]
	else:
		milestone = CurrentLevel.settings.finish_condition
	return milestone


"""
If the player reached a milestone, we increase the speed.
"""
func _check_for_speed_up() -> void:
	var new_speed_index: int = PuzzleScore.speed_index
	
	while new_speed_index + 1 < CurrentLevel.settings.speed_ups.size() \
			and milestone_met(CurrentLevel.settings.speed_ups[new_speed_index + 1]):
		new_speed_index += 1
	
	if PuzzleScore.speed_index != new_speed_index:
		PuzzleScore.speed_index = new_speed_index


"""
If the player reached the finish milestone, we end the level.
"""
func _check_for_finish() -> void:
	if PuzzleScore.game_active and milestone_met(CurrentLevel.settings.finish_condition):
		PuzzleScore.trigger_finish()


func _on_PuzzleScore_before_piece_written() -> void:
	_check_for_speed_up()


func _on_PuzzleScore_after_piece_written() -> void:
	_check_for_speed_up()
	_check_for_finish()


func _on_PuzzleScore_score_changed() -> void:
	_check_for_speed_up()


func _on_PuzzleScore_combo_ended() -> void:
	# most milestones end when the piece is written; but customer milestones end when the combo ends
	if CurrentLevel.settings.finish_condition.type == Milestone.CUSTOMERS:
		_check_for_finish()
