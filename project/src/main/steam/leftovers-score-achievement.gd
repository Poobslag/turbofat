extends SteamAchievement
## Unlocks an achievement when the player reaches a score target with their leftover lines.

export (int) var target_score: int = 0

## Highest leftover lines score the player has achieved since launching the game.
var _max_score := 0

func connect_signals() -> void:
	.connect_signals()
	disconnect_save_signal()
	disconnect_load_signal()
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")


func refresh_achievement() -> void:
	if _max_score >= target_score:
		Steam.set_achievement(achievement_id)


func _on_PuzzleState_game_ended() -> void:
	_max_score = max(_max_score, PuzzleState.level_performance.leftover_score)
