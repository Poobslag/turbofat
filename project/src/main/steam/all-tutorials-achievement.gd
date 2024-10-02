extends SteamAchievement
## Unlocks an achievement when the player clears all tutorials.

func refresh_achievement() -> void:
	var finished_tutorial_count := 0
	var tutorial_count := OtherLevelLibrary.region_for_id(OtherRegion.ID_TUTORIAL).level_ids.size()
	for level_id in OtherLevelLibrary.region_for_id(OtherRegion.ID_TUTORIAL).level_ids:
		if PlayerData.level_history.is_level_finished(level_id):
			finished_tutorial_count += 1
	if finished_tutorial_count == tutorial_count:
		SteamUtils.set_achievement(achievement_id)
