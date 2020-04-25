extends State
"""
State: The player is moving the piece around the playfield.
"""

func enter(piece_manager: PieceManager, prev_state_name: String) -> void:
	if prev_state_name == "Prespawn":
		# apply an immediate frame of player movement and gravity to prevent the piece from flickering at the top of
		# the screen at 20G or when hard drop is held
		update(piece_manager)


func update(piece_manager: PieceManager) -> String:
	var new_state := ""
	piece_manager.apply_player_input()
	piece_manager.apply_gravity()
	piece_manager.apply_lock()
	if piece_manager.active_piece.lock > piece_manager.piece_speed.lock_delay:
		new_state = "Prelock"
	return new_state
