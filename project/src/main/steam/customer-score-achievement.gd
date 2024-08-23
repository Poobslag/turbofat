extends SteamAchievement
## Unlocks an achievement when the player reaches a score target for a single customer.

export (int) var target_score: int = 0

## Highest single-customer score the player has achieved since launching the game.
var _max_score := 0

func _ready() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")


func refresh_achievement() -> void:
	if _max_score >= target_score:
		Steam.set_achievement(achievement_id)


func _on_PuzzleState_score_changed() -> void:
	_max_score = max(PuzzleState.get_customer_score(), _max_score)
	refresh_achievement()
