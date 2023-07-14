extends BlockLevelChunkControl
## Level editor chunk which contains several blocks which make up a single piece, such as a T-Block.

enum EditorPiece {
	PIECE_J, PIECE_L, PIECE_O, PIECE_P, PIECE_Q, PIECE_T, PIECE_U, PIECE_V,
}

export (EditorPiece) var editor_piece: int setget set_editor_piece

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
var _type: PieceType = PieceTypes.piece_j

func set_editor_piece(new_editor_piece: int) -> void:
	editor_piece = new_editor_piece
	_type = _editor_pieces[editor_piece]
	_refresh_tile_map()
	_refresh_scale()


## Calculates the extents of the piece's used cells.
func _piece_extents() -> Rect2:
	var extents := Rect2(Vector2.ZERO, Vector2.ZERO)
	extents.position = _type.get_cell_position(_orientation, 0)
	for pos in _type.pos_arr[_orientation]:
		extents = extents.expand(pos)
	return extents


func _refresh_tile_map() -> void:
	var _extents := _piece_extents()
	$TileMap.clear()
	for i in range(_type.pos_arr[_orientation].size()):
		var target_pos := _type.get_cell_position(_orientation, i) - _extents.position
		$TileMap.set_block(target_pos, 0, _type.color_arr[_orientation][i])


func _on_RotateButton_pressed() -> void:
	_orientation = _type.get_cw_orientation(_orientation)
	_refresh_tile_map()
