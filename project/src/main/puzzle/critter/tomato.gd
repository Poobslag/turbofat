class_name Tomato
extends Node2D
## A puzzle critter which indicates lines which can't be cleared.
##
## Tomatoes show up when there are full lines which can't be cleared because of level rules. They hold up fingers
## counting down '3, 2, 1' so players can anticipate when lines will clear.

## States the tomato goes through when counting down their fingers.
enum State {
	NONE,
	IDLE_1,
	IDLE_2,
	IDLE_3
}

## The tomato has not appeared yet, or has disappeared.
const NONE := State.NONE

## The tomato is holding up 1, 2 or 3 fingers.
const IDLE_1 := State.IDLE_1
const IDLE_2 := State.IDLE_2
const IDLE_3 := State.IDLE_3

## Enum from State for the tomato's current animation state.
var state := NONE setget set_state

onready var animation_player: AnimationPlayer = $AnimationPlayer

## Poof cloud which covers the tomato when they appear or disappear
onready var poof := $TomatoHolder/Poof

## Red shadow behind the tomato which darkens the line they're affecting
onready var shadow := $TomatoHolder/Shadow

## Tomato sprite
onready var tomato := $TomatoHolder/Tomato

onready var sfx := $TomatoSfx

## Particles which decorate the tomato shadow
onready var _clock_particles := $TomatoHolder/ClockParticles
onready var _light_particles := $TomatoHolder/LightParticles

## key: (int) Enum from State
## value: (Node) State node from the _states StateMachine
onready var _state_nodes_by_enum := {
	NONE: $States/None,
	IDLE_1: $States/Idle1,
	IDLE_2: $States/Idle2,
	IDLE_3: $States/Idle3,
}

onready var _states := $States

## The column the tomato appears in
var column: int = 0 setget set_column

## 'true' if the tomato should not play their voice sfx.
var suppress_voice := false

## 'true' if the tomato will be queued for deletion after the 'poof' animation completes.
var _free_after_poof := false

var _particles_tween: SceneTreeTween

func _ready() -> void:
	_clock_particles.visible = false
	_light_particles.visible = false
	
	# The state machine defaults to the 'none' state and not the 'null' state to avoid edge cases
	_states.set_state(_state_nodes_by_enum[NONE])
	_refresh_state()
	_refresh_column()


## Parameters:
## 	'new_state': enum from State for the tomato's new animation state.
func set_state(new_state: int) -> void:
	if state == new_state:
		return
	state = new_state
	_refresh_state()


## Plays a 'poof' animation and queues the tomato for deletion.
func poof_and_free() -> void:
	set_state(NONE)
	
	if poof.is_poof_animation_playing():
		_free_after_poof = true
	else:
		queue_free()


func set_column(new_column: int) -> void:
	column = new_column
	_refresh_column()


## Makes the shadow and particles visible and starts their animation.
func show_backdrop() -> void:
	shadow.start()
	
	_particles_tween = Utils.recreate_tween(self, _particles_tween).set_parallel()
	for particles_node in [_clock_particles, _light_particles]:
		particles_node.visible = true
		particles_node.modulate = Color.transparent
		_particles_tween.tween_property(particles_node, "modulate", Color.white, TomatoShadow.FADE_IN_DURATION)


## Makes the shadow and particles invisible and stops their animation.
func hide_backdrop() -> void:
	shadow.stop()
	
	_particles_tween = Utils.recreate_tween(self, _particles_tween).set_parallel()
	for particles_node in [_clock_particles, _light_particles]:
		_particles_tween.tween_property(particles_node, "modulate", Color.transparent, TomatoShadow.FADE_OUT_DURATION)
		_particles_tween.tween_callback(particles_node, "set", ["visible", false]) \
				.set_delay(TomatoShadow.FADE_OUT_DURATION)


## Updates the state machine's state to match the value of the 'state' enum.
func _refresh_state() -> void:
	if not is_inside_tree():
		return
	
	_states.set_state(_state_nodes_by_enum[state])


## Updates the tomato's position to match our column property.
func _refresh_column() -> void:
	if not is_inside_tree():
		return
	
	tomato.position.x = 40 + column * 72.0
	poof.position.x = 40 + column * 72.0


## When the 'poof' animation finishes, if poof_and_free() was called then we queue the tomato for deletion.
func _on_Poof_animation_finished() -> void:
	if _free_after_poof:
		queue_free()
