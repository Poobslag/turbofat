class_name OtherRules
## Rules which are unique enough that it doesn't make sense to put them in their own groups.

enum SuppressPieceRotation {
	NONE, # piece rotation is not suppressed
	ROTATION, # piece rotation is suppressed, but rotation signals still fire for things like sfx
	ROTATION_AND_SIGNALS # piece rotation is suppressed, no rotation signals fire for things like sfx
}

## 'true' for levels which follow tutorial levels
var after_tutorial := false

## When the player finishes the level, all lines are cleared
var clear_on_finish := true

## 'true' to make the visual combo indicators easier to see
var enhance_combo_fx := false

## 'true' for non-interactive tutorial levels which don't let the player do anything
var non_interactive := false

## enum from SuppressPieceRotation for whether pieces can rotate
var suppress_piece_rotation := SuppressPieceRotation.NONE

## enum from SuppressPieceRotation for whether pieces can be initially rotated by holding a rotate key
var suppress_piece_initial_rotation := SuppressPieceRotation.NONE

## When the player first launches the game and does the tutorial, we skip the start button and countdown.
var skip_intro := false

## If the player restarts, they restart from this level (used for tutorials)
var start_level: String

## enum from PuzzleTileMap.TileSetType which affects the blocks' appearance (and sometimes behavior)
var tile_set := PuzzleTileMap.TileSetType.DEFAULT

## 'true' for tutorial levels which are led by Turbo
var tutorial := false

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_bool("after_tutorial")
	_rule_parser.add_bool("clear_on_finish", "no_clear_on_finish").default(true)
	_rule_parser.add_bool("enhance_combo_fx")
	_rule_parser.add_bool("non_interactive")
	_rule_parser.add_enum("suppress_piece_rotation", SuppressPieceRotation) \
			.implied(SuppressPieceRotation.ROTATION)
	_rule_parser.add_enum("suppress_piece_initial_rotation", SuppressPieceRotation) \
			.implied(SuppressPieceRotation.ROTATION)
	_rule_parser.add_bool("skip_intro")
	_rule_parser.add_string("start_level")
	_rule_parser.add_enum("tile_set", PuzzleTileMap.TileSetType)
	_rule_parser.add_bool("tutorial")


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
