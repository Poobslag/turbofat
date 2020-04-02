extends "res://addons/gut/test.gd"

var _piece_dict := {
	"j": PieceTypes.piece_j,
	"l": PieceTypes.piece_l,
	"o": PieceTypes.piece_o,
	"p": PieceTypes.piece_p,
	"q": PieceTypes.piece_q,
	"t": PieceTypes.piece_t,
	"u": PieceTypes.piece_u,
	"v": PieceTypes.piece_v
}

var from_grid := []
var to_grid := []

var _from_piece: ActivePiece
var _to_piece: ActivePiece


"""
A test which demonstrates the test framework itself is functioning properly.
"""
func test_framework():
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
	
	# framework should have detected a 'p' block at (1, 2) with rotation (0)
	assert_eq(_from_piece.type.string, "p")
	assert_eq(_from_piece.pos, Vector2(1, 2))
	assert_eq(_from_piece.rotation, 0)
	
	# framework should have detected a 'p' block at (1, 1) with rotation (1)
	assert_eq(_to_piece.type.string, "p")
	assert_eq(_to_piece.pos, Vector2(1, 1))
	assert_eq(_to_piece.rotation, 1)


func _assert_kick() -> void:
	var result := _kick_piece()
	var text := "Rotating '%s' block from %s -> %s should kick %s" % [_from_piece.type.string, _from_piece.rotation, _to_piece.rotation, _to_piece.pos - _from_piece.pos]
	assert_eq(result, _to_piece.pos - _from_piece.pos, text)


func _kick_piece() -> Vector2:
	_from_piece = _create_active_piece(from_grid)
	_to_piece = _create_active_piece(to_grid)
	return _from_piece.kick_piece(funcref(self, "_is_cell_blocked"), _from_piece.pos, _to_piece.rotation)


func _is_cell_blocked(pos: Vector2) -> bool:
	var blocked := false
	if pos.y < 0 or pos.y >= from_grid.size(): blocked = true
	elif pos.x < 0 or pos.x >= from_grid[pos.y].length(): blocked = true
	elif from_grid[pos.y][pos.x] == ":": blocked = true
	return blocked


func _create_active_piece(ascii_grid: Array) -> ActivePiece:
	var piece_type := _determine_piece_type(ascii_grid)
	if !piece_type:
		push_error("Could not find piece type in '%s' grid" % ("from" if ascii_grid == from_grid else "to"))

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
		var shape_match:bool = true
		for shape_data_index in range(shape_data.size()):
			if shape_data[shape_data_index] + position != from_shape_data[shape_data_index]:
				shape_match = false
				break
		if shape_match:
			_active_piece = ActivePiece.new(piece_type)
			_active_piece.pos = position
			_active_piece.rotation = pos_arr_index
			break
	if !_active_piece:
		push_error("Could not find piece position/rotation in '%s' grid" % ("from" if ascii_grid == from_grid else "to"))
	return _active_piece


func _determine_piece_type(ascii_grid: Array) -> PieceType:
	var piece_type: PieceType
	for row_index in range(ascii_grid.size()):
		var row_string: String = ascii_grid[row_index]
		# can we determine the piece type from this row?
		for piece_string in _piece_dict.keys():
			if row_string.find(piece_string) != -1:
				piece_type = _piece_dict[piece_string]
		if piece_type:
			break
	return piece_type
