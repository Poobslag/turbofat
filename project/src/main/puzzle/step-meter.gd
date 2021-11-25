extends Control
## Displays a distance meter for career mode.
##
## This meter increases (and sometimes decreases) as the player progresses through a puzzle.

## Array of dictionaries containing milestone metadata, including the necessary rank, the distance the player will
## travel, and the UI color.
const RANK_MILESTONES := [
	{"rank": 64.0, "distance": 1, "color": Color("48b968")},
	{"rank": 36.0, "distance": 2, "color": Color("48b968")},
	{"rank": 24.0, "distance": 3, "color": Color("48b968")},
	{"rank": 20.0, "distance": 4, "color": Color("78b948")},
	{"rank": 16.0, "distance": 5, "color": Color("b9b948")},
	{"rank": 10.0, "distance": 10, "color": Color("b95c48")},
	{"rank": 4.0, "distance": 15, "color": Color("b94878")},
	{"rank": 0.0, "distance": 25, "color": Color("b948b9")},
]

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


## Recalculates the player's projected rank and update the UI
func _recalculate() -> void:
	var overall_rank := _overall_rank()
	var rank_milestone_index := _rank_milestone_index(overall_rank)
	
	var next_progress_value := inverse_lerp(RANK_MILESTONES[rank_milestone_index - 1].rank,
			RANK_MILESTONES[rank_milestone_index].rank, overall_rank)
	next_progress_value = clamp(next_progress_value, 0.0, 1.0)
	
	_update_ui(RANK_MILESTONES[rank_milestone_index], next_progress_value)


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


## Calculates the highest rank milestone the player's reached.
func _rank_milestone_index(overall_rank: float) -> int:
	var rank_milestone_index := 0
	for i in range(1, RANK_MILESTONES.size()):
		var rank_milestone: Dictionary = RANK_MILESTONES[i]
		if overall_rank > rank_milestone.rank:
			break
		rank_milestone_index = i
	return rank_milestone_index


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
			# avoid dividing by zero
			rank_result.seconds = 9999
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
