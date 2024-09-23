class_name LegacyRankTargetCalculator
## Calculates the target score or time to achieve a particular rank or grade with a mathematical model incorporating
## piece speed, required line clears, points per line and other factors.
##
## Note: The math-based rank algorithms have been replaced with simpler percent-based algorithms, where there is a
## perfect score and then other goals are calculated based on a percentage of the perfect score.

var _rank_calculator := LegacyRankCalculator.new()

## Returns the target score or time to achieve a particular grade.
func target_for_grade(target_grade: String) -> int:
	return target_for_rank(LegacyRankCalculator.required_rank_for_grade(target_grade))


## Returns the target score or time to achieve a particular rank.
func target_for_rank(target_rank: float) -> int:
	var target_hi := 50000
	var target_lo := 0
	
	for _i in range(20):
		var rank_result := LegacyRankResult.new()
		var new_target: float = (target_hi + target_lo) / 2.0
		if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
			rank_result.seconds = new_target
			rank_result.compare = "-seconds"
		else:
			rank_result.score = new_target
		
		rank_result = _rank_calculator.calculate_rank(rank_result)
		
		if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
			if rank_result.seconds_rank <= target_rank:
				target_lo = int(floor(new_target))
			else:
				target_hi = int(ceil(new_target))
		else:
			if rank_result.score_rank <= target_rank:
				target_hi = int(ceil(new_target))
			else:
				target_lo = int(floor(new_target))
	
	var result: int
	if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
		result = target_lo
	else:
		result = target_hi
	return result
