extends Label
"""
Displays bonus points awarded during the current combo.

This only includes bonuses and should be a round number like +55 or +130 for visual aesthetics.
"""

func _ready() -> void:
	PuzzleScore.connect("score_changed", self, "_on_PuzzleScore_score_changed")
	text = "-"


func _on_PuzzleScore_score_changed() -> void:
	var bonus_score := PuzzleScore.get_bonus_score()
	text = "-" if bonus_score == 0 else "+¥%s" % StringUtils.comma_sep(bonus_score)
