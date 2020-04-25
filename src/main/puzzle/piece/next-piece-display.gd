class_name NextPieceDisplay
extends Node2D
"""
Contains logic for a single 'next piece display'. A single display might only display the piece which is coming up 3
pieces from now. Several displays are shown at once.
"""

const UNROTATED := PieceType.Orientation.UNROTATED

# how far into the future this display should look; 0 = show the next piece, 10 = show the 11th piece
var _piece_index := 0

# currently displayed piece type
var _displayed_piece

# queue of upcoming randomized pieces
var _piece_queue: PieceQueue

func initialize(piece_queue: PieceQueue, piece_index: int) -> void:
	_piece_queue = piece_queue
	_piece_index = piece_index


func _process(_delta: float) -> void:
	var next_piece := _piece_queue.get_next_piece(_piece_index)
	if next_piece != _displayed_piece:
		var bounding_box := Rect2(next_piece.get_cell_position(UNROTATED, 0), Vector2(1.0, 1.0))
		# update the tilemap with the new piece type
		$TileMap.clear()
		for i in range(next_piece.pos_arr[0].size()):
			var block_pos := next_piece.get_cell_position(UNROTATED, i)
			var block_color := next_piece.get_cell_color(UNROTATED, i)
			$TileMap.set_cell(block_pos.x, block_pos.y, 0, false, false, false, block_color)
			bounding_box = bounding_box.expand(next_piece.get_cell_position(UNROTATED, i))
			bounding_box = bounding_box.expand(next_piece.get_cell_position(UNROTATED, i) + Vector2(1, 1))
		$TileMap/CornerMap.dirty = true
		_displayed_piece = next_piece
		$TileMap.position = $TileMap.cell_size \
				* (Vector2(1.5, 1.5) - (bounding_box.position + bounding_box.size / 2.0)) / 2.0
