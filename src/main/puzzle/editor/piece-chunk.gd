class_name PieceControl
extends LevelChunkControl
"""
A level editor chunk which contains several blocks which make up a single piece, such as a t-piece.
"""

enum EditorPiece {
	PIECE_J, PIECE_L, PIECE_O, PIECE_P, PIECE_Q, PIECE_T, PIECE_U, PIECE_V,
}

export (EditorPiece) var _editor_piece: int

var _editor_pieces := {
	EditorPiece.PIECE_J: PieceTypes.piece_j,
	EditorPiece.PIECE_L: PieceTypes.piece_l,
	EditorPiece.PIECE_O: PieceTypes.piece_o,
	EditorPiece.PIECE_P: PieceTypes.piece_p,
	EditorPiece.PIECE_Q: PieceTypes.piece_q,
	EditorPiece.PIECE_T: PieceTypes.piece_t,
	EditorPiece.PIECE_U: PieceTypes.piece_u,
	EditorPiece.PIECE_V: PieceTypes.piece_v,
}

var _orientation := 0

func _refresh_tilemap() -> void:
	$TileMap.clear()
	
	var piece: PieceType = _editor_pieces[_editor_piece]
	for i in range(piece.pos_arr[_orientation].size()):
		$TileMap.set_block(piece.pos_arr[_orientation][i], 0, piece.color_arr[_orientation][i])
