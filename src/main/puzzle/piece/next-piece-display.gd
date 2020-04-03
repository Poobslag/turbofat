extends Node2D
"""
Contains logic for a single 'next piece display'. A single display might only display the piece which is coming up 3
pieces from now. Several displays are shown at once.
"""

# how far into the future this display should look; 0 = show the next piece, 10 = show the 11th piece
var piece_index := 0

# currently displayed piece type
var _displayed_piece

onready var _next_pieces = get_parent()

func _process(_delta: float) -> void:
	if _next_pieces and _next_pieces.next_pieces.size() > piece_index:
		var next_piece = _next_pieces.next_pieces[piece_index]
		if next_piece != _displayed_piece:
			var bounding_box := Rect2(next_piece.pos_arr[0][0].x, next_piece.pos_arr[0][0].y, 1, 1)
			# update the tilemap with the new piece type
			$TileMap.clear()
			for i in range(next_piece.pos_arr[0].size()):
				var block_pos: Vector2 = next_piece.pos_arr[0][i]
				var block_color: Vector2 = next_piece.color_arr[0][i]
				$TileMap.set_cell(block_pos.x, block_pos.y, \
						0, false, false, false, block_color)
				bounding_box = bounding_box.expand(next_piece.pos_arr[0][i])
				bounding_box = bounding_box.expand(next_piece.pos_arr[0][i] + Vector2(1, 1))
			$TileMap/CornerMap.dirty = true
			_displayed_piece = next_piece
			$TileMap.position.x = $TileMap.cell_size.x * (1.5 - (bounding_box.position.x + bounding_box.size.x / 2.0)) / 2.0
			$TileMap.position.y = $TileMap.cell_size.y * (1.5 - (bounding_box.position.y + bounding_box.size.y / 2.0)) / 2.0
