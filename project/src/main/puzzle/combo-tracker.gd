class_name ComboTracker
extends Node
"""
Keeps track of the player's combo.

Increments the combo when the player does well, breaks the combo when the player messes up.
"""

signal combo_break_changed(value)

# bonus points which are awarded as the player continues a combo
const COMBO_SCORE_ARR = [0, 0, 5, 5, 10, 10, 15, 15, 20]

# The number of pieces the player has dropped without clearing a line or making a box.
var combo_break := 0 setget set_combo_break

# 'true' if the player drops a piece which continues the combo (typically, making a box or clearing a line)
var piece_continued_combo := false

# 'true' if the player drops a piece which discontinues the combo.
# Some levels might break your combo if you clear a vegetable line, for example.
var piece_broke_combo := false

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	Level.connect("settings_changed", self, "_on_Level_settings_changed")


func set_combo_break(new_combo_break: int) -> void:
	combo_break = new_combo_break
	emit_signal("combo_break_changed", combo_break)


func break_combo() -> void:
	if PuzzleScore.combo >= 20:
		$Fanfare3.play()
	elif PuzzleScore.combo >= 10:
		$Fanfare2.play()
	elif PuzzleScore.combo >= 5:
		$Fanfare1.play()
	
	if PuzzleScore.combo > 0:
		PuzzleScore.end_combo()
	PuzzleScore.combo = 0
	emit_signal("combo_break_changed", combo_break)


func _reset() -> void:
	combo_break = 0
	emit_signal("combo_break_changed", combo_break)


func _on_PuzzleScore_game_prepared() -> void:
	_reset()


func _on_Level_settings_changed() -> void:
	_reset()


func _on_Playfield_box_built(_rect: Rect2, _color_int: int) -> void:
	piece_continued_combo = true
	if combo_break != 0:
		combo_break = 0
		emit_signal("combo_break_changed", combo_break)


func _on_Playfield_line_cleared(_y: int, _total_lines: int, _remaining_lines: int, box_ints: Array) -> void:
	if Level.settings.combo_break.veg_row:
		if box_ints.empty():
			piece_broke_combo = true
	piece_continued_combo = true
	if combo_break != 0:
		combo_break = 0
		emit_signal("combo_break_changed", combo_break)


func _on_Playfield_after_piece_written() -> void:
	if piece_broke_combo:
		combo_break = Level.settings.combo_break.pieces
		break_combo()
	else:
		if not piece_continued_combo:
			combo_break += 1
		
		# check for combo break even if the piece continued the combo.
		# this is necessary to cover the 'combo_break.pieces = 0' case
		if combo_break >= Level.settings.combo_break.pieces:
			break_combo()
		else:
			emit_signal("combo_break_changed", combo_break)
	
	piece_broke_combo = false
	piece_continued_combo = false


func _on_PuzzleScore_game_ended() -> void:
	PuzzleScore.end_combo()


"""
Increments the combo and score for the specified line clear.
"""
func _on_Playfield_before_line_cleared(_y: int, _total_lines: int, _remaining_lines: int, box_ints: Array) -> void:
	var combo_score: int = COMBO_SCORE_ARR[clamp(PuzzleScore.combo, 0, COMBO_SCORE_ARR.size() - 1)]
	var box_score := 0
	for box_int in box_ints:
		if PuzzleTileMap.is_snack_box(box_int):
			box_score += Level.settings.score.snack_points
		elif PuzzleTileMap.is_cake_box(box_int):
			box_score += Level.settings.score.cake_points
		else:
			box_score += Level.settings.score.veg_points
	PuzzleScore.add_line_score(combo_score, box_score)
