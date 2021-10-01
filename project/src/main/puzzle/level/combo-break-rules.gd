class_name ComboBreakRules
"""
Things that disrupt the player's combo.
"""

# a magic number for the 'pieces' combo break rule where the combo will never break
const UNLIMITED_PIECES := 999999

# by default, dropping 2 pieces breaks their combo
var pieces := 2

# 'true' if clearing a vegetable row (a row with no snack/cake blocks) breaks their combo
var veg_row := false

func from_json_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("pieces"): pieces = rules.int_value()
	if rules.has("veg_row"): veg_row = true
