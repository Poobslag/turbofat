class_name ResultsHudBlueprint
## Plans out the timing and sizes of different visual aspects of the ResultsHud animation.
##
## Several parts of the animation are synchronized or involve complex algorithms. Calculating these things up front
## ensures all the visual elements sync up correctly.

const PAUSE_DURATION := 0.6

var goal_sss: int
var goal_ss: int
var goal_s: int
var goal_a: int
var goal_b: int
var goal_success: int

## 'true' if we should show the 'GOAL' marker for the level's success_condition
var show_success_goal := false

## 'true' if we should show the 'A', 'S', 'SS' rank markers
var show_rank_goals := true

var rank_result: RankResult

## calculates the time or score thresholds
var rank_criteria: RankCriteria

var _rank_calculator := RankCalculator.new()

func _init() -> void:
	var rank_calculator := RankCalculator.new()
	rank_criteria = rank_calculator.filled_rank_criteria()
	rank_result = rank_calculator.calculate_rank()
	
	# we calculate these goals in advance because they were once computationally complex
	goal_success = CurrentLevel.settings.success_condition.value
	goal_b = _target_for_grade("B-")
	goal_a = _target_for_grade("A-")
	goal_s = _target_for_grade("S-")
	goal_ss = _target_for_grade("SS")
	goal_sss = _target_for_grade("SSS")
	
	var best_result := PlayerData.level_history.best_result(CurrentLevel.level_id)
	
	# For most levels, we show the rank goals and hide the success goal.
	show_success_goal = false
	show_rank_goals = true
	
	# We show the 'Goal' marker for levels with an unmet success condition, such as career mode boss levels
	if CurrentLevel.settings.success_condition.type == Milestone.SCORE \
			and (not best_result or best_result.score < CurrentLevel.settings.success_condition.value):
		show_success_goal = true
	if CurrentLevel.settings.success_condition.type == Milestone.TIME_UNDER \
			and (not best_result or best_result.seconds > CurrentLevel.settings.success_condition.value):
		show_success_goal = true
	if CurrentLevel.boss_level:
		show_success_goal = true
	
	
	# We hide the 'rank' markers for boss levels, so the player can focus on the score they need. They'll probably
	# only care about the letter grade when replaying the level in training mode.
	if CurrentLevel.boss_level:
		show_rank_goals = false


func should_show_medal() -> bool:
	return PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0 and CurrentLevel.hardcore \
			and CurrentLevel.best_result in [Levels.Result.FINISHED, Levels.Result.WON]

func box_score() -> int:
	return rank_result.box_score


func combo_score() -> int:
	return rank_result.combo_score


func extra_score() -> int:
	return int(max(0, rank_result.score - rank_result.box_score - rank_result.combo_score))


func box_duration() -> float:
	return _duration_from_score(box_score())


func combo_duration() -> float:
	return _duration_from_score(combo_score())


func extra_duration() -> float:
	return _duration_from_score(extra_score())


func total_duration() -> float:
	var result := 0.0
	if box_duration():
		result += box_duration() + PAUSE_DURATION
	if combo_duration():
		result += combo_duration() + PAUSE_DURATION
	if extra_duration():
		result += extra_duration() + PAUSE_DURATION
	return result


func box_height() -> float:
	return _height_from_score(box_score())


func combo_height() -> float:
	return _height_from_score(combo_score())


func extra_height() -> float:
	return _height_from_score(extra_score())


func total_height() -> float:
	return box_height() + combo_height() + extra_height()


func goal_height_b() -> float:
	return _goal_height(goal_b)


func goal_height_a() -> float:
	return _goal_height(goal_a)


func goal_height_s() -> float:
	return _goal_height(goal_s)


func goal_height_ss() -> float:
	return _goal_height(goal_ss)


func goal_height_sss() -> float:
	return _goal_height(goal_sss)


## Goal height for the 'GOAL' marker for the level's success_condition
func goal_height_success() -> float:
	return _goal_height(goal_success)


func _target_for_grade(grade: String) -> int:
	return rank_criteria.thresholds_by_grade[grade]


func _duration_from_score(score: int) -> float:
	var duration := 0.0
	if score > 0:
		duration += 0.4
	duration += 1.6 / 1000.0 * clamp(score, 0, 1000) # 800 ms for the first 1,000 points
	duration += 1.2 / 1000.0 * clamp(score - 1000, 0, 1000) # 600 ms for the second 1,000 points
	duration += 0.8 / 1000.0 * clamp(score - 2000, 0, 10000) # 400 ms for any additional 1,000 points
	return duration


func _height_from_score(score: int) -> float:
	return float(score * 0.5)


func _goal_height(goal: int) -> float:
	var result: float
	if rank_result.compare == "-seconds":
		var seconds := rank_result.seconds
		if rank_result.lost:
			var percent_complete := float(rank_result.score) / max(1, CurrentLevel.settings.finish_condition.value)
			var filled_rank_criteria: RankCriteria = _rank_calculator.filled_rank_criteria()
			seconds = filled_rank_criteria.thresholds_by_grade["B-"] * 2.0
			seconds += clamp((1.0 - percent_complete) * seconds, 1, 180)
		result = seconds * total_height() / goal
	else:
		result = _height_from_score(goal)
		
	return result
