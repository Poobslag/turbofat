extends SteamAchievement
## Unlocks an achievement when the player unlocks a chapter.

## The region ID whose unlock status should be tracked.
export (String) var region_id: String

## Refreshes the achievement based on whether the chapter has been unlocked.
func refresh_achievement() -> void:
	if not PlayerData.career.is_region_locked(CareerLevelLibrary.region_for_id(region_id)):
		SteamUtils.set_achievement(achievement_id)
