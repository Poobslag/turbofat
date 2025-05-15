extends Label
## Shows diagnostics for the piece physics. Enabled with the cheat code 'delays'.

export (NodePath) var puzzle_path: NodePath

onready var _puzzle: Puzzle = get_node(puzzle_path)
onready var _playfield: Playfield = _puzzle.get_playfield()
onready var _combo_tracker: ComboTracker = _puzzle.get_node("Fg/Playfield/ComboTracker")
onready var _piece_manager: PieceManager = _puzzle.get_piece_manager()

func _process(_delta: float) -> void:
	if visible:
		var new_text := ""
		
		new_text += "%1d" % [min(9, _combo_tracker.combo_break)]
		new_text += "l" if _playfield.is_clearing_lines() else "-"
		new_text += "b" if _playfield.is_building_boxes() else "-"
		new_text += "r" if _playfield.ready_for_new_piece() else "-"
		new_text += " %s(%02d)" % [_piece_manager.get_state().name.left(4), min(99, _piece_manager.get_state().frames)]
		new_text += "\n"
		
		new_text += input_char(_piece_manager.input.left, "l")
		new_text += input_char(_piece_manager.input.right, "r")
		new_text += input_char(_piece_manager.input.cw, "x")
		new_text += input_char(_piece_manager.input.ccw, "z")
		new_text += input_char(_piece_manager.input.soft_drop, "d")
		new_text += input_char(_piece_manager.input.hard_drop, "u")
		var max_input_frames := 0
		max_input_frames = max(max_input_frames, _piece_manager.input.left.pressed_frames)
		max_input_frames = max(max_input_frames, _piece_manager.input.right.pressed_frames)
		max_input_frames = max(max_input_frames, _piece_manager.input.cw.pressed_frames)
		max_input_frames = max(max_input_frames, _piece_manager.input.ccw.pressed_frames)
		max_input_frames = max(max_input_frames, _piece_manager.input.soft_drop.pressed_frames)
		max_input_frames = max(max_input_frames, _piece_manager.input.hard_drop.pressed_frames)
		new_text += " %02d" % [min(99, max_input_frames)]
		text = new_text


## Returns a FrameInput object as a single-character string.
func input_char(frame_input: FrameInput, character: String) -> String:
	if not frame_input.is_pressed():
		return "-"
	elif not frame_input.is_das_active():
		return character
	else:
		return character.to_upper()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "delays":
		# show/hide frame data for pieces: line clear delay, prespawn, etc
		visible = not visible
		detector.play_cheat_sound(visible)
