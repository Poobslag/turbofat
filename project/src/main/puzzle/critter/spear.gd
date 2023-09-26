class_name Spear
extends Node2D
## A puzzle critter which adds veggie blocks from the sides.
##
## Sharks pop out onto the playfield, destroying any blocks they collide with. Depending on the level configuration,
## they might retreat eventually. If they retreat, they leave behind empty cells which is annoying as well.

## Which playfield side the spear appears from.
enum Side {
	LEFT,
	RIGHT,
}

## States the spear goes through when appearing/disappearing.
enum State {
	NONE,
	WAITING,
	WAITING_END,
	POPPED_IN,
	POPPED_OUT,
}

const UNPOPPED_SPEAR_SPRITE_X := -450

const LEFT := Side.LEFT
const RIGHT := Side.RIGHT

const NONE := State.NONE
const WAITING := State.WAITING
const WAITING_END := State.WAITING_END
const POPPED_IN := State.POPPED_IN
const POPPED_OUT := State.POPPED_OUT

## Enum from State for the spear's current animation state.
var state: int = NONE setget set_state

## Which playfield side the spear appears from.
var side: int = Side.LEFT setget set_side

## The duration in seconds of the spear's pop in/pop out animation.
var pop_anim_duration := 0.6

## The length in pixels of the visible portion of the spear, after it's popped out. This can be a small number for
## short spears, or a large number for longer spears.
var pop_length := 450

## 'true' if a state has already been popped from the _next_states queue this frame. We track this to avoid
## accidentally popping two states from the queue when the spear first spawns.
var _already_popped_state := false

## 'true' if the Spear will be queued for deletion after the 'poof' animation completes.
var _free_after_poof := false

## Queue of enums from State for the spear's upcoming animation states.
var _next_states := []

## Schedules events for the spear's pop in/pop out animations.
var _pop_tween: SceneTreeTween

## key: (int) Enum from State
## value: (Node) State node from the _states StateMachine
onready var _state_nodes_by_enum := {
	NONE: $States/None,
	WAITING: $States/Waiting,
	WAITING_END: $States/WaitingEnd,
	POPPED_IN: $States/PoppedIn,
	POPPED_OUT: $States/PoppedOut,
}

onready var poof: Sprite = $Poof
onready var sfx: SpearSfx = $SpearSfx
onready var spear_holder: Control = $SpearHolder
onready var spear_sprite: Sprite = $SpearHolder/Spear
onready var wait: SpearWaitSprite = $Wait

onready var _crumb_holder := $CrumbHolder
onready var _dirt_particles_burst: Particles2D = $SoilFront/DirtParticlesBurst
onready var _dirt_particles_continuous: Particles2D = $SoilFront/DirtParticlesContinuous
onready var _face: Sprite = $SpearHolder/Spear/Face
onready var _soil_back: Sprite = $SoilFront
onready var _soil_front: Sprite = $SoilBack
onready var _states: StateMachine = $States

func _ready() -> void:
	# The state machine defaults to the 'none' state and not the 'null' state to avoid edge cases
	_states.set_state(_state_nodes_by_enum[NONE])
	spear_sprite.position.x = -450
	
	_refresh_side()
	_refresh_state()


func _process(_delta: float) -> void:
	_already_popped_state = false


## Cancels any events for the spear's pop in/pop out animations.
func kill_pop_tween() -> void:
	Utils.kill_tween(_pop_tween)
	_dirt_particles_burst.emitting = false
	_dirt_particles_continuous.emitting = false


func set_side(new_side: int) -> void:
	side = new_side
	_refresh_side()


## Enqueues an enums from State to the spear's upcoming animation states.
##
## Parameters:
## 	'next_state': Enum from State
##
## 	'count': (Optional) Number of instances of the state to enqueue.
func append_next_state(next_state: int, count: int = 1) -> void:
	for _i in range(count):
		_next_states.append(next_state)


## Clears the spear's queue of upcoming animation states.
func clear_next_states() -> void:
	_next_states.clear()


## Returns 'true' if there are states remaining in the spear's queue of upcoming animation states.
func has_next_state() -> bool:
	return not _next_states.empty()


## Dequeues the next state from the spear's queue of upcoming animation states.
##
## Returns:
## 	Enum from State for the spear's new state.
func pop_next_state() -> int:
	if _next_states.empty():
		return NONE
	
	if _already_popped_state:
		pass
	else:
		var next_state: int = _next_states.pop_front()
		set_state(next_state)
		_already_popped_state = true
	
	return state


