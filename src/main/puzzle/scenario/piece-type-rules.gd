class_name PieceTypeRules
"""
Pieces the player is given.
"""

# pieces the player is given at the start of a level (shuffled)
var start_types: Array = []

# pieces the player is given during a level
var types: Array = []

func from_string_array(strings: Array) -> void:
	var json_types: Dictionary = {
		"piece-j": PieceTypes.piece_j,
		"piece-l": PieceTypes.piece_l,
		"piece-o": PieceTypes.piece_o,
		"piece-p": PieceTypes.piece_p,
		"piece-q": PieceTypes.piece_q,
		"piece-t": PieceTypes.piece_t,
		"piece-u": PieceTypes.piece_u,
		"piece-v": PieceTypes.piece_v,
	}
	
	var rules := RuleParser.new(strings)
	for key in json_types:
		if rules.has(key): types.append(json_types[key])
		if rules.has("start-%s" % key): start_types.append(json_types[key])
