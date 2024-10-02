extends SteamAchievement
## Unlocks an achievement when the player obtains a particular grade on a specific level.

## The level ID whose grade should be checked.
export (String) var level_id: String

## The letter grade the player needs to achieve.
export (String) var target_grade: String

## Refreshes the achievement based on whether the player has achieved a particular grade on a level.
func refresh_achievement() -> void:
	# convert the target letter grade such as 'S+' into a numeric rating such as '12.6'
	var target_rank: float = Ranks.required_rank_for_grade(target_grade)
	
	# get the player's best performance for the level
	var best_rank: float = PlayerData.level_history.best_overall_rank(level_id)
	
	if best_rank <= target_rank:
		SteamUtils.set_achievement(achievement_id)
