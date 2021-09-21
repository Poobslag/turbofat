class_name RankRules
"""
Tweaks to rank calculation.
"""

enum ShowRank {
	DEFAULT, # rank should be automatically shown/hidden based on the finish condition
	SHOW, # rank should be shown
	HIDE, # rank should be hidden
}

# multiplier for the expected box_score_per_line. '3.0' means the player
# needs 3x the usual box points per line to get a good rank
var box_factor := 1.0

# multiplier for the expected combo_score_per_line. '3.0' means the player
# needs 3x the usual combo points per line to get a good rank
var combo_factor := 1.0

# expected combo per customer
var customer_combo := 0

# extra time it takes an expert to move the piece where it belongs
var extra_seconds_per_piece := 0.0

# expected leftover lines
var leftover_lines := 0

# expected bonus points for pickups
var master_pickup_score := 0.0

# expected bonus points per line awarded for pickups
var master_pickup_score_per_line := 0.0

var show_boxes_rank: int = ShowRank.DEFAULT
var show_combos_rank: int = ShowRank.DEFAULT
var show_lines_rank: int = ShowRank.DEFAULT
var show_pickups_rank: int = ShowRank.DEFAULT
var show_pieces_rank: int = ShowRank.DEFAULT
var show_speed_rank: int = ShowRank.DEFAULT

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
	if rules.has("extra_seconds_per_piece"): extra_seconds_per_piece = rules.float_value()
	if rules.has("leftover_lines"): leftover_lines = rules.int_value()
	if rules.has("master_pickup_score"): master_pickup_score = rules.float_value()
	if rules.has("master_pickup_score_per_line"): master_pickup_score_per_line = rules.float_value()
	
	_assign_show_rank(rules, "boxes")
	_assign_show_rank(rules, "combos")
	_assign_show_rank(rules, "lines")
	_assign_show_rank(rules, "pickups")
	_assign_show_rank(rules, "pieces")
	_assign_show_rank(rules, "speed")
	
	if rules.has("skip_results"): skip_results = true
	if rules.has("success_bonus"): success_bonus = rules.float_value()
	if rules.has("top_out_penalty"): top_out_penalty = rules.int_value()
	if rules.has("unranked"): unranked = true


"""
Populates one of our 'show_rank' fields based on the specified rule.

A value of 'hide_foo_rank' sets the show_foo_rank field to ShowRank.HIDE. A value of 'show_foo_rank' sets the
show_foo_rank field to ShowRank.SHOW.

Parameters:
	'rules': The rule parser containing 'hide_foo_rank' and 'show_foo_rank' rules.
	
	'rank_string': A string such as 'boxes' or 'pieces' indicating which rule should be parsed and assigned.
"""
func _assign_show_rank(rules: RuleParser, rank_string: String) -> void:
	var hide_string := "hide_%s_rank" % [rank_string]
	var show_string := "show_%s_rank" % [rank_string]
	if rules.has(hide_string) != rules.has(show_string):
		# one of hide_rank and show_rank is present; assign it
		set("show_%s_rank" % [rank_string], ShowRank.SHOW if rules.has(show_string) else ShowRank.HIDE)
	elif rules.has(hide_string) and rules.has(show_string):
		# both hide_rank and show_rank are present; report an error
		push_warning("'%s' conflicts with '%s'" % [hide_string, show_string])
	else:
		# neither hide_rank nor show_rank are present; ignore it
		pass
