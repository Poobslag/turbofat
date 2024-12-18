extends Node
## Library of phase conditions for level triggers.
##
## These conditions are each mapped to a unique string so that they can be referenced from json.

## We precalculate which pieces/lines will trigger certain rules, up to this limit. 20,000 corresponds to an expert
## player playing at ~200 PPM for two hours.
const MAX_PIECE_INDEX := 20000
const MAX_LINE_INDEX := 10000

class PickupCollectedPhaseCondition extends PhaseCondition:
	
	enum RequiredPickupType {
		ANY,
		SNACK,
		CAKE,
	}
	
	## enum from RequiredPickupType defining the pickup's required type
	var required_pickup_type: int = RequiredPickupType.ANY
	
	## Creates a new PickupCollectedPhaseCondition instance with the specified configuration.
	func _init(phase_config: Dictionary).(phase_config) -> void:
		if phase_config.has("0"):
			required_pickup_type = Utils.enum_from_snake_case(RequiredPickupType, phase_config["0"])
	
	
	## Returns 'true' if a trigger should run during this phase, based on the specified metadata.
	##
	## Parameters:
	## 	'event_params': 'type' is an enum from Foods.PickupType defining the pickup's color
	func should_run(event_params: Dictionary) -> bool:
		var actual_pickup_type: int = event_params["type"]
		var should_run := false
		match required_pickup_type:
			RequiredPickupType.ANY:
				should_run = true
			RequiredPickupType.SNACK:
				should_run = Foods.is_snack_food(actual_pickup_type)
			RequiredPickupType.CAKE:
				should_run = Foods.is_cake_food(actual_pickup_type)
		return should_run
	
	
	## Extracts a set of phase configuration strings from this phase condition.
	func get_phase_config() -> Dictionary:
		var result := {}
		if required_pickup_type != RequiredPickupType.ANY:
			result["0"] = Utils.enum_to_snake_case(RequiredPickupType, required_pickup_type)
		return result


class ComboEndedPhaseCondition extends PhaseCondition:
	## key: (int) combo value which triggers this phase condition, '0' means no combo
	## value: (bool) true
	var combos_to_run := {}
	
	## Creates a new ComboEndedPhaseCondition instance with the specified configuration.
	##
	## The phase_config parameter accepts an optional 'combo' expression defining which combo values will fire this
	## trigger. 1 means the smallest possible combo (clearing one line)
	##
	## 	{"combo": "10..."}: The trigger will fire if the player breaks their combo after clearing ten lines in a single
	## 		combo.
	##
	## Parameters:
	## 	'phase_config.combo': (Optional) Expression defining which combo values will fire this trigger.
	func _init(phase_config: Dictionary).(phase_config) -> void:
		var combos_string: String = phase_config.get("combo", "")
		combos_to_run = ConfigStringUtils.ints_from_config_string(combos_string, MAX_PIECE_INDEX)
	
	
	## Returns 'true' if a trigger should run during this phase, based on the specified metadata.
	##
	## Parameters:
	## 	'_event_params': (Optional) Phase-specific metadata used to decide whether the trigger should fire
	func should_run(_event_params: Dictionary) -> bool:
		var result := true
		if combos_to_run:
			result = result and (_event_params["combo"] in combos_to_run)
		return result
	
	
	## Extracts a set of phase configuration strings from this phase condition.
	##
	## Returns:
	## 	A set of phase configuration strings defining criteria for this phase condition.
	func get_phase_config() -> Dictionary:
		var result := {}
		if combos_to_run:
			result["combo"] = ConfigStringUtils.config_string_from_ints(combos_to_run.keys(), MAX_PIECE_INDEX)
		return result


