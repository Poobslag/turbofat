class_name PieceTypeRules
"""
Pieces the player is given.
"""

# pieces to prepend to the piece queue before a game begins. these pieces are shuffled
var start_types: Array = []

# piece types to choose from. if empty, reverts to the default 8 types (jlopqtuv)
var types: Array = []

func from_json_string_array(json: Array) -> void:
	var json_types: Dictionary = {
		"piece_j": PieceTypes.piece_j,
		"piece_l": PieceTypes.piece_l,
		"piece_o": PieceTypes.piece_o,
		"piece_p": PieceTypes.piece_p,
		"piece_q": PieceTypes.piece_q,
		"piece_t": PieceTypes.piece_t,
		"piece_u": PieceTypes.piece_u,
		"piece_v": PieceTypes.piece_v,
	}
	
	var rules := RuleParser.new(json)
	for key in json_types:
		if rules.has(key): types.append(json_types[key])
		if rules.has("start_%s" % key): start_types.append(json_types[key])
