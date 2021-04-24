class_name LevelTrigger
"""
A trigger which causes strange things to happen during a level.

A level can contain any number of triggers, and each trigger makes something happen at a specific time. For example, a
trigger might rotate the pieces in the piece queue every 2 seconds, or a trigger might toggle the playfield invisible
every time the player places a piece.
"""

# phases when a level trigger can fire
enum LevelTriggerPhase {
	ROTATED_RIGHT,
	ROTATED_LEFT,
	ROTATED_TWICE,
	INITIAL_ROTATED_RIGHT,
	INITIAL_ROTATED_LEFT,
	INITIAL_ROTATED_TWICE,
}

const ROTATED_RIGHT := LevelTriggerPhase.ROTATED_RIGHT
const ROTATED_LEFT := LevelTriggerPhase.ROTATED_LEFT
const ROTATED_TWICE := LevelTriggerPhase.ROTATED_TWICE
const INITIAL_ROTATED_RIGHT := LevelTriggerPhase.INITIAL_ROTATED_RIGHT
const INITIAL_ROTATED_LEFT := LevelTriggerPhase.INITIAL_ROTATED_LEFT
const INITIAL_ROTATED_TWICE := LevelTriggerPhase.INITIAL_ROTATED_TWICE

# key: json string corresponding to a phase
# value: an enum from LevelTriggerPhase
const PHASE_INTS_BY_STRING := {
	"rotated_right": ROTATED_RIGHT,
	"rotated_left": ROTATED_LEFT,
	"rotated_twice": ROTATED_TWICE,
	"initial_rotated_right": INITIAL_ROTATED_RIGHT,
	"initial_rotated_left": INITIAL_ROTATED_LEFT,
	"initial_rotated_twice": INITIAL_ROTATED_TWICE,
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
