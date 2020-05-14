extends Label
"""
Displays bonus points awarded during the current combo.

This only includes bonuses and should be a round number like +55 or +130 for visual aesthetics.
"""

func _ready() -> void:
	PuzzleScore.connect("combo_score_changed", self, "_on_PuzzleScore_combo_score_changed")
	text = "-"


func _on_PuzzleScore_combo_score_changed(new_combo_score: int) -> void:
	text = "-" if new_combo_score == 0 else "+" + str(new_combo_score)
