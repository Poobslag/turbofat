extends Label
## Displays the player's score.

func _ready() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
	text = StringUtils.format_money(0)


func _on_PuzzleState_score_changed() -> void:
	text = StringUtils.format_money(PuzzleState.get_score())
