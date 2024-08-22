extends SteamAchievement
## Unlocks an achievement when the player achieves other achievements.

## The 'API Name' of Steam achievements required to unlock this achievement.
export (Array, String) var required_achievements: Array

func refresh_achievement() -> void:
	var achieved_count := 0
	for required_achievement in required_achievements:
		if Steam.is_achievement_achieved(required_achievement):
			achieved_count += 1
	if achieved_count == required_achievements.size():
		Steam.set_achievement(achievement_id)
