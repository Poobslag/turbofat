extends Node
"""
A library of phase conditions for level triggers.

These conditions are each mapped to a unique string so that they can be referenced from json.
"""

class AfterLinesClearedPhaseCondition extends PhaseCondition:
	# key: (int) a line which causes the trigger to fire when cleared. 0 is the highest line in the playfield.
	# value: true
	var which_lines := {}
	
	"""
	Creates a new AfterLinesClearedPhaseCondition instance with the specified configuration.
	
	The phase_config parameter accepts an optional 'y' expression defining which line clears will fire this trigger.
	Commas and hyphens are accepted, 0 is the lowest line in the playfield.
	
		{"y": "2"}: The trigger will fire if the third row from the bottom is cleared.
		
		{"y": "1,3,5"}: The trigger will fire if the second, fourth, or sixth row from the bottom is cleared.
		
		{"y": "0-3"}: The trigger will fire if any of the bottom for rows from the bottom are cleared.
		
		{"y": "0,4-6"}: The trigger will fire if the bottom row, or the fifth through seventh rows from the bottom are
			cleared.
	
	Parameters:
		'phase_config.y': (Optional) An expression defining which line clears will fire this trigger.
	"""
	func _init(_phase_config: Dictionary).(_phase_config) -> void:
		var y_expression: String = _phase_config.get("y")
		var lo := 0
		var hi := PuzzleTileMap.ROW_COUNT
		if y_expression:
			for sub_expression in y_expression.split(","):
				if "-" in sub_expression:
					lo = int(StringUtils.substring_before(sub_expression, "-"))
					hi = int(StringUtils.substring_after(sub_expression, "-")) + 1
				else:
					lo = int(sub_expression)
					hi = int(sub_expression) + 1
				for y in range(lo, hi):
					which_lines[PuzzleTileMap.ROW_COUNT - y - 1] = true
	
	
	"""
	Returns 'true' if a trigger should run during this phase, based on the specified metadata.

	Parameters:
		'event_params': 'y' specifies which line was cleared, 0 is the highest line in the playfield.
	"""
	func should_run(event_params: Dictionary) -> bool:
		return which_lines.has(event_params["y"])
	
	
	"""
	Extracts a set of phase configuration strings from this phase condition.
	
	Reverse-engineers a 'y' expression like {"y": "0,4-6"} based on the `which_lines` property.
	
	Returns:
		A set of phase configuration strings defining criteria for this phase condition.
	"""
	func get_phase_config() -> Dictionary:
		var y_expression: String = ""
		
		var range_start := -1
		for y in range(PuzzleTileMap.ROW_COUNT + 1):
			var include_prev := which_lines.has(PuzzleTileMap.ROW_COUNT - y)
			var include_curr := which_lines.has(PuzzleTileMap.ROW_COUNT - y - 1)
			if include_curr and not include_prev:
				# start a new range
				range_start = y
			if not include_curr and include_prev:
				# end the range and append it to the y_expression
				var range_end := y - 1
				if y_expression:
					y_expression += ","
				if range_start == range_end:
					# isolated lines are output as "1,3,5"
					y_expression += str(range_start)
				else:
					# adjacent lines are hyphenated as "1-3,5-9"
					y_expression += "%s-%s" % [range_start, range_end]
		
		return {"y": y_expression}

var phase_conditions_by_string := {
	"after_line_cleared": AfterLinesClearedPhaseCondition,
}

"""
Creates a new PhaseCondition instance.

Parameters:
	'phase_key': A string key corresponding to the phase, such as 'after_line_cleared'.
	
	'phase_config': (Optional) A dictionary of strings defining any special conditions for the phase.
"""
func create(phase_key: String, phase_config: Dictionary) -> PhaseCondition:
	var phase_condition_type: GDScript = phase_conditions_by_string.get(phase_key, PhaseCondition)
	var phase_condition: PhaseCondition = phase_condition_type.new(phase_config)
	return phase_condition
