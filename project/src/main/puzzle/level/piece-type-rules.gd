class_name PieceTypeRules
## Pieces the player is given.

## Parses json strings like 'piece_j' into enums like PieceTypes.piece_j.
##
## Unlike most property parsers which only populate a single property, this parser populates both the 'types' and
## 'start_types' fields.
class PieceTypesPropertyParser extends RuleParser.PropertyParser:
	var start_name: String = "start_types"
	
	func _init(init_target: Object).(init_target, "types") -> void:
		default = []
		keys = []
		for piece_string in PieceTypes.pieces_by_string:
			keys.append("piece_%s" % [piece_string])
			keys.append("start_piece_%s" % [piece_string])
	
	
	func to_json_strings() -> Array:
		var result := []
		for type in target().get(name):
			result.append("piece_%s" % [type.string])
		for type in target().get(start_name):
			result.append("start_piece_%s" % [type.string])
		return result
	
	
	func from_json_string(json: String) -> void:
		if json.begins_with("piece_") \
				and PieceTypes.pieces_by_string.has(json.trim_prefix("piece_")):
			target().get(name).append(PieceTypes.pieces_by_string[json.trim_prefix("piece_")])
		elif json.begins_with("start_piece_") \
				and PieceTypes.pieces_by_string.has(json.trim_prefix("start_piece_")):
			target().get(start_name).append(PieceTypes.pieces_by_string[json.trim_prefix("start_piece_")])
		else:
			push_warning("Unrecognized: %s" % [json])
	
	
	func is_default() -> bool:
		return target().get(name).empty() and target().get(start_name).empty()

## if 'true', the start pieces always appear in the same order instead of being shuffled.
var ordered_start: bool = false

## list of PieceTypes to prepend to the piece queue before a game begins. these pieces are shuffled
var start_types := []

## list of PieceTypes to choose from. if empty, defaults to the basic 8 types (jlopqtuv)
var types := []

## if 'true', the bag algorithm rerolls the extra piece once if it comes up as an O piece
var suppress_o_piece: bool = true

## If 'true', the bag algorithm adjusts its shuffling and extra piece generation to avoid generating the same piece
## consecutively.
var suppress_repeat_piece: bool = true

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_bool("ordered_start")
	_rule_parser.add_bool("suppress_o_piece", "no_suppress_o_piece").default(true)
	_rule_parser.add_bool("suppress_repeat_piece", "no_suppress_repeat_piece").default(true)
	_rule_parser.add(PieceTypesPropertyParser.new(self))


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
