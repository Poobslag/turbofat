class_name BlocksDuringRules
"""
Blocks/boxes/pickups which appear or disappear while the game is going on.
"""

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

# if true, the entire playfield is cleared when the player tops out
var clear_on_top_out := false

# whether blocks drop following a line clear
var line_clear_type: int = LineClearType.DEFAULT

# whether pickups move with the playfield blocks
var pickup_type: int = PickupType.DEFAULT

# whether inserted rows should start from a random row in the source tiles instead of starting from the top
var random_tiles_start: bool = false

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_bool("clear_on_top_out")
	_rule_parser.add_enum("line_clear_type", LineClearType)
	_rule_parser.add_enum("pickup_type", PickupType)
	_rule_parser.add_bool("random_tiles_start")


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
