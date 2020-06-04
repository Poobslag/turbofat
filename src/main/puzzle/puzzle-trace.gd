extends Label
"""
Shows diagnostics for the piece physics. Enabled with the cheat code 'delays'.
"""

onready var _puzzle:Puzzle = get_parent()
onready var _playfield:Playfield = _puzzle.get_node("Playfield")
onready var _combo_tracker:ComboTracker = _puzzle.get_node("Playfield/ComboTracker")
onready var _piece_manager:PieceManager= _puzzle.get_piece_manager()

func _process(delta: float) -> void:
	if visible:
		var new_text: String = ""
		
		new_text += "%1d" % [min(9, _combo_tracker.combo_break)]
		new_text += "l" if _playfield.remaining_line_clear_frames > 0 else "-"
		new_text += "b" if _playfield.remaining_box_build_frames > 0 else "-"
		new_text += "r" if _playfield.ready_for_new_piece() else "-"
		new_text += " %s(%02d)" % [_piece_manager.get_state().name.left(4), min(99, _piece_manager.get_state().frames)]
		new_text += "\n"
		
		new_text += input_char(_piece_manager.get_node("InputLeft"), "l")
		new_text += input_char(_piece_manager.get_node("InputRight"), "r")
		new_text += input_char(_piece_manager.get_node("InputCw"), "x")
		new_text += input_char(_piece_manager.get_node("InputCcw"), "z")
		new_text += input_char(_piece_manager.get_node("InputSoftDrop"), "d")
		new_text += input_char(_piece_manager.get_node("InputHardDrop"), "u")
		var max_input_frames := 0
		max_input_frames = max(max_input_frames, _piece_manager.get_node("InputLeft").frames)
		max_input_frames = max(max_input_frames, _piece_manager.get_node("InputRight").frames)
		max_input_frames = max(max_input_frames, _piece_manager.get_node("InputCw").frames)
		max_input_frames = max(max_input_frames, _piece_manager.get_node("InputCcw").frames)
		max_input_frames = max(max_input_frames, _piece_manager.get_node("InputSoftDrop").frames)
		max_input_frames = max(max_input_frames, _piece_manager.get_node("InputHardDrop").frames)
		new_text += " %02d" % [min(99, max_input_frames)]
		text = new_text


"""
Returns a FrameInput object as a single-character string.
"""
func input_char(frame_input: FrameInput, character: String) -> String:
	if not frame_input.is_pressed():
		return "-"
	elif not frame_input.is_das_active():
		return character
	else:
		return character.to_upper()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "delays":
		visible = !visible
		detector.play_cheat_sound(visible)
