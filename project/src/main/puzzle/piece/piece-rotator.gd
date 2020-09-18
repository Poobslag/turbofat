extends Node
"""
Handles horizontal movement for the player's active piece.
"""

signal initial_rotated_left
signal initial_rotated_right
signal initial_rotated_twice

# warning-ignore:unused_signal
signal rotated_left
# warning-ignore:unused_signal
signal rotated_right
# warning-ignore:unused_signal
signal rotated_twice

export (NodePath) var input_path: NodePath

onready var input: PieceInput = get_node(input_path)

func apply_initial_rotate_input(piece: ActivePiece) -> void:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		return
	
	if input.is_cw_pressed() and input.is_ccw_pressed():
		input.set_cw_input_as_handled()
		input.set_ccw_input_as_handled()
		piece.orientation = piece.get_flip_orientation()
		emit_signal("initial_rotated_twice")
	elif input.is_cw_pressed():
		input.set_cw_input_as_handled()
		piece.orientation = piece.get_cw_orientation()
		emit_signal("initial_rotated_right")
	elif input.is_ccw_pressed():
		input.set_ccw_input_as_handled()
		piece.orientation = piece.get_ccw_orientation()
		emit_signal("initial_rotated_left")
	
	# relocate rotated piece to the top of the playfield
	var pos_arr: Array = piece.type.pos_arr[piece.orientation]
	var highest_pos := 3
	for pos in pos_arr:
		if pos.y < highest_pos:
			highest_pos = pos.y
	piece.pos.y -= highest_pos


func apply_rotate_input(piece: ActivePiece) -> void:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		return
	
	_calc_rotate_target(piece)
	
	if piece.target_orientation != piece.orientation:
		var rotation_signal: String
		if piece.target_orientation == piece.get_cw_orientation():
			rotation_signal = "rotated_right"
		elif piece.target_orientation == piece.get_ccw_orientation():
			rotation_signal = "rotated_left"
		elif piece.target_orientation == piece.get_flip_orientation():
			rotation_signal = "rotated_twice"
		
		var old_piece_y := piece.pos.y
		if not piece.can_move_to_target():
			piece.kick_piece()
		if not piece.can_move_to_target() and input.is_cw_pressed() and input.is_ccw_pressed():
			rotation_signal = "rotated_twice"
			piece.target_orientation = piece.get_flip_orientation()
			if not piece.can_move_to_target():
				piece.target_pos = piece.get_flip_position()
		
		if piece.target_pos.y < piece.pos.y and not piece.can_floor_kick():
			# tried to flip but we don't have any floor kicks for it
			pass
		elif piece.can_move_to_target():
			piece.move_to_target()
			if rotation_signal:
				emit_signal(rotation_signal)
			if piece.pos.y < old_piece_y:
				piece.floor_kicks += 1


"""
Calculates the position and orientation the player is trying to rotate the piece to.
"""
func _calc_rotate_target(piece: ActivePiece) -> void:
	if not input.is_cw_pressed() and not input.is_ccw_pressed():
		return
	
	piece.reset_target()
	if input.is_cw_just_pressed() and input.is_ccw_just_pressed():
		# flip the piece by rotating it twice
		piece.target_orientation = piece.get_flip_orientation()
	elif input.is_cw_just_pressed():
		if input.is_ccw_pressed():
			# flip the piece by rotating it again in the same direction
			piece.target_orientation = piece.get_ccw_orientation()
		else:
			piece.target_orientation = piece.get_cw_orientation()
	elif input.is_ccw_just_pressed():
		if input.is_cw_pressed():
			# flip the piece by rotating it again in the same direction
			piece.target_orientation = piece.get_cw_orientation()
		else:
			piece.target_orientation = piece.get_ccw_orientation()
