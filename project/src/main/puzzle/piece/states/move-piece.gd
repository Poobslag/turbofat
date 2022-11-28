extends State
## State: The player is moving the piece around the playfield.

func enter(piece_manager: PieceManager, prev_state_name: String) -> void:
	if prev_state_name == "Prespawn" or prev_state_name == "TopOut":
		# Apply an immediate frame of player movement and gravity.
		#
		# This applies the player's buffered inputs if they tap a movement/rotation key while a piece is locking. It
		# also prevents the piece from flickering at the top of the screen at 20G or when hard drop is held.
		update(piece_manager)


func update(piece_manager: PieceManager) -> String:
	var new_state := ""
	piece_manager.apply_swap_input()
	piece_manager.move_piece()
	piece_manager.apply_lock()
	if piece_manager.piece.lock > PieceSpeeds.current_speed.lock_delay:
		new_state = "Prelock"
	return new_state
