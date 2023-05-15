class_name PieceTypeMutator
## Modifies a piece type by removing cells.

## Piece type to remove.
var piece_type: PieceType

## Vector2 offsets to apply when cycling from one orientation to the next.
var _rotation_offsets := []

## Initializes PieceTypeMutator with the specified PieceType.
##
## Initializes the '_rotation_offsets' field so that we can determine which cells correspond to different parts of a
## piece as it cycles from one orientation to the next.
##
## Note: This should never be initialized with a standard PieceType from PieceTypes. PieceTypeMutator does not operate
## on a copy -- if it removes a cell from the standard T-piece which is used throughout the game, then all T-pieces
## will be modified!
func _init(init_piece_type: PieceType) -> void:
	piece_type = init_piece_type
	
	for _orientation in range(piece_type.pos_arr.size()):
		_rotation_offsets.append(Vector2.ZERO)
	
	for orientation in range(piece_type.pos_arr.size()):
		var new_orientation := piece_type.get_cw_orientation(orientation)
		
		if not piece_type.pos_arr[orientation] or not piece_type.pos_arr[new_orientation]:
			continue
		
		var expected_min: Vector2 = _rotate_vector2_cw(piece_type.pos_arr[orientation][0])
		for j in range(1, piece_type.pos_arr[orientation].size()):
			var expected: Vector2 = _rotate_vector2_cw(piece_type.pos_arr[orientation][j])
			expected_min.x = min(expected_min.x, expected.x)
			expected_min.y = min(expected_min.y, expected.y)
		
		var actual_min: Vector2 = piece_type.pos_arr[new_orientation][0]
		for j in range(1, piece_type.pos_arr[new_orientation].size()):
			var actual: Vector2 = piece_type.pos_arr[new_orientation][j]
			actual_min.x = min(actual_min.x, actual.x)
			actual_min.y = min(actual_min.y, actual.y)
		
		_rotation_offsets[orientation] = actual_min - expected_min


## Remove a cell from the PieceType we were initialized with.
##
## A PieceType defines cell positions for each orientation the PieceType cycles through. This method removes the
## specified cell from the specified orientation, as well as all other corresponding cells from other orientations.
##
## Parameters:
## 	'orientation': The orientation of the piece
##
## 	'cell_to_remove': An (x, y) position of a cell to remove
func remove_cell(orientation: int, cell_to_remove: Vector2) -> void:
	var next_orientation := orientation
	var next_cell_to_remove := cell_to_remove
	var removed_orientations := {}
	
	# remove the appropriate cell from the current orientation of the piece
	while not next_orientation in removed_orientations:
		removed_orientations[next_orientation] = true
		
		var next_pos_arr: Array = piece_type.pos_arr[next_orientation]
		var next_color_arr: Array = piece_type.color_arr[next_orientation]
		
		var cell_index: int = next_pos_arr.find(next_cell_to_remove)
		if cell_index == -1:
			push_warning("Cell not found; cannot remove cell %s from piece type '%s'"
					% [cell_to_remove, piece_type.string])
			continue
		else:
			next_pos_arr.remove(cell_index)
			next_color_arr.remove(cell_index)
		
		# update the color_arr to reshape the piece
		for color_arr_index in range(next_color_arr.size()):
			var color_x: int = 0
			if next_pos_arr[color_arr_index] + Vector2.UP in next_pos_arr:
				color_x = PuzzleConnect.set_u(color_x)
			if next_pos_arr[color_arr_index] + Vector2.DOWN in next_pos_arr:
				color_x = PuzzleConnect.set_distance(color_x)
			if next_pos_arr[color_arr_index] + Vector2.LEFT in next_pos_arr:
				color_x = PuzzleConnect.set_l(color_x)
			if next_pos_arr[color_arr_index] + Vector2.RIGHT in next_pos_arr:
				color_x = PuzzleConnect.set_r(color_x)
			next_color_arr[color_arr_index].x = color_x
		
		next_cell_to_remove = _rotate_vector2_cw(next_cell_to_remove) + _rotation_offsets[next_orientation]
		next_orientation = piece_type.get_cw_orientation(next_orientation)


## Rotates a Vector2 coordinate clockwise around the origin.
func _rotate_vector2_cw(pos: Vector2) -> Vector2:
	return Vector2(-pos.y, pos.x)
