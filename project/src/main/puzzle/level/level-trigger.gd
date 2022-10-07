class_name LevelTrigger
## A trigger which causes strange things to happen during a level.
##
## A level can contain any number of triggers, and each trigger makes something happen at a specific time. For example,
## a trigger might rotate the pieces in the piece queue every 2 seconds, or a trigger might toggle the playfield
## invisible every time the player places a piece.

## phases when a level trigger can fire
enum LevelTriggerPhase {
	AFTER_PIECE_WRITTEN, # after the piece is written, and all boxes are made, and all lines are cleared
	BOX_BUILT, # when a snack/cake box is built
	INITIAL_ROTATED_CW, # when the piece is rotated clockwise using initial DAS
	INITIAL_ROTATED_CCW, # when the piece is rotated counterclockwise using initial DAS
	INITIAL_ROTATED_180, # when the piece is flipped using initial DAS
	LINE_CLEARED, # after the line is erased for a line clear, but before the lines above are shifted
	PIECE_WRITTEN, # when the piece is written, but before any boxes are made or lines are cleared
	ROTATED_CW, # when the piece is rotated clockwise
	ROTATED_CCW, # when the piece is rotated counterclockwise
	ROTATED_180, # when the piece is flipped
	TIMER_0, # when timer 0 times out
	TIMER_1, # when timer 1 times out
	TIMER_2, # when timer 2 times out
}

const AFTER_PIECE_WRITTEN := LevelTriggerPhase.AFTER_PIECE_WRITTEN
const BOX_BUILT := LevelTriggerPhase.BOX_BUILT
const INITIAL_ROTATED_CW := LevelTriggerPhase.INITIAL_ROTATED_CW
const INITIAL_ROTATED_CCW := LevelTriggerPhase.INITIAL_ROTATED_CCW
const INITIAL_ROTATED_180 := LevelTriggerPhase.INITIAL_ROTATED_180
const LINE_CLEARED := LevelTriggerPhase.LINE_CLEARED
const PIECE_WRITTEN := LevelTriggerPhase.PIECE_WRITTEN
const ROTATED_CW := LevelTriggerPhase.ROTATED_CW
const ROTATED_CCW := LevelTriggerPhase.ROTATED_CCW
const ROTATED_180 := LevelTriggerPhase.ROTATED_180
const TIMER_0 := LevelTriggerPhase.TIMER_0
const TIMER_1 := LevelTriggerPhase.TIMER_1
const TIMER_2 := LevelTriggerPhase.TIMER_2

## key: (int) an enum from LevelTriggerPhase
## value: (Array, PhaseCondition) Conditions for whether the trigger should fire
var phases := {}

## the effect caused by this level trigger
var effect: LevelTriggerEffect

## Returns 'true' if this trigger should run during the specified phase.
##
## Parameters:
## 	'phase': An enum from LevelTriggerPhase
##
## 	'event_params': (Optional) Phase-specific metadata used to decide whether the trigger should fire
func should_run(phase: int, event_params: Dictionary = {}) -> bool:
	var result := true
	var phase_conditions: Array = phases.get(phase, [])
	if not phase_conditions:
		result = false
	else:
		for phase_condition_obj in phase_conditions:
			var phase_condition: PhaseCondition = phase_condition_obj
			if not phase_condition.should_run(event_params):
				result = false
				break
	return result


## Executes this level trigger's effect.
func run() -> void:
	effect.run()


func from_json_dict(json: Dictionary) -> void:
	# parse the phases from json
	for phase_expression in json.get("phases", []):
		var phase_expression_split: Array = phase_expression.split(" ")
		var phase_key: String = phase_expression_split[0]
		var phase_config: Dictionary = dict_config_from_array(phase_expression_split.slice(1, phase_expression_split.size()))
		_add_phase(phase_key, phase_config)
	
	# parse the effect from json
	var effect_split: Array = json.get("effect").split(" ")
	var effect_key: String = effect_split[0]
	var effect_config: Dictionary = dict_config_from_array(effect_split.slice(1, effect_split.size()))
	effect = LevelTriggerEffects.create(effect_key, effect_config)
	
	# handle special cases
	if phases.has("piece_written"):
		# 'piece_written' triggers should typically happen after the piece is written, except for clearing filled lines
		if effect_key in ["clear_filled_lines"]:
			pass
		else:
			phases["after_piece_written"] = phases["piece_written"]
			phases.erase("piece_written")


