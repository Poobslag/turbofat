class_name BlocksDuringRules
"""
Blocks/boxes which appear or disappear while the game is going on.
"""

enum LineClearType {
	DEFAULT, # lines drop normally following line clears
	FLOAT, # blocks are left floating; lines do not drop following line clears
	FLOAT_FALL, # blocks are left floating; the entire playfield drops following line clears
}

# key: (string) line clear type which appears in level definitions
# value: (int) an enum from LineClearType
const LINE_CLEAR_TYPES_BY_NAME := {
	"default": LineClearType.DEFAULT,
	"float": LineClearType.FLOAT,
	"float_fall": LineClearType.FLOAT_FALL,
}

# if true, the entire playfield is cleared when the player tops out
var clear_on_top_out := false

# whether lines drop following a line clear
var line_clear_type: int = LineClearType.DEFAULT

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("clear_on_top_out"): clear_on_top_out = true
	if rules.has("line_clear_type"):
		if not LINE_CLEAR_TYPES_BY_NAME.has(rules.string_value()):
			push_warning("Unrecognized line_clear_type: %s" % [rules.string_value()])
		else:
			line_clear_type = LINE_CLEAR_TYPES_BY_NAME[rules.string_value()]
