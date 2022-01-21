extends Control
## Displays a distance meter for career mode.
##
## This meter increases (and sometimes decreases) as the player progresses through a puzzle.

var _rank_calculator: RankCalculator = RankCalculator.new()

## Timer which periodically triggers rank recalculation
onready var _recalculate_timer: Timer = $RecalculateTimer

func _ready() -> void:
	# only display the meter in career mode
	if PlayerData.career.is_career_mode():
		visible = true
		_recalculate_timer.start()
		PuzzleState.connect("after_game_prepared", self, "_on_PuzzleState_after_game_prepared")
		PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
		PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	else:
		visible = false
	
	# initialize the meter as empty
	_recalculate()


## Returns the player's progress toward meeting the specified milestone.
##
## Unlike MilestoneManager's progress_percent() function, for this function, a higher value is always better.
func _milestone_met_percent(milestone: Milestone) -> float:
	var result := MilestoneManager.progress_percent(milestone)
	if milestone.type == Milestone.TIME_UNDER:
		result = 1.0 if result == 0 else 1.0 / result
	return result


## Returns the player's progress toward the current level's success condition as a number ranged [0.0, 1.0].
##
## For career mode boss levels, the success condition acts as an additional prerequisite to progress. This method
## calculates how close the player is to progressing through career mode.
func _boss_level_percent() -> float:
	if CurrentLevel.settings.success_condition.type == Milestone.NONE:
		return 1.0
	
	var result := _milestone_met_percent(CurrentLevel.settings.success_condition)
	if PuzzleState.game_ended:
		# If the game ended without them reaching the finish condition (because they lost or gave up) then we limit
		# their success percent by their finish percent. This avoids a case where the step meter shows a positive
		# number even when they lose
		result = min(result, _milestone_met_percent(CurrentLevel.settings.finish_condition))
	elif CurrentLevel.settings.success_condition.type == Milestone.TIME_UNDER:
		# For modes graded on time, we predict their success based on their points per second.
		var current_points_per_second := float( \
				MilestoneManager.progress_value(CurrentLevel.settings.finish_condition)) / \
				max(1.0, MilestoneManager.progress_value(CurrentLevel.settings.success_condition))
		var target_points_per_second := float( \
				CurrentLevel.settings.finish_condition.value) / \
				CurrentLevel.settings.success_condition.value
		
		result = current_points_per_second / target_points_per_second
		
		# This line deliberately inflates our seconds prediction, particularly at the start of a puzzle. We do this
		# for two reasons. We want the meter to increase, and we don't want the prediction to max out after the
		# first cleared line
		result = clamp(pow(result, 1.5), 0.0, 1.0)
	return result


## Recalculates the player's projected rank and update the UI
func _recalculate() -> void:
	var boss_level_progress := _boss_level_percent()
	if boss_level_progress < 1.0:
		var rank_milestone := CareerData.RANK_MILESTONE_FAIL
		_update_ui(rank_milestone, boss_level_progress)
	else:
		var next_progress_value: float
		var overall_rank := _overall_rank()
		var rank_milestone_index := CareerData.rank_milestone_index(overall_rank)
		
		if rank_milestone_index == CareerData.RANK_MILESTONES.size() - 1:
			next_progress_value = 1.0
		else:
			next_progress_value = inverse_lerp(CareerData.RANK_MILESTONES[rank_milestone_index].rank,
					CareerData.RANK_MILESTONES[rank_milestone_index + 1].rank, overall_rank)
		next_progress_value = clamp(next_progress_value, 0.0, 1.0)
		var rank_milestone: Dictionary = CareerData.RANK_MILESTONES[rank_milestone_index]
		_update_ui(rank_milestone, next_progress_value)


## Update the UI with the specified projected rank data.
##
## Parameters:
## 	'rank_milestone': Metadata about the milestone including the distance travelled and color.
##
## 	'next_progress_value': A number in the range [0.0, 1.0] describing how close the player is to reaching the
## 		next milestone. A high value means they've almost reached the next milestone.
func _update_ui(rank_milestone: Dictionary, next_progress_value: float) -> void:
	$Fill.get("custom_styles/panel").set_bg_color(rank_milestone.color)
	$Fill.margin_top = lerp(75, 5, next_progress_value)
	$Label.text = str(rank_milestone.distance)


## Calculates the player's projected rank.
##
## For modes graded on score, we simply rank them based on their current score. For modes graded on time, we predict
## their final time based on their current score and percent complete.
func _overall_rank() -> float:
	var overall_rank: float = RankCalculator.WORST_RANK
	
	if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
		# for modes graded on time, we predict their final time based on their current performance
		var rank_result := _rank_calculator.unranked_result()
		var percent_complete := float(rank_result.score) / CurrentLevel.settings.finish_condition.value
		percent_complete = clamp(percent_complete, 0.0, 1.0)
		
		# This line deliberately inflates our seconds prediction, particularly at the start of a puzzle. We do this
		# for two reasons. We want the meter to increase, and we don't want the prediction to max out after the first
		# cleared line
		percent_complete = pow(percent_complete, 1.5)
		
		if percent_complete == 0:
			overall_rank = RankCalculator.WORST_RANK
		else:
			rank_result.seconds = clamp(PuzzleState.level_performance.seconds / percent_complete, 0, 9999)
			rank_result = _rank_calculator.calculate_rank(rank_result)
			overall_rank = rank_result.seconds_rank
	else:
		# for modes graded on score, we feed their current score into the rank calculator
		var rank_result := _rank_calculator.calculate_rank()
		overall_rank = rank_result.score_rank
	
	return overall_rank


func _on_RecalculateTimer_timeout() -> void:
	if PuzzleState.game_active:
		_recalculate()


func _on_PuzzleState_after_game_prepared() -> void:
	_recalculate()


func _on_PuzzleState_game_ended() -> void:
	_recalculate()


func _on_PuzzleState_score_changed() -> void:
	_recalculate()
