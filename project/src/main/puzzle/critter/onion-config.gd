class_name OnionConfig
## Rules for onions on a specific level.

enum OnionState {
	NONE,
	DAY,
	DAY_END,
	NIGHT,
}

## String representing states the onion goes through, such as 'ddennn'.
##
## '.': 'None' state. The onion is underground.
## 'd': 'Day' state. The onion is dancing ominously.
## 'e': 'Day End' state. The onion raises their arms in warning.
## 'n': 'Night' state. The onion is in the sky, and the puzzle is cast in darkness.
var day_string: String

## key: (String) Character representing a state the onion goes through
## value: (int) enum from OnionState
var onion_state_by_day_char := {
	".": OnionState.NONE,
	"d": OnionState.DAY,
	"e": OnionState.DAY_END,
	"n": OnionState.NIGHT,
}

## Initializes onion with an optional day string describing the states the onion goes through.
##
## Parameters:
## 	'init_day_string': A string representing states the onion goes through, such as 'ddennn'.
func _init(init_day_string: String = "") -> void:
	day_string = init_day_string


## Returns the state the onion should be in after a number of advancements.
##
## The onion's states are cyclical, so the first few advancements will push them through the states defined in their
## day_string. Additional advancements will reset them to the start of their day string.
##
## Parameters:
## 	'advance_count': The number of times the onion has been advanced
##
## Returns:
## 	Enum from OnionState for the state the onion should be in
func get_state(advance_count: int) -> int:
	if day_string.is_empty():
		return OnionState.NONE
	
	return onion_state_by_day_char.get(day_string[advance_count % day_string.length()], OnionState.NONE)


## Returns the length of this onion's day/night cycle.
func cycle_length() -> int:
	return day_string.length()
