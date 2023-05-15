class_name Mole
extends Node2D
## A puzzle critter which digs up star seeds for the player.
##
## Moles dig for a few turns, and then add a pickup to the playfield. But they can be interrupted if they are crushed,
## or if the player clears the row they are digging.

## States the mole goes through when digging up star seeds.
enum States {
	NONE,
	WAITING,
	DIGGING,
	DIGGING_END,
	FOUND_SEED,
	FOUND_STAR,
}

## The mole has not appeared yet, or has disappeared.
const NONE := States.NONE

## The mole will appear soon. If the player crushes the mole with their piece when it is in this state, it relocates
## elsewhere in the playfield. This is so that players are not punished unfairly for crushing a mole which they did
## not see quickly enough.
const WAITING := States.WAITING

## The mole is digging, searching for a star seed.
const DIGGING := States.DIGGING

## The mole has found a star seed, and will finish digging it up very soon.
const DIGGING_END := States.DIGGING_END

## The mole has found a seed pickup.
const FOUND_SEED := States.FOUND_SEED

## The mole has found a star pickup.
const FOUND_STAR := States.FOUND_STAR

## Enum from States for the mole's current animation state.
var state := NONE: set = set_state

## 'true' if the mole is temporarily hidden by the piece.
var hidden_by_piece: bool: set = set_hidden_by_piece

## Enum from States for the mole's previous animation state, if they are temporarily hidden by the player's piece.
var hidden_mole_state := NONE

## 'true' if the Mole will be queued for deletion after the 'poof' animation completes.
var _free_after_poof := false

## Queue of enums from States for the mole's upcoming animation states.
var _next_states := []

## 'true' if a state has already been popped from the _next_states queue this frame. We track this to avoid
## accidentally popping two states from the queue when the mole first spawns.
var _already_popped_state := false

## key: (int) Enum from States
## value: (Node) State node from the _states StateMachine
@onready var _state_nodes_by_enum := {
	NONE: $States/None,
	WAITING: $States/Waiting,
	DIGGING: $States/Digging,
	DIGGING_END: $States/DiggingEnd,
	FOUND_SEED: $States/FoundSeed,
	FOUND_STAR: $States/FoundStar,
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Mole sprite
@onready var mole := $Mole

## Poof cloud which covers the mole when they appear or disappear
@onready var poof: CritterPoof = $Poof

## Speech bubble which appears in the mole's place when the mole is waiting to appear
@onready var wait_low := $WaitLow

## Speech bubble which appears over the mole's head when the mole is digging
@onready var wait_high := $WaitHigh

@onready var sfx := $MoleSfx

@onready var _states: StateMachine = $States

func _ready() -> void:
	# The state machine defaults to the 'none' state and not the 'null' state to avoid edge cases
	_states.set_state(_state_nodes_by_enum[NONE])
	
	_refresh_state()


func _enter_tree() -> void:
	_states = $States


func _process(_delta: float) -> void:
	_already_popped_state = false


## Temporarily hides/unhides the mole with a 'poof' animation.
func set_hidden_by_piece(new_hidden_by_piece: bool) -> void:
	if hidden_by_piece == new_hidden_by_piece:
		return
	hidden_by_piece = new_hidden_by_piece
	
	if hidden_by_piece:
		hidden_mole_state = state
		set_state(NONE)
	else:
		set_state(hidden_mole_state)
		hidden_mole_state = NONE


## Enqueues an enums from States to the mole's upcoming animation states.
##
## Parameters:
## 	'next_state': Enum from States
##
## 	'count': (Optional) Number of instances of the state to enqueue.
func append_next_state(next_state: States, count: int = 1) -> void:
	for _i in range(count):
		_next_states.append(next_state)


## Returns 'true' if there are states remaining in the mole's queue of upcoming animation states.
func has_next_state() -> bool:
	return not _next_states.is_empty()


## Dequeues the next state from the mole's queue of upcoming animation states.
##
## If the mole is currently visible, this updates the mole's animation and returns the dequeued state.
##
## If the mole is currently hidden, they remain invisible. But this still updates their hidden state and returns the
## dequeued state.
##
## Returns:
## 	Enum from States for the mole's new state.
func pop_next_state() -> States:
	if _next_states.is_empty():
		return NONE
	
	if _already_popped_state:
		pass
	else:
		var next_state: States = _next_states.pop_front()
		if hidden_by_piece:
			hidden_mole_state = next_state
		else:
			set_state(next_state)
		_already_popped_state = true
	
	return hidden_mole_state if hidden_by_piece else state


## Parameters:
## 	'new_state': mole's new animation state.
func set_state(new_state: States) -> void:
	state = new_state
	_refresh_state()


## Plays a 'poof' animation and queues the mole for deletion.
func poof_and_free() -> void:
	hidden_mole_state = NONE
	set_state(NONE)
	
	if poof.is_poof_animation_playing():
		_free_after_poof = true
	else:
		queue_free()


## Updates the state machine's state to match the value of the 'state' enum.
func _refresh_state() -> void:
	if not is_inside_tree():
		return
	
	_states.set_state(_state_nodes_by_enum[state])


## When the 'poof' animation finishes, if poof_and_free() was called then we queue the mole for deletion.
func _on_Poof_animation_finished() -> void:
	if _free_after_poof:
		queue_free()
