extends SteamAchievement
## Unlocks an achievement when the player gets rank "S" on all levels in a chapter, excluding the boss level.

## The 'API Name' of the Steam stat which tracks how many levels the player has achieved an 'S' rank on
export (String) var stat_id: String

## The region ID whose unlock status should be tracked.
export (String) var region_id: String

## Refreshes the achievement based on whether the chapter has been unlocked.
func refresh_achievement() -> void:
	var s_rank_percent := _s_rank_percent()
	
	Steam.set_stat_float(stat_id, 100 * s_rank_percent)
	if s_rank_percent == 1.0:
		Steam.set_achievement(achievement_id)


## Returns a number in the range [0.0, 1.0] for how many levels the player has achieved an 'S' rank on.
func _s_rank_percent() -> float:
	var region := CareerLevelLibrary.region_for_id(region_id)
	var s_rank_count := 0
	for level_obj in region.levels:
		var level: CareerLevel = level_obj
		var rank := PlayerData.level_history.best_overall_rank(level.level_id)
		if RankCalculator.rank_meets_grade(rank, "S-"):
			s_rank_count += 1
	
	return s_rank_count / float(region.levels.size())
