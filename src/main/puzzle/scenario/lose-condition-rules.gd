class_name LoseConditionRules
"""
How the player loses. The player usually loses if they top out a certain number of times, but some scenarios might
have different rules.
"""

# by default, the player loses if they top out three times
var top_out := 3

"""
Populates this object with json data.
"""
func from_string_array(strings: Array) -> void:
	var rules := RuleParser.new(strings)
	if rules.has("top-out"): top_out = rules.int_value()
