extends UniqueLevelAchievement
## Unlocks an achievement when the player reaches a score target with pickups on a level.

export (int) var target_score: int

func prepare_level_listeners() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")


func remove_level_listeners() -> void:
	if PuzzleState.is_connected("score_changed", self, "_on_PuzzleState_score_changed"):
		PuzzleState.disconnect("score_changed", self, "_on_PuzzleState_score_changed")


func refresh_achievement() -> void:
	if PuzzleState.level_performance.pickup_score > target_score:
		SteamUtils.set_achievement(achievement_id)


func _on_PuzzleState_score_changed() -> void:
	refresh_achievement()