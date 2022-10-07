class_name BlocksDuringRules
## Blocks/boxes/pickups which appear or disappear while the game is going on.

enum FilledLineClearOrder {
	DEFAULT,
	HIGHEST,
	LOWEST,
	OLDEST,
	RANDOM,
}

enum ShuffleLinesType {
	NONE, # do not shuffle
	SLICE, # start at a random position within the inserted lines
	BAG, # 'bag shuffle'; ensure each row is picked the same number of times
}

enum LineClearType {
	DEFAULT, # lines drop normally following line clears
	FLOAT, # blocks are left floating; lines do not drop following line clears
	FLOAT_FALL, # blocks are left floating; the entire playfield drops following line clears
}

enum PickupType {
	DEFAULT, # pickups raise/lower with the playfield blocks
	FLOAT, # pickups float in place behind the playfield blocks
	FLOAT_REGEN, # pickups float in place and regenerate if collected
}

## If false, lines will not be cleared when the player fills them. They can still be cleared with a level trigger
## effect.
var clear_filled_lines := true

## if true, the entire playfield is cleared when the player tops out
var clear_on_top_out := false

## How many pieces or trigger effects a line waits before being cleared; 0 = immediate
##
## The effect of setting this to a nonzero value is that the player fills a line, then must drop a few extra pieces
## elsewhere before the line clears
var filled_line_clear_delay := 0

## The maximum number of lines which can be cleared simultaneously. Additional lines are left uncleared until the next
## piece is dropped.
var filled_line_clear_max: int = 999999

## The minimum number of lines which must be filled to trigger line clears.
##
## If this is set to 3, filled lines will remain on the playfield until the player fills 3 complete lines. Then all
## filled lines will be cleared.
var filled_line_clear_min: int = 0

## The order in which filled lines are cleared. This is purely cosmetic unless other rules are in place to prevent or
## delay filled lines from being cleared.
var filled_line_clear_order: int = FilledLineClearOrder.DEFAULT

## tiles key for 'filled' lines -- lines which fill from the top for levels with narrow playfields
var fill_lines: String

## whether blocks drop following a line clear
var line_clear_type: int = LineClearType.DEFAULT

## whether pickups move with the playfield blocks
var pickup_type: int = PickupType.DEFAULT

## if true, the entire playfield is refreshed when the player tops out
var refresh_on_top_out := false

## whether inserted rows should start from a random row in the source tiles instead of starting from the top
var shuffle_inserted_lines: int = ShuffleLinesType.NONE

## whether filled rows should start from a random row in the source tiles instead of starting from the top
var shuffle_filled_lines: int = ShuffleLinesType.NONE

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_bool("clear_filled_lines", "no_clear_filled_lines").default(true)
	_rule_parser.add_bool("clear_on_top_out")
	_rule_parser.add_int("filled_line_clear_delay")
	_rule_parser.add_int("filled_line_clear_max").default(999999)
	_rule_parser.add_int("filled_line_clear_min")
	_rule_parser.add_enum("filled_line_clear_order", FilledLineClearOrder)
	_rule_parser.add_string("fill_lines")
	_rule_parser.add_enum("line_clear_type", LineClearType)
	_rule_parser.add_enum("pickup_type", PickupType)
	_rule_parser.add_bool("refresh_on_top_out")
	_rule_parser.add_enum("shuffle_filled_lines", ShuffleLinesType) \
			.implied(ShuffleLinesType.BAG)
	_rule_parser.add_enum("shuffle_inserted_lines", ShuffleLinesType) \
			.implied(ShuffleLinesType.BAG)


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
