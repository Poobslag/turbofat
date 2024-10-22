extends SteamAchievement
## Unlocks an achievement when the player reaches a combo target.

export (int) var target_combo: int = 0

## Highest combo the player has achieved since launching the game.
var _max_combo := 0

func connect_signals() -> void:
	.connect_signals()
	disconnect_save_signal()
	disconnect_load_signal()
	PuzzleState.connect("combo_changed", self, "_on_PuzzleState_combo_changed")


func refresh_achievement() -> void:
	if _max_combo >= target_combo:
		SteamUtils.set_achievement(achievement_id)


func _on_PuzzleState_combo_changed(value: int) -> void:
	if SteamUtils.is_achievement_achieved(achievement_id):
		return
	_max_combo = max(_max_combo, value)
	refresh_achievement()
