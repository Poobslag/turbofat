extends SteamAchievement
## Unlocks an achievement when the player reaches a combo target.

export (int) var target_combo: int = 0

## Highest combo the player has achieved since launching the game.
var _max_combo := 0

func _ready() -> void:
	PuzzleState.connect("combo_changed", self, "_on_PuzzleState_combo_changed")


func refresh_achievement() -> void:
	if _max_combo >= target_combo:
		Steam.set_achievement(achievement_id)


func _on_PuzzleState_combo_changed(value: int) -> void:
	_max_combo = max(_max_combo, value)
	refresh_achievement()
