extends SteamAchievement

export (String) var region_id: String

func refresh_achievement() -> void:
	if not PlayerData.career.is_region_locked(CareerLevelLibrary.region_for_id(region_id)):
		GodotSteam.set_achievement(achievement_id)
