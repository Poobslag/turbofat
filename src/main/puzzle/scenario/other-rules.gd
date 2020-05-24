class_name OtherRules
"""
Rules which are unique enough that it doesn't make sense to put them in their own groups.
"""

var tutorial := false

# If the player restarts, they restart from this scenario (used for tutorials)
var start_scenario_name: String

func from_string_array(strings: Array) -> void:
	var rules := RuleParser.new(strings)
	if rules.has("tutorial"): tutorial = true
	if rules.has("start-scenario"): start_scenario_name = rules.string_value()
