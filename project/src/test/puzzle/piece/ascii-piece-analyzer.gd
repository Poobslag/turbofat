class_name AsciiPieceAnalyzer
## Evaluates ascii pictures of piece grids to figure out where pieces are located and how they are oriented.
##
## Used in unit tests so they can have images of pieces and playfield layouts, instead of incomprehensible lists of
## numbers and grid coordinates.
##
## Each index in the ascii grid corresponds to a playfield row, with the first item corresponding to the top row. The
## grid supports the following characters:
## 	'j', 'l', 'o', 'p'...:                  A fragment of the corresponding piece
## 	' ':                                    An empty playfield cell
## 	':':                                    A filled playfield cell
##
## Here is an example grid showing a T piece on a narrow platform:
## 	[
## 	 "     ",
## 	 "  t  ",
## 	 " ttt ",
## 	 "  :  ",
## 	]

## Array of strings which illustrates the piece's position and orientation
var ascii_grid: Array

## Parameters:
## 	'init_ascii_grid': Array of strings which illustrates of the piece's position and orientation
func _init(init_ascii_grid: Array) -> void:
	ascii_grid = init_ascii_grid


## Determines the piece type by browsing the ascii grid for letters.
##
## Returns:
## 	The discovered piece type, or 'null' if no piece could be found
func _determine_piece_type() -> PieceType:
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


## Creates an piece based on an ascii drawing.
##
## Calculates the piece's type, position and orientation.
##
## Note: The ActivePiece requires a funcref to this AsciiPieceAnalyzer, and will stop working if the analyzer is
## garbage collected.
##
## Parameters:
## 	'forced_piece_orientation': (Optional) A number [0-3] representing the piece's orientation. For some pieces
## 		(such as the O piece) the orientation is ambiguous but some tests might care which one is selected.
##
## Returns:
## 	An ActivePiece instance with the appropriate piece type, position and orientation. Returns null if the type,
## 	position or orientation cannot be determined.
func create_active_piece(forced_piece_orientation: int = -1) -> ActivePiece:
	var piece_type := _determine_piece_type()
	if not piece_type:
		push_warning("Could not find piece type in '%s' ascii_grid" % ("from" if ascii_grid == ascii_grid else "to"))

	var from_shape_data := []
	for row_index in range(ascii_grid.size()):
		var row_string: String = ascii_grid[row_index]
		for col_index in range(row_string.length()):
			if row_string[col_index] == piece_type.string:
				from_shape_data.append(Vector2(col_index, row_index))
	
	var _active_piece: ActivePiece
	var possible_orientations: Array
	if forced_piece_orientation != -1:
		possible_orientations = [forced_piece_orientation]
	else:
		possible_orientations = range(piece_type.pos_arr.size())
	for pos_arr_index in possible_orientations:
		var shape_data: Array = piece_type.pos_arr[pos_arr_index]
		var position: Vector2 = from_shape_data[0] - shape_data[0]
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
	
	if _active_piece:
		_active_piece.reset_target()
	else:
		push_warning("Could not find piece position/orientation in '%s' ascii_grid"\
				% ("from" if ascii_grid == ascii_grid else "to"))
	return _active_piece


## Returns 'true' if the specified cell has a block in it or if it's outside the ascii drawing's boundaries.
func _is_cell_blocked(pos: Vector2) -> bool:
	var blocked := false
	if pos.y < 0 or pos.y >= ascii_grid.size(): blocked = true
	elif pos.x < 0 or pos.x >= ascii_grid[pos.y].length(): blocked = true
	elif ascii_grid[pos.y][pos.x] == ":": blocked = true
	return blocked
