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

var _rank_target_calculator: RankTargetCalculator
var rank_result: RankResult

func _init() -> void:
	_rank_target_calculator = RankTargetCalculator.new()
	var rank_calculator := RankCalculator.new()
	rank_result = rank_calculator.calculate_rank()
	
	# we calculate these goals in advance because they're computationally complex
	goal_b = _target_for_grade("B-")
	goal_a = _target_for_grade("A-")
	goal_s = _target_for_grade("S-")
	goal_ss = _target_for_grade("SS")
	goal_sss = _target_for_grade("SSS")


func should_show_medal() -> bool:
	return PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0 and CurrentLevel.hardcore \
			and CurrentLevel.best_result in [Levels.Result.FINISHED, Levels.Result.WON]

func box_score() -> int:
	return rank_result.box_score


func combo_score() -> int:
	return rank_result.combo_score


func extra_score() -> int:
	return rank_result.lines + rank_result.pickup_score + rank_result.leftover_score


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


func _target_for_grade(grade: String) -> int:
	var result := _rank_target_calculator.target_for_grade(grade)
	if rank_result.compare == "-seconds":
		result = min(result, 5999)
	return result


func _duration_from_score(score: int) -> float:
	var duration := 0.0
	if score >= 0:
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
			var percent_complete := float(rank_result.score) / CurrentLevel.settings.finish_condition.value
			seconds = _rank_target_calculator.target_for_rank(RankCalculator.BAD_RANK)
			seconds += clamp((1.0 - percent_complete) * seconds, 1, 180)
		result = seconds * total_height() / goal
	else:
		result = _height_from_score(goal)
		
	return result
