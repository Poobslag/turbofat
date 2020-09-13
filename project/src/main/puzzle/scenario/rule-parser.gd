class_name RuleParser
"""
Parses scenario rules.

Scenario rules involve lists of strings like 'top-out 3' or 'piece-t'.
"""

# Stores key/value pairs parsed from JSON.
# For keys which have no value, we store the number of times the key is repeated.
var _parsed_rules: Dictionary

# The queried key which we store to avoid repetitive 'has value foo, get value foo' code
var _prev_key: String

func _init(strings: Array) -> void:
	for string_obj in strings:
		var string: String = string_obj
		var split := string.split(" ")
		if split.size() == 1:
			if not _parsed_rules.has(split[0]):
				_parsed_rules[split[0]] = 0
			_parsed_rules[split[0]] += 1
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

