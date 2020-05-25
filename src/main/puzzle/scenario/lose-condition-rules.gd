class_name LoseConditionRules
"""
How the player loses. The player usually loses if they top out a certain number of times, but some scenarios might
have different rules.
"""

# by default, the player loses if they top out three times
var top_out := 3

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("top-out"): top_out = rules.int_value()
