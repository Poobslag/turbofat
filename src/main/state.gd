class_name State
extends Node
"""
An abstract 'state' object for use in conjunction with the StateMachine class.
"""

# The number of frames this state has been active for.
var frames := 0

"""
Called once when the state is first entered.

Parameters:
	'_host': The state machine's parent object.
	
	'_prev_state': The previous state the state machine was in.
"""
func enter(_host, _prev_state_name: String) -> void:
	pass

"""
Called once each frame to make the state update.

Returns the name of the new state to transition to, or '' if the state should not change.

Parameters:
	'_host': The state machine's parent object.
"""
func update(_host) -> String:
	return ""
