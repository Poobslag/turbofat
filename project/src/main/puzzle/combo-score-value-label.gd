extends Label
## Displays bonus points awarded during the current combo.
##
## This only includes bonuses and should be a round number like +55 or +130 for visual aesthetics.

func _ready() -> void:
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
	text = "-"


func _on_PuzzleState_score_changed() -> void:
	var bonus_score := PuzzleState.get_bonus_score()
	if bonus_score == 0:
		# zero is displayed as '-'
		text = "-"
	elif bonus_score >= 0:
		# positive values are displayed as '+¥1,025'
		text = "+" + StringUtils.format_money(bonus_score)
	else:
		# negative values (which should never show up) are displayed as '-¥1,025'
		text = StringUtils.format_money(bonus_score)
