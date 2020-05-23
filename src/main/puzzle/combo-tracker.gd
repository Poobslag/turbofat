class_name ComboTracker
extends Node
"""
Keeps track of the player's combo.

Increments the combo when the player does well, breaks the combo when the player messes up.
"""

signal combo_break_changed(value)

# bonus points which are awarded as the player continues a combo
const COMBO_SCORE_ARR = [0, 0, 5, 5, 10, 10, 15, 15, 20]

# number of lines the player has cleared without dropping their combo
var combo := 0

# The number of pieces the player has dropped without clearing a line or making a box.
var combo_break := 0

# 'true' if the player drops a piece which continues the combo (typically, making a box or clearing a line)
var piece_continued_combo := false

# 'true' if the player drops a piece which discontinues the combo.
# Some scenarios might break your combo if you clear a vegetable line, for example.
var piece_broke_combo := false

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")


"""
Increments the combo and score for the specified line clear.
"""
func add_combo_and_score(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	combo += 1
	var combo_score: int = COMBO_SCORE_ARR[clamp(combo - 1, 0, COMBO_SCORE_ARR.size() - 1)]
	var box_score := 0
	for box_int in box_ints:
		if PuzzleTileMap.is_snack_box(box_int):
			box_score += Global.scenario_settings.score.snack_points
		elif PuzzleTileMap.is_cake_box(box_int):
			box_score += Global.scenario_settings.score.cake_points
		else:
			box_score += Global.scenario_settings.score.veg_points
	PuzzleScore.add_line_score(combo_score, box_score)


func break_combo() -> void:
	if combo >= 20:
		$Fanfare3.play()
	elif combo >= 10:
		$Fanfare2.play()
	elif combo >= 5:
		$Fanfare1.play()
	
	if PuzzleScore.get_customer_score() > 0:
		PuzzleScore.end_combo()
	combo = 0


func _on_PuzzleScore_game_prepared() -> void:
	combo = 0


func _on_Playfield_box_made(x: int, y: int, width: int, height: int, color_int: int) -> void:
	piece_continued_combo = true
	if combo_break != 0:
		combo_break = 0
		emit_signal("combo_break_changed", combo_break)


func _on_Playfield_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	if Global.scenario_settings.combo_break.veg_row:
		if box_ints.empty():
			piece_broke_combo = true
	piece_continued_combo = true
	if combo_break != 0:
		combo_break = 0
		emit_signal("combo_break_changed", combo_break)


func _on_Playfield_after_piece_written() -> void:
	if piece_broke_combo:
		combo_break = Global.scenario_settings.combo_break.pieces
		break_combo()
		emit_signal("combo_break_changed", combo_break)
	elif piece_continued_combo:
		pass
	else:
		# piece did not continue or break the combo; increment combo_break
		combo_break += 1
		if combo_break >= Global.scenario_settings.combo_break.pieces:
			break_combo()
		emit_signal("combo_break_changed", combo_break)
	
	piece_broke_combo = false
	piece_continued_combo = false


func _on_PuzzleScore_game_ended() -> void:
	PuzzleScore.end_combo()
	combo = 0
