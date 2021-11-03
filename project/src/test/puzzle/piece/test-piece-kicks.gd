extends "res://addons/gut/test.gd"
"""
Framework for testing piece kicks.
"""

# Unit tests need to distinguish between a piece rotating in place and failing to rotate.
# This should only be used in tests; a piece kicking to -99, -99 could cause a softlock the game.
const FAILED_KICK := Vector2(-99, -99)

var from_grid := []
var to_grid := []

var _from_piece: ActivePiece
var _to_piece: ActivePiece

"""
A test which demonstrates the test framework itself is functioning properly.
"""
func test_framework() -> void:
	from_grid = [
		"  :::",
		"  : :",
		" ppp:",
		"  pp:",
		"  :::"
	]
	to_grid = [
		"  :::",
		"  :p:",
		"  pp:",
		"  pp:",
		"  :::"
	]
	_kick_piece()
	
	# framework should have detected a 'p' block at (1, 2) with orientation (0)
	assert_eq(_from_piece.type.string, "p")
	assert_eq(_from_piece.pos, Vector2(1, 2))
	assert_eq(_from_piece.orientation, 0)
	
	# framework should have detected a 'p' block at (1, 1) with orientation (1)
	assert_eq(_to_piece.type.string, "p")
	assert_eq(_to_piece.pos, Vector2(1, 1))
	assert_eq(_to_piece.orientation, 1)


"""
Verifies that the piece kicks appropriately when rotated.

Verifies the piece shown in 'from_grid' can rotate to the orientation shown in 'to_grid'. Also verifies the piece is
moved to the correct position.
"""
func assert_kick() -> void:
	var result := _kick_piece()
	var text := "Rotating '%s' block from %s -> %s should kick %s" \
			% [_from_piece.type.string, _from_piece.orientation,
			_to_piece.orientation, _to_piece.pos - _from_piece.pos]
	if result == FAILED_KICK:
		# fail with a nice message; [none] expected to equal [(0, 1)]
		assert_eq("none", str(_to_piece.pos - _from_piece.pos), text)
	else:
		assert_eq(result, _to_piece.pos - _from_piece.pos, text)


"""
Attempts to rotate the piece to a new orientation, kicking if necessary

Returns one of the following:
	1. FAILED_KICK if the piece could not rotate.
	2. A zero vector if the piece could rotate without kicking.
	3. A non-zero vector if the piece could rotate, but needed to be kicked.
"""
func _kick_piece() -> Vector2:
	var result: Vector2
	_from_piece = _create_active_piece(from_grid)
	_to_piece = _create_active_piece(to_grid)
	
	var piece := _create_active_piece(from_grid)
	piece.target_orientation = _to_piece.orientation
	
	# if the piece is blocked, kick the piece
	if not piece.can_move_to(piece.target_pos, piece.target_orientation):
		piece.kick_piece()
	
	# if the piece is still blocked, it's a failed kick
	if not piece.can_move_to(piece.target_pos, piece.target_orientation):
		result = FAILED_KICK
	else:
		result = piece.target_pos - piece.pos
	return result


"""
Returns 'true' if the specified cell has a block in it or if it's outside the ascii drawing's boundaries.
"""
func _is_cell_blocked(pos: Vector2) -> bool:
	var blocked := false
	if pos.y < 0 or pos.y >= from_grid.size(): blocked = true
	elif pos.x < 0 or pos.x >= from_grid[pos.y].length(): blocked = true
	elif from_grid[pos.y][pos.x] == ":": blocked = true
	return blocked


"""
Create an active piece from an ascii drawing.

Calculates the piece's type, position and orientation.
"""
func _create_active_piece(ascii_grid: Array) -> ActivePiece:
	var piece_type := _determine_piece_type(ascii_grid)
	if not piece_type:
		push_warning("Could not find piece type in '%s' grid" % ("from" if ascii_grid == from_grid else "to"))

	var from_shape_data := []
	for row_index in range(from_grid.size()):
		var row_string: String = ascii_grid[row_index]
		for col_index in range(row_string.length()):
			if row_string[col_index] == piece_type.string:
				from_shape_data.append(Vector2(col_index, row_index))
	
	var _active_piece: ActivePiece
	for pos_arr_index in range(piece_type.pos_arr.size()):
		var shape_data:Array = piece_type.pos_arr[pos_arr_index]
		var position:Vector2 = from_shape_data[0] - shape_data[0]
		var shape_match := true
		for shape_data_index in range(shape_data.size()):
			if shape_data[shape_data_index] + position != from_shape_data[shape_data_index]:
				shape_match = false
				break
		if shape_match:
			_active_piece = ActivePiece.new(piece_type, funcref(self, "_is_cell_blocked"))
			_active_piece.pos = position
			_active_piece.orientation = pos_arr_index
			break
	if not _active_piece:
		push_warning("Could not find piece position/orientation in '%s' grid"\
				% ("from" if ascii_grid == from_grid else "to"))
	_active_piece.reset_target()
	return _active_piece


func _determine_piece_type(ascii_grid: Array) -> PieceType:
	var piece_type: PieceType
	for row_index in range(ascii_grid.size()):
		var row_string: String = ascii_grid[row_index]
		# can we determine the piece type from this row?
		for piece_string in PieceTypes.pieces_by_string.keys():
			if row_string.find(piece_string) != -1:
				piece_type = PieceTypes.pieces_by_string[piece_string]
		if piece_type:
			break
	return piece_type
