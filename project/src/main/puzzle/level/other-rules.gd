class_name OtherRules
"""
Rules which are unique enough that it doesn't make sense to put them in their own groups.
"""

# 'true' for tutorial levels which are led by Turbo
var tutorial := false

# 'true' for non-interactive tutorial levels which don't let the player do anything
var non_interactive := false

# 'true' for levels which follow tutorial levels
var after_tutorial := false

# 'true' to make the visual combo indicators easier to see
var enhance_combo_fx := false

# If the player restarts, they restart from this level (used for tutorials)
var start_level: String

# When the player finishes the level, all lines are cleared
var clear_on_finish := true

# When the player first launches the game and does the tutorial, we skip the start button and countdown.
var skip_intro := false

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("after_tutorial"): after_tutorial = true
	if rules.has("enhance_combo_fx"): enhance_combo_fx = true
	if rules.has("no_clear_on_finish"): clear_on_finish = false
	if rules.has("start_level"): start_level = rules.string_value()
	if rules.has("tutorial"): tutorial = true
	if rules.has("non_interactive"): non_interactive = true
