class_name RankCalculator
## Calculates the player's performance with a percent-based algorithm, where there is a perfect score and then other
## goals are calculated based on a percentage of the perfect score.
##
## This performance is stored as a series of 'ranks', where 0 is the best possible rank and 999 is the worst.

## Calculates the player's rank.
##
## This is calculated by comparing the player's performance to a set of thresholds in the current level's rank
## criteria. Each level defines the rank criteria for the best rank, and can optionally define rank criteria for other
## ranks. The remaining ranks are calculated by interpolation.
##
## Parameters:
## 	'unranked_result': (Optional) Information about a playthrough to evaluate. If omitted, a new RankResult
## 		instance is populated with data from PuzzleState.
##
## Returns:
## 	A RankResult object with its 'rank' field populated.
func calculate_rank(unranked_result: RankResult = null) -> RankResult:
	# obtain a populated RankResult with input data to evaluate
	var rank_result: RankResult
	if unranked_result:
		rank_result = unranked_result
	else:
		rank_result = unranked_result()
	
	var rank_criteria := filled_rank_criteria()
	
	# populate the rank field
	if CurrentLevel.settings.rank.unranked:
		rank_result.rank = Ranks.WORST_RANK if rank_result.lost else Ranks.BEST_RANK
	elif rank_result.compare == "-seconds" and rank_result.lost:
		rank_result.rank = Ranks.WORST_RANK
	else:
		rank_result.rank = rank_criteria.calculate_rank( \
				rank_result.seconds if rank_result.compare == "-seconds" else float(rank_result.score))
	return rank_result


## Returns a copy of the current level's rank criteria with all grade thresholds defined.
func filled_rank_criteria() -> RankCriteria:
	var rank_criteria := RankCriteria.new()
	rank_criteria.copy_from(CurrentLevel.settings.rank.rank_criteria)
	rank_criteria.duration_criteria = CurrentLevel.settings.finish_condition.type == Milestone.SCORE
	rank_criteria.fill_missing_thresholds()
	return rank_criteria


## Populates a new RankResult object with raw statistics.
##
## This does not include any rank data, only objective information like lines cleared and time taken.
func unranked_result() -> RankResult:
	var rank_result := RankResult.new()
	
	if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
		rank_result.compare = "-seconds"

	# copy performance statistics from PuzzleState
	rank_result.box_score = PuzzleState.level_performance.box_score
	rank_result.combo_score = PuzzleState.level_performance.combo_score
	rank_result.pickup_score = PuzzleState.level_performance.pickup_score
	rank_result.leftover_score = PuzzleState.level_performance.leftover_score
	rank_result.lines = PuzzleState.level_performance.lines
	rank_result.lost = PuzzleState.level_performance.lost
	rank_result.success = PuzzleState.level_performance.success
	rank_result.score = PuzzleState.level_performance.score + PuzzleState.bonus_score
	rank_result.seconds = PuzzleState.level_performance.seconds
	
	return rank_result
