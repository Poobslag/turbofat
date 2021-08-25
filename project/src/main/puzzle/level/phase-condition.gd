class_name PhaseCondition
"""
Defines the conditions under which a level trigger should fire.

A level can contain triggers which make something happen at a specific time, such as 'add a row of blocks if the player
clears one of the bottom three lines'. A PhaseCondition encapsulates the concept of 'the player clears one of the
bottom three lines', defining what 'the bottom three lines' means and that the check should happen during a line clear.
"""

"""
Creates a new PhaseCondition instance.

The default implementation ignores the '_definition_params' array, but this can be overridden to parse or store the
parameters.

Parameters:
	'_phase_config': (Optional) A set of phase configuration strings defining criteria for a phase condition.
"""
func _init(_phase_config: Dictionary) -> void:
	pass


"""
Can be overridden to return 'true' if a trigger should run during this phase.

The default implementation always returns true, but subclasses can override this behavior.

Parameters:
	'_event_params': (Optional) Phase-specific metadata used to decide whether the trigger should fire
"""
func should_run(_event_params: Dictionary) -> bool:
	return true
