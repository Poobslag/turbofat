extends Label
## Displays bonus points awarded during the current combo.
##
## This only includes bonuses and should be a round number like +55 or +130 for visual aesthetics.

## Enforces a minimum time that we show the top out penalty. Without this, the player might not notice the penalty if
## their score changed a split second later (or worse yet, on the exact same frame).
onready var _penalty_timer := $PenaltyTimer

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	PuzzleState.connect("score_changed", self, "_on_PuzzleState_score_changed")
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")
	text = "-"


func _refresh_score() -> void:
	modulate = Color("80ffffff")
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


func _on_resized() -> void:
	# Avoid a Stack Overflow where changing our margins triggers another _on_resized() event, see #1810
	disconnect("resized", self, "_on_resized")
	margin_left = -rect_size.x
	connect("resized", self, "_on_resized")


func _on_PuzzleState_score_changed() -> void:
	if not _penalty_timer.is_stopped():
		# if the player tops out, we show the penalty value for a few seconds
		return
	
	_refresh_score()


func _on_PuzzleState_topped_out() -> void:
	modulate = Color("80ff5555")
	text = StringUtils.format_money(-1 * PuzzleState.TOP_OUT_PENALTY)
	rect_size = Vector2(0, 0)
	_penalty_timer.start()


func _on_PuzzleState_game_prepared() -> void:
	_penalty_timer.stop()
	_refresh_score()
