class_name LegacyRankCriteriaCalculator
## Populates a level's rank criteria fields based on a mathematical model.
##
## Before September 2024, we calculated ranks with a complex mathematical model incorporating piece speed, required
## line clears, points per line and other factors. After September 2024, we switched over to a simpler percent-based
## algorithm, where there is a perfect score and then other goals are calculated based on a percentage of the perfect
## score. This script bridges between those two models, populating a level's perfect score based on the mathematical
## model so that it can be stored.

var _rank_target_calculator := LegacyRankTargetCalculator.new()
var _duration_calculator := LegacyDurationCalculator.new()

## Populates a level's rank criteria fields based on a mathematical model.
##
## Parameters:
## 	'settings': The level settings whose rank criteria fields should be populated.
func populate_rank_fields(settings: LevelSettings) -> void:
	# temporarily assign CurrentLevel.settings; LegacyRankTargetCalculator depends on it
	var previous_settings := CurrentLevel.settings
	CurrentLevel.settings = settings
	
	var target_for_master_rank := _rank_target_calculator.target_for_rank(0.0)
	if settings.finish_condition.type == Milestone.SCORE:
		target_for_master_rank = Ranks.round_time_up(target_for_master_rank)
	else:
		target_for_master_rank = Ranks.round_score_down(target_for_master_rank)
	settings.rank.rank_criteria.add_threshold(Ranks.BEST_GRADE, target_for_master_rank)
	
	var duration := _duration_calculator.duration(settings)
	duration = Ranks.round_time_up(duration)
	settings.rank.duration = duration
	
	CurrentLevel.settings = previous_settings
