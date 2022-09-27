extends Node
## A library of phase conditions for level triggers.
##
## These conditions are each mapped to a unique string so that they can be referenced from json.

class AfterPieceWrittenPhaseCondition extends PhaseCondition:
	## We precalculate which pieces will trigger the rule, up to this number of pieces.
	## 20,000 corresponds to an expert player playing at ~200 PPM for two hours.
	const MAX_PIECE_INDEX := 20000
	
	## The 'n' string read from the json configuration file.
	var _indexes_string: String
	
	## The 'combo' string read from the json configuration file.
	var _combos_string: String
	
	## key: (int) piece index which triggers this phase condition, '0' is the first piece
	## value: (bool) true
	var _indexes_to_run := {}
	
	## key: (int) combo value which triggers this phase condition, '0' means no combo
	## value: (bool) true
	var _combos_to_run := {}
	
	## Creates a new AfterPieceWrittenPhaseCondition instance with the specified configuration.
	##
	## The phase_config parameter accepts an optional 'n' expression defining which pieces will fire this trigger.
	## 0 is the first piece placed.
	##
	## The phase_config parameter accepts an optional 'combo' expression defining which combo values will fire this
	## trigger. 0 means 'no combo'.
	##
	## 	{"combo": "0"}: The trigger will fire for every piece if no combo is active.
	##
	## 	{"n": "0,1,2,3,4"}: The trigger will fire for the first five pieces.
	##
	## 	{"n": "10,11,12..."}: The trigger will fire for every piece past the tenth piece.
	##
	## Parameters:
	## 	'phase_config.n': (Optional) An expression defining which pieces will fire this trigger.
	##
	## 	'phase_config.combo': (Optional) An expression defining which combo values will fire this trigger.
	func _init(_phase_config: Dictionary).(_phase_config) -> void:
		_indexes_string = _phase_config.get("n", "")
		_indexes_to_run = _parse_int_series(_indexes_string, MAX_PIECE_INDEX)
		
		_combos_string = _phase_config.get("combo", "")
		_combos_to_run = _parse_int_series(_combos_string, MAX_PIECE_INDEX)
	
	
	## Returns 'true' if a trigger should run during this phase, based on the specified metadata.
	##
	## Parameters:
	## 	'_event_params': (Optional) Phase-specific metadata used to decide whether the trigger should fire
	func should_run(_event_params: Dictionary) -> bool:
		var result := true
		if _indexes_string:
			result = result and (PuzzleState.level_performance.pieces - 1 in _indexes_to_run)
		if _combos_string:
			result = result and (PuzzleState.combo in _combos_to_run)
		return result
	
	
	## Extracts a set of phase configuration strings from this phase condition.
	##
	## Returns:
	## 	A set of phase configuration strings defining criteria for this phase condition.
	func get_phase_config() -> Dictionary:
		var result := {}
		if _indexes_string: result["n"] = _indexes_string
		return result
	
	
	## Parse an int series string such as '3,4,5...'
	##
	## Parses a string expression and returns a dictionary containing all ints which meet that condition. Commas and
	## ellipses are supported.
	##
	## 	{"n": "0,1,2,3,4"}: The numbers 0, 1, 2, 3 and 4 meet the condition.
	##
	## 	{"n": "1,3,5..."}: All positive odd numbers meet the condition.
	##
	## 	{"n": "10,11,12..."}: All numbers greater than or equal to 10 meet the condition.
	##
	## Parameters:
	## 	'int_series_string': A string expression describing ints which meet a condition.
	##
	## 	'max_int': The maximum value which should be checked for meeting the condition.
	##
	## Returns:
	## 	A dictionary of int values meeting the specified condition. The values are set to 'true'.
	func _parse_int_series(int_series_string: String, max_int: int) -> Dictionary:
		var result := {}
		
		# append all raw values
		var ints_split := int_series_string.trim_suffix("...").split(",")
		for index_obj in ints_split:
			result[int(index_obj)] = true
		
		# This unusual for loop checks for ellipses, and allows us to 'break' for errors to avoid 'return' statements
		# in the middle of a method
		for _i in range(1 if int_series_string.ends_with("...") else 0):
			# determine difference of last two values
			if ints_split.size() < 2:
				push_warning("index string doesn't have enough values to extrapolate: '%s'" % [int_series_string])
				break
			
			var low := int(ints_split[ints_split.size() - 2])
			var high := int(ints_split[ints_split.size() - 1])
			if high <= low:
				push_warning("nonsensical index string extrapolation: '%s'" % [int_series_string])
				break
			
			var i := 2 * high - low
			# extrapolate until we hit max_int
			while i < max_int:
				result[i] = true
				i += high - low
		
		return result


