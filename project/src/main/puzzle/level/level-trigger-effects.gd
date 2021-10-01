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
	var rotate_dir: int = Rotation.NONE
	
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
	func set_config(new_config: Dictionary = {}) -> void:
		if new_config.has("0"):
			match new_config["0"]:
				"none": rotate_dir = Rotation.NONE
				"cw": rotate_dir = Rotation.CW
				"ccw": rotate_dir = Rotation.CCW
				"180": rotate_dir = Rotation.FLIP
		
		if new_config.has("1"):
			next_piece_from_index = new_config["1"].to_int()
		
		if new_config.has("2"):
			next_piece_to_index = new_config["2"].to_int()
	
	
	"""
	Rotates one or more pieces in the piece queue.
	"""
	func run() -> void:
		var pieces: Array = CurrentLevel.puzzle.get_piece_queue().pieces
		for i in range(next_piece_from_index, next_piece_to_index + 1):
			if i >= pieces.size():
				break
			var next_piece: NextPiece = pieces[i]
			match rotate_dir:
				Rotation.CW: next_piece.orientation = next_piece.get_cw_orientation()
				Rotation.CCW: next_piece.orientation = next_piece.get_ccw_orientation()
				Rotation.FLIP: next_piece.orientation = next_piece.get_flip_orientation()


"""
Inserts a new line at the bottom of the playfield.
"""
class InsertLineEffect extends LevelTriggerEffect:
	# (Optional) a key corresponding to a set of tiles in LevelTiles for the tiles to insert
	var tiles_key: String
	
	"""
	Updates the effect's configuration.
	
	This effect's configuration accepts the following parameters:
	
	[tiles_key]: (Optional) A key corresponding to a set of tiles in LevelTiles for the tiles to insert.
	
	Example: ["tiles_key=0"]
	"""
	func set_config(new_config: Dictionary = {}) -> void:
		tiles_key = new_config.get("tiles_key", "")
	
	
	"""
	Inserts a new line at the bottom of the playfield.
	"""
	func run() -> void:
		CurrentLevel.puzzle.get_playfield().line_inserter.insert_line(tiles_key)


var effects_by_string := {
	"rotate_next_pieces": RotateNextPiecesEffect,
	"insert_line": InsertLineEffect,
}

"""
Creates a new LevelTriggerEffect instance.

Parameters:
	'effect_key': A string key corresponding to the level trigger effect, such as 'insert_line'.
	
	'effect_config': (Optional) An array of strings defining the effect's behavior.
"""
func create(effect_key: String, effect_config: Dictionary = {}) -> LevelTriggerEffect:
	if not effects_by_string.has(effect_key):
		push_warning("Unrecognized effect: %s" % [effect_key])
	var effect_script: GDScript = effects_by_string.get(effect_key)
	var effect: LevelTriggerEffect = effect_script.new()
	if effect_config:
		effect.set_config(effect_config)
	return effect
