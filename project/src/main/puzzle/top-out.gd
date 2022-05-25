extends State
## State: The player has topped out, but the game is still running. We're waiting for the playfield to make room for
## the current piece.

func update(piece_manager: PieceManager) -> String:
	piece_manager.buffer_inputs()
	var new_state_name := ""
	if frames >= piece_manager.piece.spawn_delay:
		piece_manager.pop_buffered_inputs()
		if piece_manager.initially_move_piece():
			new_state_name = "MovePiece"
		else:
			new_state_name = "TopOut"
	return new_state_name
