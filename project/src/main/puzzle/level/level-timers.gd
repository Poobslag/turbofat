class_name LevelTimers
"""
Timers which cause strange things to happen during a level.

A level can contain several timers, and each timer can activate a trigger to cause different unique effects.
"""

# array of dictionary timer definitions
var timers := []

"""
Returns how frequently the timer should fire, measured in seconds.
"""
func get_timer_interval(timer_index: int) -> float:
	return timers[timer_index].get("interval")


"""
Returns the number of timers used by this level.

For most levels, this will be zero.
"""
func get_timer_count() -> int:
	return timers.size()


func from_json_array(timers_json: Array) -> void:
	timers = timers_json


func to_json_array() -> Array:
	return timers


func is_default() -> bool:
	return timers.empty()
