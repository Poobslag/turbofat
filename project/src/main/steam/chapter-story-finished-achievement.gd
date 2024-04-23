extends SteamAchievement
## Unlocks an achievement when the player views all cutscenes in a chapter.

## The 'API Name' of the Steam stat which tracks how many cutscenes the player has viewed.
export (String) var stat_id: String

## The region ID whose cutscenes should be tracked.
export (String) var region_id: String

## Refreshes the achievement and stat based on how many cutscenes the player has viewed in a chapter.
func refresh_achievement() -> void:
	var region_completion := PlayerData.career.region_completion(CareerLevelLibrary.region_for_id(region_id))
	Steam.set_stat_float(stat_id, 100 * region_completion.cutscene_completion_percent())
	if region_completion.cutscene_completion_percent() == 1.0:
		Steam.set_achievement(achievement_id)
