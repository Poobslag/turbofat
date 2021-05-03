extends Node
"""
A library of level trigger effects.

These effects are each mapped to a unique string so that they can be referenced from json.
"""

"""
Rotates one or more pieces in the piece queue.
"""
class RotateNextPiecesEffect extends LevelTriggerEffect:
	enum Rotation {
		NONE, CW, CCW, FLIP
	}
	
	# an enum in Rotation corresponding to the direction to rotate
	var rotate_dir: int
	
	# The first piece index in the queue to rotate, inclusive
	var next_piece_from_index: int = 0
	
	# The last piece index in the queue to rotate, inclusive
	var next_piece_to_index: int = 999999
	
	"""
	Updates the effect's configuration.
	
	This effect's configuration accepts the following parameters:
	
	[0]: (Optional) The direction to rotate, 'cw', 'ccw', '180' or 'none'. Defaults to 'none'.
	[1]: (Optional) The first piece index in the queue to rotate. Defaults to 0.
	[2]: (Optional) The last piece index in the queue to rotate. Defaults to 999999.
	
	Example: ["cw", "0", "0"]
	"""
	func set_config(new_config: Array = []) -> void:
		if new_config.size() >= 1:
			match(new_config[0]):
				"none": rotate_dir = Rotation.NONE
				"cw": rotate_dir = Rotation.CW
				"ccw": rotate_dir = Rotation.CCW
				"180": rotate_dir = Rotation.FLIP
		
		if new_config.size() >= 2:
			next_piece_from_index = new_config[1].to_int()
		
		if new_config.size() >= 3:
			next_piece_to_index = new_config[2].to_int()
	
	
	"""
	Rotates one or more pieces in the piece queue.
	"""
	func run(_params: Array = []) -> void:
		for i in range(next_piece_from_index, next_piece_to_index + 1):
			if i >= PieceQueue.pieces.size():
				break
			var next_piece: NextPiece = PieceQueue.pieces[i]
			match rotate_dir:
				Rotation.CW: next_piece.orientation = next_piece.get_cw_orientation()
				Rotation.CCW: next_piece.orientation = next_piece.get_ccw_orientation()
				Rotation.FLIP: next_piece.orientation = next_piece.get_flip_orientation()


var effects_by_string := {
	"rotate_next_pieces": RotateNextPiecesEffect,
}