class PieceWrittenPhaseCondition extends PhaseCondition:
	## key: (int) piece index which triggers this phase condition, '1' is the first piece
	## value: (bool) true
	var indexes_to_run := {}
	
	## key: (int) combo value which triggers this phase condition, '0' means no combo
	## value: (bool) true
	var combos_to_run := {}
	
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
	## 	{"n": "1,2,3,4,5"}: The trigger will fire for the first five pieces.
	##
	## 	{"n": "10,11,12..."}: The trigger will fire for every piece past the tenth piece.
	##
	## Parameters:
	## 	'phase_config.n': (Optional) Expression defining which pieces will fire this trigger.
	##
	## 	'phase_config.combo': (Optional) Expression defining which combo values will fire this trigger.
	func _init(phase_config: Dictionary).(phase_config) -> void:
		var indexes_string: String = phase_config.get("n", "")
		indexes_to_run = ConfigStringUtils.ints_from_config_string(indexes_string, MAX_PIECE_INDEX)
		
		var combos_string: String = phase_config.get("combo", "")
		combos_to_run = ConfigStringUtils.ints_from_config_string(combos_string, MAX_PIECE_INDEX)
	
	
	## Returns 'true' if a trigger should run during this phase, based on the specified metadata.
	##
	## Parameters:
	## 	'_event_params': (Optional) Phase-specific metadata used to decide whether the trigger should fire
	func should_run(_event_params: Dictionary) -> bool:
		var result := true
		if indexes_to_run:
			result = result and (PuzzleState.level_performance.pieces in indexes_to_run)
		if combos_to_run:
			result = result and (PuzzleState.combo in combos_to_run)
		return result
	
	
	## Extracts a set of phase configuration strings from this phase condition.
	##
	## Returns:
	## 	A set of phase configuration strings defining criteria for this phase condition.
	func get_phase_config() -> Dictionary:
		var result := {}
		if indexes_to_run:
			result["n"] = ConfigStringUtils.config_string_from_ints(indexes_to_run.keys(), MAX_PIECE_INDEX)
		if combos_to_run:
			result["combo"] = ConfigStringUtils.config_string_from_ints(combos_to_run.keys(), MAX_PIECE_INDEX)
		return result


