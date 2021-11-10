extends State
## State: The piece will spawn soon.

func update(piece_manager: PieceManager) -> String:
	var new_state_name := ""
	if frames >= piece_manager.piece.spawn_delay:
		piece_manager.pop_buffered_inputs()
		if piece_manager.spawn_piece():
			new_state_name = "MovePiece"
		else:
			new_state_name = "TopOut"
	return new_state_name
