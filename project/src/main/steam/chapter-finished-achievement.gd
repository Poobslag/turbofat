extends SteamAchievement
## Unlocks an achievement when the player finishes a chapter, clearing the final level.

## The region ID whose final level must be cleared.
export (String) var region_id: String

## Refreshes the achievement based on whether the final level in the chapter has been cleared.
func refresh_achievement() -> void:
	if PlayerData.career.is_region_finished(CareerLevelLibrary.region_for_id(region_id)):
		Steam.set_achievement(achievement_id)
