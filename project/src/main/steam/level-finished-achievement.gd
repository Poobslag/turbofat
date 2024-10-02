extends SteamAchievement
## Unlocks an achievement when the player clears a specific level.

## The level ID which should be checked.
export (String) var level_id: String

## Refreshes the achievement based on whether the player has cleared a level.
func refresh_achievement() -> void:
	if PlayerData.level_history.is_level_finished(level_id):
		SteamUtils.set_achievement(achievement_id)
