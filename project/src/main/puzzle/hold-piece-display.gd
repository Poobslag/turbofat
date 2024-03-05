class_name HoldPieceDisplay
extends PieceDisplay
## Contains logic for the 'hold piece display'.
##
## If the player has enabled the hold piece cheat, this display shows their currently held piece.

var _piece_queue: PieceQueue

func _process(_delta: float) -> void:
	refresh_tile_map(_piece_queue.hold_piece)


func initialize(piece_queue: PieceQueue) -> void:
	_piece_queue = piece_queue
