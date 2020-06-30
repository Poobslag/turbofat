class_name Creature
extends KinematicBody2D
"""
Script for representing a creature in the 2D overworld.
"""

signal fatness_changed

signal creature_arrived

signal food_eaten

const SOUTHEAST = CreatureVisuals.SOUTHEAST
const SOUTHWEST = CreatureVisuals.SOUTHWEST
const NORTHWEST = CreatureVisuals.NORTHWEST
const NORTHEAST = CreatureVisuals.NORTHEAST

# Number from [0.0, 1.0] which determines how quickly the creature slows down
const FRICTION := 0.15

# How slow can the creature move before she stops
const MIN_RUN_SPEED := 150

# How fast can the creature move
const MAX_RUN_SPEED := 338

# How fast can the creature accelerate
const MAX_RUN_ACCELERATION := 2250

export (Dictionary) var creature_def: Dictionary setget set_creature_def
export (String) var chat_id: String setget set_chat_id
export (String) var chat_name: String setget set_chat_name
export (Dictionary) var chat_theme_def: Dictionary setget set_chat_theme_def

# 'true' if the creature is being slowed by friction while stopping or turning
var _friction := false

# the velocity the player is moving, in isometric and non-isometric coordinates
var _iso_velocity := Vector2.ZERO
var _non_iso_velocity := Vector2.ZERO

# the direction the creature wants to move, in isometric and non-isometric coordinates
var _iso_walk_direction := Vector2.ZERO
var _non_iso_walk_direction := Vector2.ZERO

onready var _creature: CreatureVisuals = $Visuals

func _ready() -> void:
	_refresh()


func _physics_process(delta: float) -> void:
	_apply_friction()
	_apply_walk(delta)
	var old_non_iso_velocity := _non_iso_velocity
	set_iso_velocity(move_and_slide(_iso_velocity))
	_update_animation()
	_maybe_play_bonk_sound(old_non_iso_velocity)


func set_fatness(new_fatness: float) -> void:
	_creature.set_fatness(new_fatness)


func get_fatness() -> float:
	return _creature.get_fatness()


func set_non_iso_walk_direction(new_direction: Vector2) -> void:
	_non_iso_walk_direction = new_direction
	_iso_walk_direction = Global.to_iso(new_direction)


func set_iso_velocity(new_velocity: Vector2) -> void:
	_iso_velocity = new_velocity
	_non_iso_velocity = Global.from_iso(new_velocity)


func set_non_iso_velocity(new_velocity: Vector2) -> void:
	_non_iso_velocity = new_velocity
	_iso_velocity = Global.to_iso(new_velocity)


func set_creature_def(new_creature_def: Dictionary) -> void:
	creature_def = new_creature_def
	set_meta("creature_def", creature_def)
	_refresh()


func set_chat_id(new_chat_id: String) -> void:
	chat_id = new_chat_id
	set_meta("chat_id", chat_id)


func set_chat_name(new_chat_name: String) -> void:
	chat_name = new_chat_name
	set_meta("chat_name", chat_name)


func set_chat_theme_def(new_chat_theme_def: Dictionary) -> void:
	chat_theme_def = new_chat_theme_def
	set_meta("chat_theme_def", chat_theme_def)


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on Creature/MovementAnims, omitting the directional suffix
	
	'movement_direction': A vector in the (X, Y) direction the creature is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	_creature.play_movement_animation(animation_prefix, movement_direction)


"""
Animates the creature's appearance according to the specified mood: happy, angry, etc...

Parameters:
	'mood': The creature's new mood from ChatEvent.Mood
"""
func play_mood(mood: int) -> void:
	_creature.play_mood(mood)


"""
Orients this creature so they're facing the specified target.
"""
func orient_toward(target: Node2D) -> void:
	if not _creature.is_idle():
		# don't change this creature's orientation if they're performing an activity
		return
	
	# calculate the relative direction of the object this creature should face
	var direction: Vector2 = Global.from_iso(position.direction_to(target.position))
	var direction_dot := 0.0
	if direction:
		direction_dot = direction.normalized().dot(Vector2.RIGHT)
		if direction_dot == 0.0:
			# if two characters are directly above/below each other, make them face opposite directions
			direction_dot = direction.normalized().dot(Vector2.DOWN)

	if direction_dot > 0:
		# the target is to the right; face right
		_creature.set_orientation(SOUTHEAST)
	elif direction_dot < 0:
		# the target is to the left; face left
		_creature.set_orientation(SOUTHWEST)


"""
Plays a 'hello!' voice sample, for when a creature enters the restaurant
"""
func play_hello_voice(force: bool = false) -> void:
	$CreatureSfx.play_hello_voice(force)


"""
Plays a 'mmm!' voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	$CreatureSfx.play_combo_voice()


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice(force: bool = false) -> void:
	$CreatureSfx.play_goodbye_voice(force)


func feed(food_color: Color) -> void:
	_creature.feed(food_color)


func _refresh() -> void:
	if is_inside_tree():
		if creature_def:
			_creature.summon(creature_def)
		if not chat_id:
			$ChatIcon.bubble_type = ChatIcon.BubbleType.NONE


func _apply_friction() -> void:
	if _iso_velocity and _iso_walk_direction:
		_friction = _non_iso_velocity.normalized().dot(_non_iso_walk_direction.normalized()) < 0.25
	else:
		_friction = true
	
	if _friction:
		set_non_iso_velocity(lerp(_non_iso_velocity, Vector2.ZERO, FRICTION))
		if _non_iso_velocity.length() < MIN_RUN_SPEED:
			set_non_iso_velocity(Vector2.ZERO)


func _apply_walk(delta: float) -> void:
	if _iso_walk_direction:
		_accelerate_xy(delta, _non_iso_walk_direction, MAX_RUN_ACCELERATION, MAX_RUN_SPEED)


"""
Accelerates the creature horizontally.

If the creature would be accelerated beyond the specified maximum speed, the creature's acceleration is reduced.
"""
func _accelerate_xy(delta: float, _non_iso_push_direction: Vector2,
		acceleration: float, max_speed: float) -> void:
	if _non_iso_push_direction.length() == 0:
		return

	var accel_vector := _non_iso_push_direction.normalized() * acceleration * delta
	var new_velocity := _non_iso_velocity + accel_vector
	if new_velocity.length() > _non_iso_velocity.length() and new_velocity.length() > max_speed:
		new_velocity = new_velocity.normalized() * max_speed
	set_non_iso_velocity(new_velocity)


"""
Plays a bonk sound if Spira bumps into a wall.
"""
func _maybe_play_bonk_sound(old_non_iso_velocity: Vector2) -> void:
	var velocity_diff := _non_iso_velocity - old_non_iso_velocity
	if velocity_diff.length() > MAX_RUN_SPEED * 0.9:
		$BonkSound.play()


func _update_animation() -> void:
	if _non_iso_walk_direction.length() > 0:
		play_movement_animation("run", _non_iso_walk_direction)
	elif _creature.movement_mode:
		play_movement_animation("idle", _non_iso_velocity)


func _on_Creature_landed() -> void:
	$HopSound.play()


func _on_Creature_fatness_changed() -> void:
	emit_signal("fatness_changed")


func _on_CreatureVisuals_creature_arrived() -> void:
	visible = true
	emit_signal("creature_arrived")


func _on_CreatureVisuals_food_eaten() -> void:
	emit_signal("food_eaten")
