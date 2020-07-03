extends State
"""
The piece has locked into position. The player can still press 'down' to unlock it or squeeze it past other blocks.
"""

func update(piece_manager: PieceManager) -> String:
	var new_state_name := ""
	piece_manager.move_piece()
	if piece_manager.piece.lock == 0:
		# piece was unlocked
		new_state_name = "MovePiece"
	elif frames >= PieceSpeeds.current_speed.post_lock_delay:
		piece_manager.buffer_inputs()
		piece_manager.write_piece_to_playfield()
		var spawn_delay: float
		if piece_manager.is_playfield_clearing_lines():
			# line was cleared; different appearance delay
			spawn_delay = PieceSpeeds.current_speed.line_appearance_delay
		else:
			spawn_delay = PieceSpeeds.current_speed.appearance_delay
		piece_manager.piece.spawn_delay = spawn_delay
		new_state_name = "WaitForPlayfield"
	
	return new_state_name
