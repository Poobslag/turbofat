class_name ComboBreakRules
## Things that disrupt the player's combo.

## a magic number for the 'pieces' combo break rule where the combo will never break
const UNLIMITED_PIECES := 999999

## by default, dropping 2 pieces breaks their combo
var pieces := 2

## 'true' if clearing a vegetable row (a row with no snack/cake blocks) breaks their combo
var veg_row := false

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_int("pieces").default(2)
	_rule_parser.add_bool("veg_row")


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
