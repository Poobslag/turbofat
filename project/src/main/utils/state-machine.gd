class_name StateMachine
extends Node
## Implementation of the state pattern.
##
## State nodes can be added to this node as children. This class provides logic for switching between its child states,
## invoking their methods, and emitting signals.

## emitted once when a state is entered
signal entered_state(prev_state, state)

## currently active state
var _state: State

## host object which is passed into each state
@onready var _host := get_parent()

## Calls 'update' on the currently active state, and changes the current state if necessary.
func update() -> void:
	var old_state := _state
	var new_state_name: String = _state.update(_host)
	if new_state_name:
		# The update() method returned a non-empty string. This signals us to transition to a new state.
		
		if old_state == _state:
			# We only transition if the state stayed the same during the update() method. It's possible for
			# State1.update() to transition to State2 and return State3. In that case, State2 wins.
			set_state(get_node(new_state_name))
	_state.frames += 1


## Transitions to a new state.
##
## Resets the state's internal variables and notifies any listeners.
func set_state(new_state: State) -> void:
	var prev_state := _state
	var prev_state_name: String = "" if _state == null else _state.name as String
	var new_state_name: String = "" if new_state == null else new_state.name as String
	if _state:
		_state.exit(_host, new_state_name)
	_state = new_state
	_state.frames = 0
	_state.enter(_host, prev_state_name)
	emit_signal("entered_state", prev_state, _state)


func get_state() -> State:
	return _state
