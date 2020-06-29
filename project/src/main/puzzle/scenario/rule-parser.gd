class_name RuleParser
"""
Parses scenario rules.

Scenario rules involve lists of strings like 'top-out 3' or 'piece-t'.
"""

var _parsed_rules: Dictionary

# The queried key which we store to avoid repetitive 'has value foo, get value foo' code
var _prev_key: String

func _init(strings: Array) -> void:
	for string_obj in strings:
		var string: String = string_obj
		var split := string.split(" ")
		if split.size() == 1:
			_parsed_rules[split[0]] = split[0]
		elif split.size() >= 2:
			_parsed_rules[split[0]] = split[1]


func has(key: String) -> bool:
	_prev_key = key
	return _parsed_rules.has(key)


"""
Returns the int value for the key previously passed into the 'has' function.
"""
func int_value() -> int:
	return int(_parsed_rules[_prev_key])


"""
Returns the float value for the key previously passed into the 'has' function.
"""
func float_value() -> float:
	return float(_parsed_rules[_prev_key])


"""
Returns the string value for the key previously passed into the 'has' function.
"""
func string_value() -> String:
	return str(_parsed_rules[_prev_key])

