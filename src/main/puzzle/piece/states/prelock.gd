extends State
"""
The piece has locked into position. The player can still press 'down' to unlock it or squeeze it past other blocks.
"""

func update(piece_manager: PieceManager) -> String:
	var new_state_name := ""
	piece_manager.apply_player_input()
	
	if frames >= piece_manager.piece_speed.post_lock_delay:
		var active_piece = piece_manager.active_piece
		if piece_manager.playfield:
			if piece_manager.playfield.write_piece(active_piece.pos, active_piece.orientation, active_piece.type,
					piece_manager.piece_speed.line_clear_delay):
				# line was cleared; different appearance delay
				active_piece.spawn_delay = piece_manager.piece_speed.line_appearance_delay
			else:
				active_piece.spawn_delay = piece_manager.piece_speed.appearance_delay
		active_piece.setType(PieceTypes.piece_null)
		piece_manager.tile_map_dirty = true
		new_state_name = "WaitForPlayfield"
	
	return new_state_name