class AfterLineClearedPhaseCondition extends PhaseCondition:
	## key: (int) a line which causes the trigger to fire when cleared. 0 is the highest line in the playfield.
	## value: (bool) true
	var which_lines := {}
	
	## Creates a new AfterLineClearedPhaseCondition instance with the specified configuration.
	##
	## The phase_config parameter accepts an optional 'y' expression defining which line clears will fire this trigger.
	## Commas and hyphens are accepted, 0 is the lowest line in the playfield.
	##
	## 	{"y": "2"}: The trigger will fire if the third row from the bottom is cleared.
	##
	## 	{"y": "1,3,5"}: The trigger will fire if the second, fourth, or sixth row from the bottom is cleared.
	##
	## 	{"y": "0-3"}: The trigger will fire if any of the bottom for rows from the bottom are cleared.
	##
	## 	{"y": "0,4-6"}: The trigger will fire if the bottom row, or the fifth through seventh rows from the bottom are
	## 		cleared.
	##
	## Parameters:
	## 	'phase_config.y': (Optional) An expression defining which line clears will fire this trigger.
	func _init(_phase_config: Dictionary).(_phase_config) -> void:
		var y_expression: String = _phase_config.get("y")
		if y_expression:
			var which_lines_array := ConfigStringUtils.ints_from_config_string(y_expression)
			which_lines_array = ConfigStringUtils.invert_puzzle_row_indexes(which_lines_array)
			for which_line in which_lines_array:
				which_lines[which_line] = true
	
	
	## Returns 'true' if a trigger should run during this phase, based on the specified metadata.
	##
	## Parameters:
	## 	'event_params': 'y' specifies which line was cleared, 0 is the highest line in the playfield.
	func should_run(event_params: Dictionary) -> bool:
		return which_lines.has(event_params["y"])
	
	
	## Extracts a set of phase configuration strings from this phase condition.
	##
	## Reverse-engineers a 'y' expression like {"y": "0,4-6"} based on the `which_lines` property.
	##
	## Returns:
	## 	A set of phase configuration strings defining criteria for this phase condition.
	func get_phase_config() -> Dictionary:
		var inverted_which_lines := ConfigStringUtils.invert_puzzle_row_indexes(which_lines.keys())
		var y_expression: String = ConfigStringUtils.config_string_from_ints(inverted_which_lines)
		return {"y": y_expression}

var phase_conditions_by_string := {
	"after_line_cleared": AfterLineClearedPhaseCondition,
	"after_piece_written": AfterPieceWrittenPhaseCondition,
}

## Creates a new PhaseCondition instance.
##
## Parameters:
## 	'phase_key': A string key corresponding to the phase, such as 'after_line_cleared'.
##
## 	'phase_config': (Optional) A dictionary of strings defining any special conditions for the phase.
func create(phase_key: String, phase_config: Dictionary) -> PhaseCondition:
	var phase_condition_type: GDScript = phase_conditions_by_string.get(phase_key, PhaseCondition)
	var phase_condition: PhaseCondition = phase_condition_type.new(phase_config)
	return phase_condition
