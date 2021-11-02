extends "res://addons/gut/test.gd"

func test_empty() -> void:
	assert_eq([0], non_adjacent_indexes([], "p"))


func test_nothing_matches() -> void:
	assert_eq([0, 1, 2, 3], non_adjacent_indexes(["l", "l", "l"], "o"))


func test_many_matches() -> void:
	assert_eq([0, 3, 6], non_adjacent_indexes(["l", "o", "l", "l", "o", "l"], "o"))


func test_from_index() -> void:
	assert_eq([3, 4], non_adjacent_indexes(["l", "o", "l", "l"], "o", 3))
	assert_eq([4], non_adjacent_indexes(["l", "o", "l", "l"], "o", 4))


func test_no_possibilities() -> void:
	assert_eq([], non_adjacent_indexes(["o", "l", "o"], "o"))


"""
Convenience function which converts strings into appropriate piece parameters.

Parameters:
	'piece_strings': An array of strings like 't' and 'o' corresponding to piece shapes.
	
	'piece_type_string': A string like 't' or 'o' corresponding to a piece type.
	
	'from_index': The lowest position to check in the piece queue.
"""
func non_adjacent_indexes(piece_strings: Array, piece_type_string: String, from_index: int = 0) -> Array:
	var pieces := []
	for piece_string in piece_strings:
		var next_piece := NextPiece.new()
		next_piece.type = PieceTypes.pieces_by_string.get(piece_string)
		pieces.append(next_piece)
	var piece_type: PieceType = PieceTypes.pieces_by_string.get(piece_type_string)
	return PieceQueue.non_adjacent_indexes(pieces, piece_type, from_index)
