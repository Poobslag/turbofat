"""
Contains logic for a single 'next piece display'. A single display might only display the piece which is coming up 3
pieces from now. Several displays are shown at once.
"""
extends Node2D

onready var NextPieces = get_node("..")

# currently displayed piece type
var displayed_piece

# how far into the future this display should look; 0 = show the next piece, 10 = show the 11th piece
var piece_index = 0

func _process(delta):
	if NextPieces != null && NextPieces.next_pieces.size() > piece_index:
		var next_piece = NextPieces.next_pieces[piece_index]
		if next_piece != displayed_piece:
			# update the tilemap with the new piece type
			$TileMap.clear()
			for i in range(0, next_piece.pos_arr[0].size()):
				var block_pos = next_piece.pos_arr[0][i]
				var block_color = next_piece.color_arr[0][i]
				$TileMap.set_cell(block_pos.x, block_pos.y, \
						0, false, false, false, block_color)
			$TileMap/CornerMap.dirty = true
			displayed_piece = next_piece
