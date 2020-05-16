extends Label
"""
Shows diagnostics for the piece physics. Enabled with the cheat code 'delays'.
"""

onready var _puzzle:Puzzle = get_parent()
onready var _playfield:Playfield = _puzzle.get_node("Playfield")
onready var _pieceManager:PieceManager= _puzzle.get_node("PieceManager")

func _process(delta: float) -> void:
	if visible:
		var new_text: String = ""
		new_text += "%1d" % [min(9, _playfield._combo_break)]
		new_text += "l" if _playfield._remaining_line_clear_frames > 0 else "-"
		new_text += "b" if _playfield._remaining_box_build_frames > 0 else "-"
		new_text += "r" if _playfield.ready_for_new_piece() else "-"
		var das: bool = _pieceManager._input_left_frames > PieceSpeeds.current_speed.delayed_auto_shift_delay \
				or _pieceManager._input_right_frames > PieceSpeeds.current_speed.delayed_auto_shift_delay
		new_text += "D" if das else "-"
		new_text += "%1d%1d" % [min(9, _pieceManager._input_left_frames), min(9, _pieceManager._input_right_frames)]
		new_text += " %s(%02d)" % [_pieceManager.get_state().name.left(4), min(99, _pieceManager.get_state().frames)]
		text = new_text


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "delays":
		visible = !visible
		detector.play_cheat_sound(visible)
