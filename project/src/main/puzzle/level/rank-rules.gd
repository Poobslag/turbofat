class_name RankRules
## Tweaks to rank calculation.

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


var rank_criteria: RankCriteria = RankCriteria.new()

## the level's estimated duration
var duration: int

## 'true' if the results screen should be skipped. Used for tutorials.
var skip_results := false

## Bonus rank given if the player achieves the level's success condition. Useful when designing levels where
## achieving a target score of 1,000 is an A grade, but failing with a score of 999 is also an A grade. This property
## gives the player a little bump in rank so achieving the target score will always result in a higher grade.
var success_bonus := 0.0

## If 'true' the player is not given a rank for this level.
var unranked := false

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_int("duration")
	_rule_parser.add(RankCriteriaParser.new(self, "rank_criteria"))
	_rule_parser.add_bool("skip_results")
	_rule_parser.add_float("success_bonus")
	_rule_parser.add_bool("unranked")


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
