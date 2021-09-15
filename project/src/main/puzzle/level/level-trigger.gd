class_name LevelTrigger
"""
A trigger which causes strange things to happen during a level.

A level can contain any number of triggers, and each trigger makes something happen at a specific time. For example, a
trigger might rotate the pieces in the piece queue every 2 seconds, or a trigger might toggle the playfield invisible
every time the player places a piece.
"""

# phases when a level trigger can fire
enum LevelTriggerPhase {
	AFTER_LINE_CLEARED,
	INITIAL_ROTATED_CW, # when the piece is rotated clockwise using initial DAS
	INITIAL_ROTATED_CCW, # when the piece is rotated counterclockwise using initial DAS
	INITIAL_ROTATED_180, # when the piece is flipped using initial DAS
	ROTATED_CW, # when the piece is rotated clockwise
	ROTATED_CCW, # when the piece is rotated counterclockwise
	ROTATED_180, # when the piece is flipped
	TIMER_0, # when timer 0 times out
}

const AFTER_LINE_CLEARED := LevelTriggerPhase.AFTER_LINE_CLEARED
const INITIAL_ROTATED_CW := LevelTriggerPhase.INITIAL_ROTATED_CW
const INITIAL_ROTATED_CCW := LevelTriggerPhase.INITIAL_ROTATED_CCW
const INITIAL_ROTATED_180 := LevelTriggerPhase.INITIAL_ROTATED_180
const ROTATED_CW := LevelTriggerPhase.ROTATED_CW
const ROTATED_CCW := LevelTriggerPhase.ROTATED_CCW
const ROTATED_180 := LevelTriggerPhase.ROTATED_180
const TIMER_0 := LevelTriggerPhase.TIMER_0

# key: json string corresponding to a phase
# value: an enum from LevelTriggerPhase
const PHASE_INTS_BY_STRING := {
	"after_line_cleared": AFTER_LINE_CLEARED,
	"initial_rotated_cw": INITIAL_ROTATED_CW,
	"initial_rotated_ccw": INITIAL_ROTATED_CCW,
	"initial_rotated_180": INITIAL_ROTATED_180,
	"rotated_cw": ROTATED_CW,
	"rotated_ccw": ROTATED_CCW,
	"rotated_180": ROTATED_180,
	"timer_0": TIMER_0,
}

# key: an enum from LevelTriggerPhase
# value: array of PhaseCondition instances defining whether the trigger should fire
var phases := {}

# the effect caused by this level trigger
var effect: LevelTriggerEffect

"""
Returns 'true' if this trigger should run during the specified phase.

Parameters:
	'phase': An enum from LevelTriggerPhase
	
	'event_params': (Optional) Phase-specific metadata used to decide whether the trigger should fire
"""
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


"""
Executes this level trigger's effect.
"""
func run() -> void:
	effect.run()


func from_json_dict(json: Dictionary) -> void:
	for phase_expression in json.get("phases", []):
		var phase_expression_split: Array = phase_expression.split(" ")
		var phase_key: String = phase_expression_split[0]
		var phase_config: Dictionary = dict_config(phase_expression_split.slice(1, phase_expression_split.size()))
		_add_phase(phase_key, phase_config)
	
	var effect_split: Array = json.get("effect").split(" ")
	var effect_key: String = effect_split[0]
	var effect_config: Dictionary = dict_config(effect_split.slice(1, effect_split.size()))
	effect = LevelTriggerEffects.create(effect_key, effect_config)


"""
Enables this trigger for the specified phase.

Parameters:
	'phase_key': A string key corresponding to the phase, such as 'after_line_cleared'.
	
	'phase_config': An array of strings defining any special conditions for the phase.
"""
func _add_phase(phase_key: String, phase_config: Dictionary) -> void:
	if not PHASE_INTS_BY_STRING.has(phase_key):
		push_warning("Unrecognized phase: %s" % [phase_key])
	var phase_condition: PhaseCondition = PhaseConditions.create(phase_key, phase_config)
	var phase: int = PHASE_INTS_BY_STRING[phase_key]
	if not phases.has(phase):
		phases[phase] = []
	phases[phase].append(phase_condition)


"""
Parses an array of configuration strings into a set of key/value pairs.

Keyed values like "foo=bar" are added to the resulting dictionary as {"foo": "bar"}

Unkeyed values like "foo" and "bar" are added to the dictionary as {"0": "foo", "1": "bar"}

Parameters:
	'param_array': An array of configuration strings.

Returns:
	A dictionary of configuration strings organized into key/value pairs.
"""
static func dict_config(param_array: Array) -> Dictionary:
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
