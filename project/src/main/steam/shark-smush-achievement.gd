extends SteamAchievement
## Unlocks an achievement when the player squishes a shark with a piece.

func connect_signals() -> void:
	.connect_signals()
	disconnect_save_signal()
	disconnect_load_signal()
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")


func _sharks() -> Sharks:
	return CurrentLevel.puzzle.get_sharks() if CurrentLevel.puzzle else null


func _on_PuzzleState_game_prepared() -> void:
	if CurrentLevel.puzzle \
			and not _sharks().is_connected("shark_squished", self, "_on_Sharks_shark_squished"):
		_sharks().connect("shark_squished", self, "_on_Sharks_shark_squished")


func _on_Sharks_shark_squished(_shark: Shark) -> void:
	SteamUtils.set_achievement(achievement_id)