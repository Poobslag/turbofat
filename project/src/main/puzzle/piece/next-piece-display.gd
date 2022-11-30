class_name NextPieceDisplay
extends PieceDisplay
## Contains logic for a single 'next piece display'. A single display might only display the piece which is coming up 3
## pieces from now. Several displays are shown at once.

var _piece_queue: PieceQueue

## how far into the future this display should look; 0 = show the next piece, 10 = show the 11th piece
var _piece_index := 0

func initialize(piece_queue: PieceQueue, piece_index: int) -> void:
	_piece_queue = piece_queue
	_piece_index = piece_index


func _process(_delta: float) -> void:
	refresh_tile_map(_piece_queue.get_next_piece(_piece_index))