class BoxBuiltPhaseCondition extends PhaseCondition:
	
	## Different box variety conditions. Levels can specify a unique box type like 'PINK', but more commonly specify
	## generic varieties like 'ANY' or 'CAKE'.
	enum RequiredBoxType {
		ANY,
		SNACK,
		CAKE,
		BROWN,
		PINK,
		BREAD,
		WHITE,
		CHEESE,
		CAKE_JJO,
		CAKE_JLO,
		CAKE_JTT,
		CAKE_LLO,
		CAKE_LTT,
		CAKE_PQV,
		CAKE_PUV,
		CAKE_QUV,
		CAKE_CJU,
		CAKE_CLU,
		CAKE_CTU,
	}
	
	## Maps enum keys one-to-one from 'RequiredBoxType' to 'Foods.BoxType'.
	##
	## Note: This dictionary does not have entries for one-to-many keys like RequiredBoxType.ANY or
	## RequiredBoxType.CAKE.
	##
	## key: (int) Enum from RequiredBoxType
	## value: (int) Enum from Foods.BoxType
	const BOX_TYPE_BY_REQUIRED_BOX_TYPE := {
		RequiredBoxType.BROWN: Foods.BoxType.BROWN,
		RequiredBoxType.PINK: Foods.BoxType.PINK,
		RequiredBoxType.BREAD: Foods.BoxType.BREAD,
		RequiredBoxType.WHITE: Foods.BoxType.WHITE,
		RequiredBoxType.CHEESE: Foods.BoxType.CHEESE,
		RequiredBoxType.CAKE_JJO: Foods.BoxType.CAKE_JJO,
		RequiredBoxType.CAKE_JLO: Foods.BoxType.CAKE_JLO,
		RequiredBoxType.CAKE_JTT: Foods.BoxType.CAKE_JTT,
		RequiredBoxType.CAKE_LLO: Foods.BoxType.CAKE_LLO,
		RequiredBoxType.CAKE_LTT: Foods.BoxType.CAKE_LTT,
		RequiredBoxType.CAKE_PQV: Foods.BoxType.CAKE_PQV,
		RequiredBoxType.CAKE_PUV: Foods.BoxType.CAKE_PUV,
		RequiredBoxType.CAKE_QUV: Foods.BoxType.CAKE_QUV,
		RequiredBoxType.CAKE_CJU: Foods.BoxType.CAKE_CJU,
		RequiredBoxType.CAKE_CLU: Foods.BoxType.CAKE_CLU,
		RequiredBoxType.CAKE_CTU: Foods.BoxType.CAKE_CTU,
	}
	
	## enum from RequiredBoxType defining the box's required type
	var required_box_type: int = RequiredBoxType.ANY
	
	## Creates a new BoxBuiltPhaseCondition instance with the specified configuration.
	func _init(phase_config: Dictionary).(phase_config) -> void:
		if phase_config.has("0"):
			required_box_type = Utils.enum_from_snake_case(RequiredBoxType, phase_config["0"])
	
	
	## Returns 'true' if a trigger should run during this phase, based on the specified metadata.
	##
	## Parameters:
	## 	'event_params': 'type' is an enum from Foods.BoxType defining the box's color
	func should_run(event_params: Dictionary) -> bool:
		var actual_box_type: int = event_params["type"]
		var should_run := false
		match required_box_type:
			RequiredBoxType.ANY:
				should_run = true
			RequiredBoxType.SNACK:
				should_run = Foods.is_snack_box(actual_box_type)
			RequiredBoxType.CAKE:
				should_run = Foods.is_cake_box(actual_box_type)
			RequiredBoxType.BROWN, \
			RequiredBoxType.PINK, \
			RequiredBoxType.BREAD, \
			RequiredBoxType.WHITE, \
			RequiredBoxType.CHEESE, \
			RequiredBoxType.CAKE_JJO, \
			RequiredBoxType.CAKE_JLO, \
			RequiredBoxType.CAKE_JTT, \
			RequiredBoxType.CAKE_LLO, \
			RequiredBoxType.CAKE_LTT, \
			RequiredBoxType.CAKE_PQV, \
			RequiredBoxType.CAKE_PUV, \
			RequiredBoxType.CAKE_QUV, \
			RequiredBoxType.CAKE_CJU, \
			RequiredBoxType.CAKE_CLU, \
			RequiredBoxType.CAKE_CTU:
				should_run = actual_box_type == BOX_TYPE_BY_REQUIRED_BOX_TYPE[required_box_type]
		return should_run
	
	
	## Extracts a set of phase configuration strings from this phase condition.
	func get_phase_config() -> Dictionary:
		var result := {}
		if required_box_type != RequiredBoxType.ANY:
			result["0"] = Utils.enum_to_snake_case(RequiredBoxType, required_box_type)
		return result


