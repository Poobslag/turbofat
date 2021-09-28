class_name RankRules
"""
Tweaks to rank calculation.
"""

"""
Parses a json string like 'hide_combos_rank' into an enum like 'ShowRank.HIDE'
"""
class ShowRankPropertyParser extends RuleParser.PropertyParser:
	var _hide_string: String
	
	func _init(init_target: Object, init_name: String).(init_target, init_name) -> void:
		default = []
		_hide_string = "hide%s" % [init_name.trim_prefix("show")]
		keys.append(_hide_string)
	
	
	func to_json_strings() -> Array:
		var result := []
		match target.get(name):
			ShowRank.SHOW: result.append(name)
			ShowRank.HIDE: result.append(_hide_string)
		return result
	
	
	func from_json_string(json: String) -> void:
		match json:
			name: target.set(name, ShowRank.SHOW)
			_hide_string: target.set(name, ShowRank.HIDE)
			_: push_warning("Unrecognized: %s" % [json])
	
	
	func is_default() -> bool:
		return target.get(name) == ShowRank.DEFAULT


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
var skip_results := false

# Bonus rank given if the player achieves the level's success condition. Useful when designing levels where
# achieving a target score of 1,000 is an A grade, but failing with a score of 999 is also an A grade. This property
# gives the player a little bump in rank so achieving the target score will always result in a higher grade.
var success_bonus := 0.0

# rank penalty applied each time the player tops out
var top_out_penalty := 4

# If 'true' the player is not given a rank for this level.
var unranked := false

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_float("box_factor").default(1.0)
	_rule_parser.add_float("combo_factor").default(1.0)
	_rule_parser.add_int("customer_combo")
	_rule_parser.add_float("extra_seconds_per_piece")
	_rule_parser.add_int("leftover_lines")
	_rule_parser.add_float("master_pickup_score")
	_rule_parser.add_float("master_pickup_score_per_line")
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_boxes_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_combos_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_lines_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_pickups_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_pieces_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_speed_rank"))
	_rule_parser.add_bool("skip_results")
	_rule_parser.add_float("success_bonus")
	_rule_parser.add_int("top_out_penalty").default(4)
	_rule_parser.add_bool("unranked")


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
