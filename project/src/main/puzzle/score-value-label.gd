extends Label
"""
Displays the player's score.
"""

func _ready() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
	text = "¥0"


func _on_PuzzleState_score_changed() -> void:
	text = "¥%s" % StringUtils.comma_sep(PuzzleState.get_score())
