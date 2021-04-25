class_name RankRules
"""
Tweaks to rank calculation.
"""

# multiplier for the expected box_points_per_line. '3.0' means the player
# needs 3x the usual box points per line to get a good rank
var box_factor := 1.0

# multiplier for the expected combo_points_per_line. '3.0' means the player
# needs 3x the usual combo points per line to get a good rank
var combo_factor := 1.0

# extra time it takes an expert to move the piece where it belongs
var extra_seconds_per_piece := 0.0

# expected combo per customer
var customer_combo := 0

# expected leftover lines
var leftover_lines := 0

# 'true' if the results screen should be skipped. Used for tutorials.
var skip_results: bool

# Bonus rank given if the player achieves the level's success condition. Useful when designing levels where
# achieving a target score of 1,000 is an A grade, but failing with a score of 999 is also an A grade. This property
# gives the player a little bump in rank so achieving the target score will always result in a higher grade.
var success_bonus := 0.0

# rank penalty applied each time the player tops out
var top_out_penalty := 4

# If 'true' the player is not given a rank for this level.
var unranked: bool = false

func from_json_string_array(json: Array) -> void:
	var rules := RuleParser.new(json)
	if rules.has("box_factor"): box_factor = rules.float_value()
	if rules.has("combo_factor"): combo_factor = rules.float_value()
	if rules.has("customer_combo"): customer_combo = rules.int_value()
	if rules.has("leftover_lines"): leftover_lines = rules.int_value()
	if rules.has("skip_results"): skip_results = true
	if rules.has("success_bonus"): success_bonus = rules.float_value()
	if rules.has("top_out_penalty"): top_out_penalty = rules.int_value()
	if rules.has("unranked"): unranked = true
	if rules.has("extra_seconds_per_piece"): extra_seconds_per_piece = rules.float_value()