func pop_in_immediately() -> void:
	kill_pop_tween()
	spear_sprite.position.x = -450 + pop_length
	_dirt_particles_burst.restart()
	_dirt_particles_burst.emitting = true


## Parameters:
## 	'new_state': enum from State for the spear's new animation state.
func set_state(new_state: int) -> void:
	state = new_state
	_refresh_state()


## Plays a 'poof' animation and queues the spear for deletion.
func poof_and_free() -> void:
	set_state(NONE)
	
	if poof.is_poof_animation_playing():
		_free_after_poof = true
	else:
		queue_free()


# Tweens the spear into view, or out of view.
func tween_and_pop(target_x: float, squint_duration: float) -> void:
	sfx.play_pop_sound(pop_anim_duration)
	
	_dirt_particles_burst.restart()
	_dirt_particles_burst.emitting = true
	_dirt_particles_continuous.emitting = true
	
	_pop_tween = Utils.recreate_tween(self, _pop_tween)
	_pop_tween.set_parallel()
	_ruffle_soil()
	_face.squint(squint_duration)
	_pop_tween.tween_property(spear_sprite, "position:x", target_x, pop_anim_duration) \
			.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_pop_tween.tween_callback(_dirt_particles_burst, "set", ["emitting", false]) \
			.set_delay(pop_anim_duration)
	_pop_tween.tween_callback(_dirt_particles_continuous, "set", ["emitting", false]) \
			.set_delay(pop_anim_duration * 0.5)
	
	if target_x > UNPOPPED_SPEAR_SPRITE_X:
		# if the spear is popping into view, we play a 'hello' sound effect
		_pop_tween.tween_callback(sfx, "play_hello_voice").set_delay(0.1)


## Emits particle properties based on the speared blocks.
##
## Parameters:
## 	'crumb_colors': An array of Color instances corresponding to crumb colors for destroyed blocks.
##
## 	'width': The width in pixels which should be covered in crumbs.
func emit_crumbs(crumb_colors: Array, row: int) -> void:
	_crumb_holder.get_child(row).emit_crumbs(crumb_colors, pop_length)


## Schedules the soil to cycle between frames as the spear pops in or out.
func _ruffle_soil() -> void:
	for soil_sprite in [_soil_back, _soil_front]:
		# make the soil visible
		soil_sprite.visible = true
		soil_sprite.frame = 0
		
		_pop_tween.tween_callback(soil_sprite, "set", ["frame", 1]).set_delay(pop_anim_duration * 0.050)
		_pop_tween.tween_callback(soil_sprite, "set", ["frame", 2]).set_delay(pop_anim_duration * 0.080)
		_pop_tween.tween_callback(soil_sprite, "set", ["frame", 0]).set_delay(pop_anim_duration * 0.130)
		_pop_tween.tween_callback(soil_sprite, "set", ["frame", 1]).set_delay(pop_anim_duration * 0.210)
		_pop_tween.tween_callback(soil_sprite, "set", ["frame", 2]).set_delay(pop_anim_duration * 0.340)
		_pop_tween.tween_callback(soil_sprite, "set", ["frame", 0]).set_delay(pop_anim_duration * 0.550)


## Refreshes our visuals based on the 'side' property.
##
## Most of our visual elements flip or change position if we're appearing on the left or right side.
func _refresh_side() -> void:
	if not is_inside_tree():
		return
	
	var new_child_scale := -1 if side == Side.RIGHT else 1
	_soil_back.scale.x = new_child_scale
	spear_holder.rect_scale.x = new_child_scale
	_soil_front.scale.x = new_child_scale
	_crumb_holder.rect_scale.x = new_child_scale
	wait.position.x = abs(wait.position.x) * new_child_scale
	poof.position.x = abs(poof.position.x) * new_child_scale


## Updates the state machine's state to match the value of the 'state' enum.
func _refresh_state() -> void:
	if not is_inside_tree():
		return
	
	_states.set_state(_state_nodes_by_enum[state])


## When the 'poof' animation finishes, if poof_and_free() was called then we queue the spear for deletion.
func _on_Poof_animation_finished() -> void:
	if _free_after_poof:
		queue_free()
