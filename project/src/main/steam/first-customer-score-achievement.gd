extends UniqueLevelAchievement
## Unlocks an achievement when the player reaches a target score with their first customer on a level.

export (int) var target_score: int

func prepare_level_listeners() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")


func refresh_achievement() -> void:
	if PuzzleState.customer_scores[0] >= target_score:
		SteamUtils.set_achievement(achievement_id)


func _on_PuzzleState_score_changed() -> void:
	refresh_achievement()
