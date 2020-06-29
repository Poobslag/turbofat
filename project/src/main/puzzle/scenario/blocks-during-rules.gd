class_name BlocksDuringRules
"""
Blocks/boxes which appear or disappear while the game is going on.
"""

# if true, the entire playfield is cleared when the player tops out
var clear_on_top_out := false

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("clear-on-top-out"): clear_on_top_out = true
