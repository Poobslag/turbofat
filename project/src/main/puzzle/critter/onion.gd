class_name Onion
extends Node2D
## An onion, a puzzle critter which darkens things making it hard to see.

## Emitted when the onion starts/stops playing their floating animation
signal float_animation_playing_changed(value)

## The onion's location. They are either in the soil, sky, or transitioning between the two.
enum OnionLocation {
	SOIL,
	ASCENDING,
	SKY,
	DESCENDING,
}

## Time in seconds the onion spends in the air when launching or falling
const LAUNCH_DURATION := 1.2

## Position in the sky the onion should launch towards, defined as units relative to our parent node
export var sky_position: Vector2 = Vector2.ZERO

## The onion's location. They are either in the soil, sky, or transitioning between the two.
export (OnionLocation) var onion_location: int = OnionLocation.SOIL setget set_onion_location

## True if the onion is currently playing their floating animation
export (bool) var float_animation_playing: bool setget set_float_animation_playing

onready var _animation_tree := $AnimationTree
onready var _onion := $Onion
onready var _soil := $Soil

onready var _dirt_particles := $DirtParticles
onready var _onion_location_tween := $OnionLocationTween

## An enum from OnionConfig.OnionState for the onion's current gameplay state.
var state: int = OnionConfig.OnionState.NONE setget set_state

## Queue of enums from States for the onion's upcoming animation states.
var _next_states := []

## The index in next_states for the onion's current state.
var _current_state_index := -1

## 'true' if a state has already been popped from the _next_states queue this frame. We track this to avoid
## accidentally popping two states from the queue when the onion first spawns.
var _already_popped_state := false

func _ready() -> void:
	# The state machine defaults to the 'none' state and not the 'null' state to avoid edge cases
	_animation_tree.active = true
	
	_refresh_state()
	_refresh_onion_location()


func _process(_delta: float) -> void:
	_already_popped_state = false


func set_float_animation_playing(new_float_animation_playing: bool) -> void:
	if float_animation_playing == new_float_animation_playing:
		return
	
	float_animation_playing = new_float_animation_playing
	emit_signal("float_animation_playing_changed", float_animation_playing)


func set_onion_location(new_onion_location: int) -> void:
	if onion_location == new_onion_location:
		return
	
	onion_location = new_onion_location
	_refresh_onion_location()


## Empties the next_states array.
##
## The onion retains its current state.
func clear_states() -> void:
	_current_state_index = -1
	_next_states.clear()


## Enqueues an enums from States to the onion's upcoming animation states.
##
## Parameters:
## 	'next_state': An enum from States
##
## 	'count': (Optional) The number of instances of the state to enqueue.
func append_next_state(next_state: int) -> void:
	_next_states.append(next_state)


## Dequeues the next state from the onion's queue of upcoming animation states.
##
## Updates the onion's animation and returns the dequeued state.
##
## Returns:
## 	An enum from States for the onion's new state.
func advance_state() -> int:
	if _already_popped_state:
		pass
	elif _next_states.empty():
		set_state(OnionConfig.OnionState.NONE)
	else:
		_current_state_index = (_current_state_index + 1) % _next_states.size()
		set_state(_next_states[_current_state_index])
	
	return state


func set_state(new_state: int) -> void:
	state = new_state
	_refresh_state()


## Plays a 'poof' animation and queues the onion for deletion.
func poof_and_free() -> void:
	set_state(OnionConfig.OnionState.NONE)
	queue_free()


func emit_dirt_particles() -> void:
	_dirt_particles.emitting = true


## Immediately puts the onion in the sky without an animation.
##
## This is used when initially loading a night level, or when restarting a permanently dark level.
func skip_to_night_mode() -> void:
	# There is no path to the 'skip-to-float' node, so the animation tree always warps there instantly.
	_animation_tree["parameters/playback"].travel("skip-to-float")


## Resets the onion to the first state in its day/night cycle.
func reset_cycle() -> void:
	if _next_states.empty():
		set_state(OnionConfig.OnionState.NONE)
	else:
		_current_state_index = 0
		set_state(_next_states[_current_state_index])


## Updates the state machine's state to match the value of the 'state' enum.
func _refresh_state() -> void:
	if not is_inside_tree():
		return
	
	_refresh_animation_tree_conditions()


func _refresh_onion_location() -> void:
	if not is_inside_tree():
		return
	
	_onion_location_tween.remove_all()
	match onion_location:
		OnionLocation.SOIL:
			_onion.position = _soil.position
		OnionLocation.ASCENDING:
			_onion_location_tween.interpolate_property(_onion, "position", null,
					_local_sky_position(), LAUNCH_DURATION, Tween.TRANS_QUAD, Tween.EASE_OUT)
			_onion_location_tween.start()
		OnionLocation.SKY:
			_onion.position = _local_sky_position()
		OnionLocation.DESCENDING:
			_onion_location_tween.interpolate_property(_onion, "position", null,
					_soil.position, LAUNCH_DURATION, Tween.TRANS_QUAD, Tween.EASE_IN)
			_onion_location_tween.start()
	
	_refresh_animation_tree_conditions()


func _local_sky_position() -> Vector2:
	return (sky_position - position) / scale


func _refresh_animation_tree_conditions() -> void:
	_animation_tree.set("parameters/conditions/location_soil", _onion.position == _soil.position)
	_animation_tree.set("parameters/conditions/location_sky", _onion.position == _local_sky_position())
	_animation_tree.set("parameters/conditions/dancing", state == OnionConfig.OnionState.DAY)
	_animation_tree.set("parameters/conditions/dancing_end", state == OnionConfig.OnionState.DAY_END)
	_animation_tree.set("parameters/conditions/floating", state == OnionConfig.OnionState.NIGHT)
	_animation_tree.set("parameters/conditions/not_floating", state != OnionConfig.OnionState.NIGHT)


func _on_OnionLocationTween_tween_completed(object: Object, key: NodePath) -> void:
	if object == _onion and key == ":position":
		_refresh_animation_tree_conditions()
