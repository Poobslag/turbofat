extends State
"""
State: The playfield is clearing lines or making boxes. We're waiting for these animations to complete before spawning
a new piece.
"""

func update(piece_manager: PieceManager) -> String:
	var new_state := ""
	if piece_manager.is_playfield_ready_for_new_piece():
		new_state = "Prespawn"
	return new_state
