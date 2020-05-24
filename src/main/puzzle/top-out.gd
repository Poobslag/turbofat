extends State
"""
State: The player has topped out, but the game is still running. We're waiting for the playfield to make room for the
current piece.
"""

func update(piece_manager: PieceManager) -> String:
	var new_state_name := ""
	if frames >= piece_manager.piece.spawn_delay:
		new_state_name = "MovePiece"
	return new_state_name
