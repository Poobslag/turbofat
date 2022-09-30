extends Node
## A library of phase conditions for level triggers.
##
## These conditions are each mapped to a unique string so that they can be referenced from json.

class PieceWrittenPhaseCondition extends PhaseCondition:
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
	
	## Creates a new PieceWrittenPhaseCondition instance with the specified configuration.
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
	func _init(phase_config: Dictionary).(phase_config) -> void:
		_indexes_string = phase_config.get("n", "")
		_indexes_to_run = ConfigStringUtils.ints_from_config_string(_indexes_string, MAX_PIECE_INDEX)
		
		_combos_string = phase_config.get("combo", "")
		_combos_to_run = ConfigStringUtils.ints_from_config_string(_combos_string, MAX_PIECE_INDEX)
	
	
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


class LineClearedPhaseCondition extends PhaseCondition:
	## key: (int) a line which causes the trigger to fire when cleared. 0 is the highest line in the playfield.
	## value: (bool) true
	var which_lines := {}
	
	## Creates a new LineClearedPhaseCondition instance with the specified configuration.
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
	func _init(phase_config: Dictionary).(phase_config) -> void:
		if phase_config.has("y"):
			var y_expression: String = phase_config["y"]
			var inverted_which_lines := ConfigStringUtils.ints_from_config_string(y_expression)
			for which_line in inverted_which_lines:
				which_lines[ConfigStringUtils.invert_puzzle_row_index(which_line)] = true
	
	
	## Returns 'true' if a trigger should run during this phase, based on the specified metadata.
	##
	## Parameters:
	## 	'event_params': 'y' specifies which line was cleared, 0 is the highest line in the playfield.
	func should_run(event_params: Dictionary) -> bool:
		var result := true
		if which_lines:
			result = result and which_lines.has(event_params["y"])
		return result
	
	
	## Extracts a set of phase configuration strings from this phase condition.
	##
	## Reverse-engineers a 'y' expression like {"y": "0,4-6"} based on the `which_lines` property.
	##
	## Returns:
	## 	A set of phase configuration strings defining criteria for this phase condition.
	func get_phase_config() -> Dictionary:
		var result := {}
		if which_lines:
			var inverted_which_lines := ConfigStringUtils.invert_puzzle_row_indexes(which_lines.keys())
			result["y"] = ConfigStringUtils.config_string_from_ints(inverted_which_lines)
		return result

var phase_conditions_by_string := {
	"piece_written": PieceWrittenPhaseCondition,
	"line_cleared": LineClearedPhaseCondition,
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
