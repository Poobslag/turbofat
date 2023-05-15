class_name State
extends Node
## Empty 'state' script for use in conjunction with the StateMachine class.
##
## States should extend from this script to define functionality.

## Number of frames this state has been active for.
var frames := 0

## Called when the state is entered.
##
## Parameters:
## 	'_host': The state machine's parent object.
##
## 	'_prev_state_name': The state name the state machine was in before this one.
func enter(_host, _prev_state_name: String) -> void:
	pass


## Called when the state is exited.
##
## Parameters:
## 	'_host': The state machine's parent object.
##
## 	'_new_state_name': The state name the state machine will be in after this one.
func exit(_host, _new_state_name: String) -> void:
	pass


## Called each frame to make the state update.
##
## Returns the name of the new state to transition to, or '' if the state should not change.
##
## Parameters:
## 	'_host': The state machine's parent object.
func update(_host) -> String:
	return ""
