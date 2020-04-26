extends Node
"""
Contains global utilities, as well as variables for preserving state when loading different scenes.
"""

const NUM_SCANCODES: Dictionary = {
	KEY_0: 0, KEY_1: 1, KEY_2: 2, KEY_3: 3, KEY_4: 4,
	KEY_5: 5, KEY_6: 6, KEY_7: 7, KEY_8: 8, KEY_9: 9
}

# String to display if the player scored worse than the lowest grade
const NO_GRADE := "-"

# Target number of customer greetings (hello, goodbye) per minute
const GREETINGS_PER_MINUTE := 3.0

# The scenario currently being launched or played
var scenario_settings := ScenarioSettings.new()

# The player's performance on the current scenario
var scenario_performance := ScenarioPerformance.new()

# Stores all of the benchmarks which have been started
var _benchmark_start_times := Dictionary()

# A number in the range [-1, 1] which corresponds to how many greetings we've given recently. If it's close to 1,
# we're very unlikely to receive a greeting. If it's close to -1, we're very likely to receive a greeting.
var _greetiness := 0.0

func _process(delta: float) -> void:
	_greetiness = clamp(_greetiness + delta * GREETINGS_PER_MINUTE / 60, -1.0, 1.0)


"""
Converts a numeric grade such as '12.6' into a grade string such as 'A+'.
"""
func grade(rank: float) -> String:
	var grade := NO_GRADE
	if   rank <= 0:  grade = "M"
	
	elif rank <= 2:  grade = "S++"
	elif rank <= 3:  grade = "S+"
	elif rank <= 9:  grade = "S"
	elif rank <= 10: grade = "S-"
	
	elif rank <= 13: grade = "A+"
	elif rank <= 22: grade = "A"
	elif rank <= 23: grade = "A-"
	
	elif rank <= 26: grade = "B+"
	elif rank <= 33: grade = "B"
	elif rank <= 34: grade = "B-"
	
	elif rank <= 37: grade = "C+"
	elif rank <= 44: grade = "C"
	elif rank <= 45: grade = "C-"
	
	elif rank <= 48: grade = "D+"
	elif rank <= 58: grade = "D"
	elif rank <= 64: grade = "D-"
	return grade


"""
Sets the start time for a benchmark. Calling 'benchmark_start(foo)' and 'benchmark_finish(foo)' will display a message
like 'foo took 123 milliseconds'.
"""
func benchmark_start(key: String = "") -> void:
	_benchmark_start_times[key] = OS.get_ticks_usec()


"""
Prints the amount of time which has passed since a benchmark was started. Calling 'benchmark_start(foo)' and
'benchmark_finish(foo)' will display a message like 'foo took 123 milliseconds'.
"""
func benchmark_end(key: String = "") -> void:
	if not _benchmark_start_times.has(key):
		print("Invalid benchmark: %s" % key)
		return
	print("benchmark %s: %.3f msec" % [key, (OS.get_ticks_usec() - _benchmark_start_times[key]) / 1000.0])


"""
Returns 'true' if the customer should greet us. We calculate this based on how many times we've been greeted recently.

Novice players or fast players won't mind receiving a lot of sounds related to combos because those sounds are
associated with positive reinforcement (big combos), but they could get annoyed if customers say hello/goodbye too
frequently because those sounds are associated with negative reinforcement (broken combos).
"""
func should_chat() -> bool:
	var should_chat := true
	if _greetiness + randf() > 1.0:
		_greetiness -= 1.0 / GREETINGS_PER_MINUTE
	else:
		should_chat = false
	return should_chat


"""
Returns the scancode for a keypress event, or -1 if the event is not a keypress event.
"""
func key_scancode(event: InputEvent) -> int:
	var scancode := -1
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		scancode = event.scancode
	return scancode


"""
Returns [0-9] for a number key event, or -1 if the event is not a number key event.
"""
func key_num(event: InputEvent) -> int:
	return NUM_SCANCODES.get(key_scancode(event), -1)
