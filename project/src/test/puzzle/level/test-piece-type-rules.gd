extends "res://addons/gut/test.gd"

var rules: PieceTypeRules

func before_each() -> void:
	rules = PieceTypeRules.new()


func test_is_default() -> void:
	assert_eq(rules.is_default(), true)
	
	rules.ordered_start = true
	assert_eq(rules.is_default(), false)


func test_convert_to_json_and_back() -> void:
	rules.ordered_start = true
	rules.start_types = [PieceTypes.piece_j, PieceTypes.piece_l]
	rules.types = [PieceTypes.piece_o, PieceTypes.piece_p]
	_convert_to_json_and_back()
	
	assert_eq(rules.ordered_start, true)
	assert_eq(rules.start_types, [PieceTypes.piece_j, PieceTypes.piece_l])
	assert_eq(rules.types, [PieceTypes.piece_o, PieceTypes.piece_p])


func _convert_to_json_and_back() -> void:
	var json := rules.to_json_array()
	rules = PieceTypeRules.new()
	rules.from_json_array(json)
