extends Label
## Displays bonus points awarded during the current combo.
##
## This only includes bonuses and should be a round number like +55 or +130 for visual aesthetics.

func _ready() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
	text = "-"


func _on_PuzzleState_score_changed() -> void:
	var bonus_score := PuzzleState.get_bonus_score()
	text = "-" if bonus_score == 0 else "+¥%s" % StringUtils.comma_sep(bonus_score)
