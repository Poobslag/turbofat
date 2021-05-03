class_name LevelTrigger
"""
A trigger which causes strange things to happen during a level.

A level can contain any number of triggers, and each trigger makes something happen at a specific time. For example, a
trigger might rotate the pieces in the piece queue every 2 seconds, or a trigger might toggle the playfield invisible
every time the player places a piece.
"""

# phases when a level trigger can fire
enum LevelTriggerPhase {
	ROTATED_CW,
	ROTATED_CCW,
	ROTATED_180,
	INITIAL_ROTATED_CW,
	INITIAL_ROTATED_CCW,
	INITIAL_ROTATED_180,
}

const ROTATED_CW := LevelTriggerPhase.ROTATED_CW
const ROTATED_CCW := LevelTriggerPhase.ROTATED_CCW
const ROTATED_180 := LevelTriggerPhase.ROTATED_180
const INITIAL_ROTATED_CW := LevelTriggerPhase.INITIAL_ROTATED_CW
const INITIAL_ROTATED_CCW := LevelTriggerPhase.INITIAL_ROTATED_CCW
const INITIAL_ROTATED_180 := LevelTriggerPhase.INITIAL_ROTATED_180

# key: json string corresponding to a phase
# value: an enum from LevelTriggerPhase
const PHASE_INTS_BY_STRING := {
	"rotated_cw": ROTATED_CW,
	"rotated_ccw": ROTATED_CCW,
	"rotated_180": ROTATED_180,
	"initial_rotated_cw": INITIAL_ROTATED_CW,
	"initial_rotated_ccw": INITIAL_ROTATED_CCW,
	"initial_rotated_180": INITIAL_ROTATED_180,
}

# key: an enum from LevelTriggerPhase
# value: 'true' if this trigger should fire during that phase
var phases := {}

# the effect caused by this level trigger
var effect: LevelTriggerEffect

"""
Enables this trigger for the specified phase.

Parameters:
	'phase': an enum from LevelTriggerPhase corresponding to the new phase.
"""
func add_phase(phase: int) -> void:
	phases[phase] = true


"""
Executes this level trigger's effect.

Parameters:
	'params': Parameters specific to this level trigger's phase. For example, a phase which involves clearing lines
		could pass in parameters specifying which lines were cleared.
"""
func run(params: Array = []) -> void:
	effect.run(params)


func from_json_dict(json: Dictionary) -> void:
	for phase_string in json.get("phases", []):
		if not PHASE_INTS_BY_STRING.has(phase_string):
			push_warning("Unrecognized phase: %s" % [phase_string])
			continue
		
		add_phase(PHASE_INTS_BY_STRING.get(phase_string))
	
	var effect_string: String = json.get("effect")
	var effect_key: String = StringUtils.substring_before(effect_string, " ")
	var effect_config: Array = StringUtils.substring_after(effect_string, " ").split(" ")
	if not LevelTriggerEffects.effects_by_string.has(effect_key):
		push_warning("Unrecognized effect: %s" % [effect_key])
	var effect_script: GDScript = LevelTriggerEffects.effects_by_string.get(effect_key)
	effect = effect_script.new()
	if effect_config:
		effect.set_config(effect_config)
