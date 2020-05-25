class_name OtherRules
"""
Rules which are unique enough that it doesn't make sense to put them in their own groups.
"""

# 'true' for tutorial scenarios which are led by Turbo
var tutorial := false

# 'true' for scenarios which follow tutorial scenarios
var after_tutorial := false

# If the player restarts, they restart from this scenario (used for tutorials)
var start_scenario_name: String

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("tutorial"): tutorial = true
	if rules.has("after-tutorial"): after_tutorial = true
	if rules.has("start-scenario"): start_scenario_name = rules.string_value()
