class_name PieceTypeRules
"""
Pieces the player is given.
"""

# if 'true', the start pieces always appear in the same order instead of being shuffled.
var ordered_start: bool = false

# pieces to prepend to the piece queue before a game begins. these pieces are shuffled
var start_types := []

# piece types to choose from. if empty, reverts to the default 8 types (jlopqtuv)
var types := []

func from_json_string_array(json: Array) -> void:
	var types_by_json_string := {
		"piece_j": PieceTypes.piece_j,
		"piece_l": PieceTypes.piece_l,
		"piece_o": PieceTypes.piece_o,
		"piece_p": PieceTypes.piece_p,
		"piece_q": PieceTypes.piece_q,
		"piece_t": PieceTypes.piece_t,
		"piece_u": PieceTypes.piece_u,
		"piece_v": PieceTypes.piece_v,
	}
	
	for json_obj in json:
		var json_string: String = json_obj
		if json_string == "ordered_start":
			ordered_start = true
		elif types_by_json_string.has(json_string):
			types.append(types_by_json_string[json_string])
		elif json_string.begins_with("start_") \
				and types_by_json_string.has(json_string.trim_prefix("start_")):
			start_types.append(types_by_json_string[json_string.trim_prefix("start_")])
