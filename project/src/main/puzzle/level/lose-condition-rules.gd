class_name LoseConditionRules
## How the player loses. The player usually loses if they top out a certain number of times, but some levels might
## have different rules.

## if 'true', the finish screen is shown when the player loses
var finish_on_lose := false

## by default, the player loses if they top out three times
var top_out := 3

var _rule_parser: RuleParser

func _init() -> void:
	_rule_parser = RuleParser.new(self)
	_rule_parser.add_bool("finish_on_lose")
	_rule_parser.add_int("top_out").default(3)


func from_json_array(json: Array) -> void:
	_rule_parser.from_json_array(json)


func to_json_array() -> Array:
	return _rule_parser.to_json_array()


func is_default() -> bool:
	return _rule_parser.is_default()
