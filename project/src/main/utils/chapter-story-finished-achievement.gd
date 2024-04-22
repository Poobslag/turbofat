extends SteamAchievement

export (String) var stat_id: String
export (String) var region_id: String

func refresh_achievement() -> void:
	var region_completion := PlayerData.career.region_completion(CareerLevelLibrary.region_for_id(region_id))
	GodotSteam.set_stat_float(stat_id, region_completion.cutscene_completion_percent())
	if region_completion.cutscene_completion_percent() == 1.0:
		GodotSteam.set_achievement(achievement_id)
