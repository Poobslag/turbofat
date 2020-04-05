extends State
"""
State: The piece will spawn soon.
"""

func update(piece_manager: PieceManager) -> String:
	var new_state_name := ""
	if frames >= piece_manager.active_piece.spawn_delay:
		piece_manager._spawn_piece()
		new_state_name = "MovePiece"
	return new_state_name
