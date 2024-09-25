class_name RankRules
## Tweaks to rank calculation.

## Parses legacy rank criteria such as 'legacy box_factor' into the 'legacy_rules' field.
class LegacyCriteriaParser extends RuleParser.PropertyParser:
	func _init(init_target: Object, init_name: String).(init_target, init_name) -> void:
		pass
	
	
	# don't write legacy properties, we don't want to preserve them in future versions of the game
	func to_json_strings() -> Array:
		return []
	
	
	func from_json_string(json: String) -> void:
		var json_strings := json.split(" ")
		
		match json_strings[1]:
			"box_factor", \
			"combo_factor", \
			"extra_seconds_per_piece", \
			"master_pickup_score", \
			"master_pickup_score_per_line":
				target().legacy_rules[json_strings[1]] = float(json_strings[2])
			"customer_combo", \
			"leftover_lines", \
			"preplaced_pieces":
				target().legacy_rules[json_strings[1]] = int(json_strings[2])


## Parses a json string like 'rank_criteria m=1000 s=800' into a RankCriteria instance.
class RankCriteriaParser extends RuleParser.PropertyParser:
	func _init(init_target: Object, init_name: String).(init_target, init_name) -> void:
		pass
	
	func to_json_strings() -> Array:
		var result := "rank_criteria"
		for grade in target().rank_criteria.thresholds_by_grade:
			var threshold: int = target().rank_criteria.thresholds_by_grade[grade]
			result += " %s=%s" % [grade.to_lower(), threshold]
		return [result]
	
	
	func from_json_string(json: String) -> void:
		var json_strings := json.split(" ")
		for i in range(1, json_strings.size()):
			var grade_string := json_strings[i].split("=")[0].to_upper()
			var cutoff_string := int(json_strings[i].split("=")[1])
			target().rank_criteria.add_threshold(grade_string, cutoff_string)
	
	
	func is_default() -> bool:
		return not target().rank_criteria.thresholds_by_grade


## Parses a json string like 'hide_combos_rank' into an enum like 'ShowRank.HIDE'
class ShowRankPropertyParser extends RuleParser.PropertyParser:
	var _hide_string: String
	
	func _init(init_target: Object, init_name: String).(init_target, init_name) -> void:
		default = []
		_hide_string = "hide%s" % [init_name.trim_prefix("show")]
		keys.append(_hide_string)
	
	
	func to_json_strings() -> Array:
		var result := []
		match target().get(name):
			ShowRank.SHOW: result.append(name)
			ShowRank.HIDE: result.append(_hide_string)
		return result
	
	
	func from_json_string(json: String) -> void:
		match json:
			name: target().set(name, ShowRank.SHOW)
			_hide_string: target().set(name, ShowRank.HIDE)
			_: push_warning("Unrecognized: %s" % [json])
	
	
	func is_default() -> bool:
		return target().get(name) == ShowRank.DEFAULT


enum ShowRank {
	DEFAULT, # rank should be automatically shown/hidden based on the finish condition
	SHOW, # rank should be shown
	HIDE, # rank should be hidden
}

var rank_criteria: RankCriteria = RankCriteria.new()

## the level's estimated duration
var duration: int

var show_boxes_rank: int = ShowRank.DEFAULT
var show_combos_rank: int = ShowRank.DEFAULT
var show_lines_rank: int = ShowRank.DEFAULT
var show_pickups_rank: int = ShowRank.DEFAULT
var show_pieces_rank: int = ShowRank.DEFAULT
var show_speed_rank: int = ShowRank.DEFAULT

## 'true' if the results screen should be skipped. Used for tutorials.
var skip_results := false

## Bonus rank given if the player achieves the level's success condition. Useful when designing levels where
## achieving a target score of 1,000 is an A grade, but failing with a score of 999 is also an A grade. This property
## gives the player a little bump in rank so achieving the target score will always result in a higher grade.
var success_bonus := 0.0

## If 'true' the player is not given a rank for this level.
var unranked := false
var legacy_rules := {}

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_int("duration")
	_rule_parser.add(LegacyCriteriaParser.new(self, "legacy"))
	_rule_parser.add(RankCriteriaParser.new(self, "rank_criteria"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_boxes_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_combos_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_lines_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_pickups_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_pieces_rank"))
	_rule_parser.add(ShowRankPropertyParser.new(self, "show_speed_rank"))
	_rule_parser.add_bool("skip_results")
	_rule_parser.add_float("success_bonus")
	_rule_parser.add_bool("unranked")


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