func to_json_dict() -> Dictionary:
	var result := {
		"phases": []
	}
	
	# serialize the phases as json
	for phase in phases:
		for phase_condition in phases[phase]:
			var phase_key := Utils.enum_to_snake_case(LevelTriggerPhase, phase)
			var phase_config_dict: Dictionary = phase_condition.get_phase_config()
			var phase_string: String
			if phase_config_dict:
				var phase_config_array := dict_config_to_array(phase_config_dict)
				var phase_config_string := PoolStringArray(phase_config_array).join(" ")
				phase_string = "%s %s" % [phase_key, phase_config_string]
			else:
				phase_string = phase_key
			result["phases"].append(phase_string)
	
	# serialize the effect as json
	var dict_config := effect.get_config()
	var effect_key: String = LevelTriggerEffects.effect_key(effect)
	if dict_config:
		var string_config := PoolStringArray(dict_config_to_array(dict_config)).join(" ")
		result["effect"] = "%s %s" % [effect_key, string_config]
	else:
		result["effect"] = effect_key
	
	return result


## Enables this trigger for the specified phase.
##
## Parameters:
## 	'phase_key': A string key corresponding to the phase, such as 'line_cleared'.
##
## 	'phase_config': A dictionary of strings defining any special conditions for the phase.
func _add_phase(phase_key: String, phase_config: Dictionary) -> void:
	if not LevelTriggerPhase.has(phase_key.to_upper()):
		push_warning("Unrecognized phase: %s" % [phase_key])
	var phase_condition: PhaseCondition = PhaseConditions.create(phase_key, phase_config)
	var phase: int = Utils.enum_from_snake_case(LevelTriggerPhase, phase_key)
	if not phases.has(phase):
		phases[phase] = []
	phases[phase].append(phase_condition)


## Parses an array of configuration strings into a set of key/value pairs.
##
## Keyed values like "foo=bar" are added to the resulting dictionary as {"foo": "bar"}
##
## Unkeyed values like "foo" and "bar" are added to the dictionary as {"0": "foo", "1": "bar"}
##
## Parameters:
## 	'param_array': An array of configuration strings.
##
## Returns:
## 	A dictionary of configuration strings organized as key/value pairs.
static func dict_config_from_array(param_array: Array) -> Dictionary:
	var result := {}
	var param_index := 0
	for param in param_array:
		if "=" in param:
			# add a keyed entry like {"foo": "bar"}
			result[StringUtils.substring_before(param, "=")] = StringUtils.substring_after(param, "=")
		else:
			# add an unkeyed entry like {"0": "foo"}
			result[str(param_index)] = param
			param_index += 1
	return result


## Converts a set of key/value pairs into an array of configuration strings.
##
## Keyed entries like {"foo": "bar"} are added to the resulting array as ["foo=bar"]
##
## Unkeyed entries like {"0": "foo", "1": "bar"} are added to the array as ["foo", "bar"]
##
## Parameters:
## 	'param_array': A dictionary of configuration strings organized as key/value pairs.
##
## Returns:
## 	An array of configuration strings.
static func dict_config_to_array(dict_config: Dictionary) -> Array:
	var result := []
	var remaining_config := dict_config.duplicate()
	var next_numeric_key := "0"
	for key in remaining_config:
		if key == next_numeric_key:
			# add an unkeyed entry like ["foo"]
			result.append(remaining_config[key])
			next_numeric_key = str(int(next_numeric_key) + 1)
		else:
			# add a keyed entry like ["foo=bar"]
			result.append("%s=%s" % [key, remaining_config[key]])
	return result
