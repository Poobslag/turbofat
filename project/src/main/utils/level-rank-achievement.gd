extends SteamAchievement

## Random grades to cycle between when showing the player's scrambled grade
const GRADES := ["M", "SSS", "SS+", "SS", "S+", "S", "S-", "AA+", "AA", "A+", "A", "A-", "B+", "B", "B-"]

export (String) var level_id: String
export (String) var target_grade: String

func refresh_achievement() -> void:
	var best_rank: float = PlayerData.level_history.best_overall_rank(level_id)
	var target_rank: float = RankCalculator.rank(target_grade)
	if best_rank <= target_rank:
		GodotSteam.set_achievement(achievement_id)
