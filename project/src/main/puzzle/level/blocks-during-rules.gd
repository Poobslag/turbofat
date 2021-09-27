class_name BlocksDuringRules
"""
Blocks/boxes which appear or disappear while the game is going on.
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

# key: (string) line clear type which appears in level definitions
# value: (int) an enum from LineClearType
const LINE_CLEAR_TYPES_BY_NAME := {
	"default": LineClearType.DEFAULT,
	"float": LineClearType.FLOAT,
	"float_fall": LineClearType.FLOAT_FALL,
}

# key: (string) pickup type which appears in level definitions
# value: (int) an enum from PickupType
const PICKUP_TYPES_BY_NAME := {
	"default": PickupType.DEFAULT,
	"float": PickupType.FLOAT,
	"float_regen": PickupType.FLOAT_REGEN,
}

# if true, the entire playfield is cleared when the player tops out
var clear_on_top_out := false

# whether blocks drop following a line clear
var line_clear_type: int = LineClearType.DEFAULT

# whether pickups move with the playfield blocks
var pickup_type: int = PickupType.DEFAULT

# whether inserted rows should start from a random row in the source tiles instead of starting from the top
var random_tiles_start: bool = false

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("clear_on_top_out"): clear_on_top_out = true
	if rules.has("line_clear_type"):
		if not LINE_CLEAR_TYPES_BY_NAME.has(rules.string_value()):
			push_warning("Unrecognized line_clear_type: %s" % [rules.string_value()])
		else:
			line_clear_type = LINE_CLEAR_TYPES_BY_NAME[rules.string_value()]
	if rules.has("pickup_type"):
		if not PICKUP_TYPES_BY_NAME.has(rules.string_value()):
			push_warning("Unrecognized pickup_type: %s" % [rules.string_value()])
		else:
			pickup_type = PICKUP_TYPES_BY_NAME[rules.string_value()]
	if rules.has("random_tiles_start"): random_tiles_start = true