class LineClearedPhaseCondition extends PhaseCondition:
	## key: (int) line which causes the trigger to fire when cleared. 0 is the highest line in the playfield.
	## value: (bool) true
	var rows := {}
	
	## key: (int) line milestone which causes the trigger to fire when cleared.
	## value: (bool) true
	var indexes_to_run := {}
	
	## key: (int) combo value which triggers this phase condition, '0' means no combo
	## value: (bool) true
	var combos_to_run := {}
	
	## key: (int) score values which trigger this phase condition when exceeded
	## value: (bool) true
	var scores_to_run := {}
	
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
	## 	'phase_config.y': (Optional) Expression defining which rows will fire this trigger.
	## 	'phase_config.n': (Optional) Expression defining how many line clears will fire this trigger.
	## 	'phase_config.combo': (Optional) Expression defining how many combos will fire this trigger.
	## 	'phase_config.score': (Optional) Expression defining which score milestones will fire this trigger.
	func _init(phase_config: Dictionary).(phase_config) -> void:
		var y_expression: String = phase_config.get("y", "")
		var inverted_rows := ConfigStringUtils.ints_from_config_string(y_expression)
		for row in inverted_rows:
			rows[ConfigStringUtils.invert_puzzle_row_index(row)] = true
		
		var indexes_string: String = phase_config.get("n", "")
		indexes_to_run = ConfigStringUtils.ints_from_config_string(indexes_string, MAX_LINE_INDEX)
		
		var combos_string: String = phase_config.get("combo", "")
		combos_to_run = ConfigStringUtils.ints_from_config_string(combos_string, MAX_LINE_INDEX)
		
		var scores_string: String = phase_config.get("score", "")
		scores_to_run = ConfigStringUtils.ints_from_config_string(scores_string, MAX_LINE_INDEX)
	
	
	## Returns 'true' if a trigger should run during this phase, based on the specified metadata.
	##
	## Parameters:
	## 	'event_params': Defines criteria for this line clear.
	##	 	'event_params.y': specifies which line was cleared, 0 is the highest line in the playfield.
	##	 	'event_params.n': specifies how many total lines have been cleared, 1 for the first line cleared.
	## 		'event_params.combo': specifies the combo after clearing this line, 1 for the first line in a combo.
	## 		'event_params.prev_score': specifies the max score reached before clearing this line.
	## 		'event_params.score': specifies the max score reached after clearing this line.
	func should_run(event_params: Dictionary) -> bool:
		var result := true
		if rows:
			result = result and rows.has(event_params["y"])
		if indexes_to_run:
			result = result and indexes_to_run.has(event_params["n"])
		if combos_to_run:
			result = result and combos_to_run.has(event_params["combo"])
		if scores_to_run:
			var score_reached := false
			for score in range(event_params["prev_score"] + 1, event_params["score"] + 1):
				if scores_to_run.has(score):
					score_reached = true
					break
			result = result and score_reached
		return result
	
	
	## Extracts a set of phase configuration strings from this phase condition.
	##
	## Reverse-engineers a 'y' expression like {"y": "0,4-6"} based on the `rows` property.
	##
	## Returns:
	## 	A set of phase configuration strings defining criteria for this phase condition.
	func get_phase_config() -> Dictionary:
		var result := {}
		if rows:
			var inverted_rows := ConfigStringUtils.invert_puzzle_row_indexes(rows.keys())
			result["y"] = ConfigStringUtils.config_string_from_ints(inverted_rows)
		if indexes_to_run:
			result["n"] = ConfigStringUtils.config_string_from_ints(indexes_to_run.keys(), MAX_LINE_INDEX)
		if combos_to_run:
			result["combo"] = ConfigStringUtils.config_string_from_ints(combos_to_run.keys(), MAX_LINE_INDEX)
		if scores_to_run:
			result["score"] = ConfigStringUtils.config_string_from_ints(scores_to_run.keys(), MAX_LINE_INDEX)
		return result


var phase_conditions_by_string := {
	"box_built": BoxBuiltPhaseCondition,
	"combo_ended": ComboEndedPhaseCondition,
	"line_cleared": LineClearedPhaseCondition,
	"pickup_collected": PickupCollectedPhaseCondition,
	"piece_written": PieceWrittenPhaseCondition,
}


## Creates a new PhaseCondition instance.
##
## Parameters:
## 	'phase_key': A string key corresponding to the phase, such as 'line_cleared'.
##
## 	'phase_config': (Optional) Dictionary of strings defining any special conditions for the phase.
func create(phase_key: String, phase_config: Dictionary) -> PhaseCondition:
	var phase_condition_type: GDScript = phase_conditions_by_string.get(phase_key, PhaseCondition)
	var phase_condition: PhaseCondition = phase_condition_type.new(phase_config)
	return phase_condition
