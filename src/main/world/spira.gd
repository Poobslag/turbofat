class_name Spira
extends KinematicBody2D
"""
Script for manipulating the player-controlled character 'Spira' in the overworld.
"""

# Number from [0.0, 1.0] which determines how quickly Spira slows down
const FRICTION := 0.15

# How slow can Spira move before she stops
const MIN_RUN_SPEED := 150

# How fast can Spira move
const MAX_RUN_SPEED := 338

# How fast can Spira accelerate
const MAX_RUN_ACCELERATION := 2250

# The factor to multiply by to convert non-isometric coordinates into isometric coordinates
const ISO_FACTOR := Vector2(1.0, 0.5)

# 'true' if Spira is being slowed by friction while stopping or turning
var _friction := false

# 'true' if the controls should be rotated 45 degrees, giving the player orthographic controls.
# 'false' if the controls should not be rotated, giving the player isometric controls.
var _rotate_controls := false

# the velocity the player is moving, in isometric and non-isometric coordinates
var _iso_velocity := Vector2.ZERO
var _non_iso_velocity := Vector2.ZERO

# the input direction the player is pressing, in isometric and non-isometric coordinates
var _iso_walk_direction := Vector2.ZERO
var _non_iso_walk_direction := Vector2.ZERO

func _ready() -> void:
	# Spira is dark red with black eyes.
	set_creature_def({
		"line_rgb": "6c4331", "body_rgb": "b23823", "eye_rgb": "282828 dedede", "horn_rgb": "f1e398",
		"ear": "1", "horn": "1", "mouth": "2", "eye": "1"})


func _unhandled_input(_event: InputEvent) -> void:
	if Utils.ui_pressed_dir(_event) or Utils.ui_released_dir(_event):
		# calculate the direction the player wants to move
		set_non_iso_walk_direction(Utils.ui_pressed_dir())
		if _rotate_controls:
			set_non_iso_walk_direction(_non_iso_walk_direction.rotated(-PI / 4))
		get_tree().set_input_as_handled()


func _physics_process(delta: float) -> void:
	_apply_friction()
	_apply_player_walk(delta)
	set_iso_velocity(move_and_slide(_iso_velocity))
	_update_animation()


func set_non_iso_walk_direction(new_direction: Vector2) -> void:
	_non_iso_walk_direction = new_direction
	_iso_walk_direction = _to_iso(new_direction)


func set_iso_velocity(new_velocity: Vector2) -> void:
	_iso_velocity = new_velocity
	_non_iso_velocity = _from_iso(new_velocity)


func set_non_iso_velocity(new_velocity: Vector2) -> void:
	_non_iso_velocity = new_velocity
	_iso_velocity = _to_iso(new_velocity)


func set_creature_def(creature_def: Dictionary) -> void:
	set_meta("creature_def", creature_def)
	$Creature.summon(creature_def)


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on $Creature/MovementAnims, omitting the directional suffix
	
	'movement_direction': A vector in the (X, Y) direction the creature is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	$Creature.play_movement_animation(animation_prefix, movement_direction)


func _to_iso(vector: Vector2) -> Vector2:
	return vector * ISO_FACTOR


func _from_iso(vector: Vector2) -> Vector2:
	return vector / ISO_FACTOR


func _apply_friction() -> void:
	if _iso_velocity and _iso_walk_direction:
		_friction = _non_iso_velocity.normalized().dot(_non_iso_walk_direction.normalized()) < 0.25
	else:
		_friction = true
	
	if _friction:
		set_non_iso_velocity(lerp(_non_iso_velocity, Vector2.ZERO, FRICTION))
		if _non_iso_velocity.length() < MIN_RUN_SPEED:
			set_non_iso_velocity(Vector2.ZERO)


func _apply_player_walk(delta: float) -> void:
	if _iso_walk_direction:
		_accelerate_player_xy(delta, _non_iso_walk_direction, MAX_RUN_ACCELERATION, MAX_RUN_SPEED)


"""
Accelerates Spira horizontally.

If Spira would be accelerated beyond the specified maximum speed, Spira's acceleration is reduced.
"""
func _accelerate_player_xy(delta: float, _non_iso_push_direction: Vector2,
		acceleration: float, max_speed: float) -> void:
	if _non_iso_push_direction.length() == 0:
		return

	var accel_vector := _non_iso_push_direction.normalized() * acceleration * delta
	var new_velocity := _non_iso_velocity + accel_vector
	if new_velocity.length() > _non_iso_velocity.length() and new_velocity.length() > max_speed:
		new_velocity = new_velocity.normalized() * max_speed
	set_non_iso_velocity(new_velocity)


func _update_animation() -> void:
	var old_orientation: int = $Creature.orientation
	if _non_iso_walk_direction.length() > 0:
		play_movement_animation("run", _non_iso_velocity)
	else:
		play_movement_animation("idle", _non_iso_velocity)


func _on_Creature_landed() -> void:
	$HopSound.play()
