class_name Spira
extends Customer3D
"""
Script for manipulating the player-controlled character 'Spira' in the 3D overworld.
"""

# If acceleration via gravity makes our vertical momentum something small like -6, there's a risk we won't actually
# collide with the surface we're sitting on which causes causing an unpleasant jitter effect.
#
# This is our minimum vertical velocity. Any non-zero values smaller than this will be scaled up.
const MIN_GRAVITY_SPEED = 10.0

# Number from [0.0, 1.0] which determines how quickly Spira slows down
const FRICTION := 0.15

# How fast can Spira move
const MAX_RUN_SPEED := 90

# How fast can Spira slip
const MAX_NARROW_SLIP_SPEED := 120

# How fast can Spira slip
const MAX_LEDGE_SLIP_SPEED := 60

# How fast Spira slips off of slippery platforms
const MAX_SLIP_ACCELERATION := 900

# How fast can Spira accelerate
const MAX_RUN_ACCELERATION := 600

# How slow can Spira move before she stops
const MIN_RUN_SPEED := 40

# How fast does gravity accelerate Spira
const GRAVITY := 400.0

# Vertical force applied to Spira when she jumps
const JUMP_SPEED := 160

# Default position of camera relative to Spira. The camera is above and in front.
const DEFAULT_CAMERA_TRANSLATION := Vector3(300, 250, 300)

# How far the camera should lead Spira's movement when Spira is walking/jumping
const CAMERA_LEAD_DISTANCE := 60

# Number from [0.0, 1.0] for how tight the camera should snap to Spira's movement
const CAMERA_JERKINESS := 0.04

# How many rays we should cast when determining how Spira falls from a ledge
const LEDGE_RAY_COUNT := 16

# How far apart the rays should be when determining how Spira falls from a ledge
const LEDGE_RAY_RADIUS := 12.0

# Spira's (X, Y, Z) velocity
var _velocity := Vector3.ZERO

# 'true' if the controls should be rotated 45 degrees, giving the player orthographic controls.
# 'false' if the controls should not be rotated, giving the player isometric controls.
var _rotate_controls := true

# 'true' if Spira is currently mid-air after having jumped
var _jumping := false

# 'true' if Spira is either slipping, or mid-air after having slipped
var _slipping := false

# 'true' if Spira is being slowed by friction while stopping or turning
var _friction := false

# The direction Spira is walking in (X, Y) coordinates, where 'Y' is forward.
var _walk_direction := Vector2.ZERO

func _ready() -> void:
	._ready()
	$CollisionShape.disabled = false
	InteractableManager.set_spira(self)


func _physics_process(delta) -> void:
	_apply_friction()
	_apply_gravity(delta)
	_apply_player_walk(delta)
	
	var was_on_floor := is_on_floor()
	var old_velocity := _velocity
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
	_update_animation()
	_update_camera_target()
	_maybe_play_bonk_sound(old_velocity)
	_maybe_slip(delta)
	_process_jump_buffers(was_on_floor)


"""
Applies Spira's jump/movement input for most cases. Some edge cases such as buffered jumps are handled outside this
function.
"""
func _unhandled_input(_event: InputEvent) -> void:
	# apply movement
	if Global.ui_pressed_dir() or Global.ui_released_dir():
		# calculate the direction the player wants to move
		_walk_direction = Global.ui_pressed_dir()
		if _rotate_controls:
			_walk_direction = _walk_direction.rotated(-PI / 4)
		if Global.ui_pressed_dir() or Global.ui_released_dir():
			get_tree().set_input_as_handled()
	
	# apply jump
	if Input.is_action_pressed("jump") and not _slipping:
		# pressing/holding jump button
		if is_on_floor() or not $CoyoteTimer.is_stopped():
			_jump()
			get_tree().set_input_as_handled()
		elif Input.is_action_just_pressed("jump"):
			# only start the jump buffer when pressing the button, not when holding it
			$JumpBuffer.start()
		get_tree().set_input_as_handled()


"""
Spira is dark red with black eyes.
"""
func get_customer_def() -> Dictionary:
	return {
		"line_rgb": "6c4331", "body_rgb": "b23823", "eye_rgb": "282828 dedede", "horn_rgb": "f1e398",
		"ear": "0", "horn": "1", "mouth": "1", "eye": "0"
	}


"""
Tries to halt Spira's movement and make her idle.

Returns 'true' if Spira has entered the idle state, or 'false' if she was mid-air or out of the player's control.
"""
func stop_movement() -> bool:
	_walk_direction = Vector2.ZERO
	var became_idle := false
	if _is_midair():
		pass
	elif _slipping:
		pass
	else:
		play_movement_animation("idle")
		became_idle = true
	return became_idle


"""
Plays a bonk sound if Spira bumps into a wall.
"""
func _maybe_play_bonk_sound(old_velocity: Vector3) -> void:
	var velocity_diff := _velocity - old_velocity
	velocity_diff.y = 0
	if velocity_diff.length() > MAX_RUN_SPEED * 0.9:
		if not is_on_floor():
			$BonkSound.unit_db = -9.0
		else:
			$BonkSound.unit_db = -12.0
		$BonkSound.play()


func _maybe_slip(delta: float) -> void:
	if is_on_floor():
		var did_slip := _slip_from_narrow_surfaces(delta)
		if not did_slip:
			did_slip = _slip_from_ledges(delta)
		if _jumping and did_slip:
			# temporarily change the movement animation to 'run' to force the jump animation to restart
			play_movement_animation("run", _get_xy_velocity())
		_slipping = did_slip


func _process_jump_buffers(was_on_floor: bool) -> void:
	if is_on_floor():
		if not $JumpBuffer.is_stopped():
			_jump()
		else:
			_jumping = false
	
	if not is_on_floor() and was_on_floor and not _jumping and not _slipping:
		$CoyoteTimer.start()


func _update_animation() -> void:
	var old_orientation: int = $Viewport/Customer.get_orientation()
	if _slipping:
		play_movement_animation("jump", _get_xy_velocity())
	elif _jumping:
		play_movement_animation("jump", _get_xy_velocity())
	elif _walk_direction.length() > 0:
		play_movement_animation("run", _get_xy_velocity())
	else:
		play_movement_animation("idle", _get_xy_velocity())


func _update_camera_target() -> void:
	var new_translation := DEFAULT_CAMERA_TRANSLATION \
			+ Vector3(_walk_direction.x, 0, _walk_direction.y) * CAMERA_LEAD_DISTANCE
	$CameraTarget.translation = lerp($CameraTarget.translation, new_translation, CAMERA_JERKINESS)


func _apply_gravity(delta: float) -> void:
	_velocity += Vector3.DOWN * GRAVITY * delta

	# If acceleration via gravity makes our momentum something small like -6, there's a risk we won't actually collide
	# with the surface we're sitting on which causes causing an unpleasant jitter effect.
	if _velocity.y < 0.0 and _velocity.y > -MIN_GRAVITY_SPEED:
		_velocity.y = -MIN_GRAVITY_SPEED


func _apply_friction() -> void:
	var xy_velocity: Vector2 = _get_xy_velocity()
	if _is_midair():
		_friction = false
	elif _slipping:
		_friction = false
	elif xy_velocity and _walk_direction:
		_friction = xy_velocity.normalized().dot(_walk_direction.normalized()) < 0.25
	else:
		_friction = true
	
	if _friction:
		xy_velocity = lerp(xy_velocity, Vector2.ZERO, FRICTION)
		if xy_velocity.length() < MIN_RUN_SPEED:
			xy_velocity = Vector2()
		_set_xy_velocity(xy_velocity)


func _is_midair() -> bool:
	return $CoyoteTimer.is_stopped() and not is_on_floor()


"""
Gets Spira's (X, Y, Z) velocity where 'Y' is up as an (X, Y) movement vector where 'Y' is forward.
"""
func _get_xy_velocity() -> Vector2:
	return Vector2(_velocity.x, _velocity.z)


"""
Sets Spira's (X, Y, Z) velocity where 'Y' is up from an (X, Y) movement vector where 'Y' is forward.
"""
func _set_xy_velocity(xy_velocity: Vector2) -> void:
	_velocity.x = xy_velocity.x
	_velocity.z = xy_velocity.y


func _apply_player_walk(delta: float) -> void:
	if _walk_direction:
		if _is_midair():
			pass
		elif _slipping:
			pass
		else:
			_accelerate_player_xy(delta, _walk_direction, MAX_RUN_ACCELERATION, MAX_RUN_SPEED)


"""
Accelerates Spira horizontally.

If Spira would be accelerated beyond the specified maximum speed, Spira's acceleration is reduced.
"""
func _accelerate_player_xy(delta: float, push_direction: Vector2, acceleration: float, max_speed: float) -> void:
	if push_direction.length() == 0:
		return

	var accel_vector := push_direction.normalized() * acceleration * delta
	
	var old_xy_velocity := _get_xy_velocity()
	var new_xy_velocity := old_xy_velocity + accel_vector
	if new_xy_velocity.length() > old_xy_velocity.length() and new_xy_velocity.length() > max_speed:
		new_xy_velocity = new_xy_velocity.normalized() * max_speed
	_set_xy_velocity(new_xy_velocity)


func _jump() -> void:
	# 'CoyoteTimer' and 'JumpBuffer' make jumping easier when active. They're disabled after a successful jump.
	$CoyoteTimer.stop()
	$JumpBuffer.stop()
	_velocity.y = JUMP_SPEED
	_jumping = true
	# change the movement animation to ensure the jump animation restarts even if we were already jumping
	play_movement_animation("idle")


"""
Returns 'true' if Spira is directly over something.

Most notably, this returns 'false' if Spira is standing on a surface, but the surface is not directly beneath her.
This enables the slipping logic.
"""
func over_something() -> bool:
	return $RayCast.is_colliding()


"""
When Spira attempts to jump onto a narrow surface (such as someone's head) she slips off unless she lands very
squarely in the middle of it.

This function triggers the slipping physics, and returns 'true' if Spira is slipping from a narrow surface.
"""
func _slip_from_narrow_surfaces(delta: float) -> bool:
	if not over_something():
		# character is not directly over anything; slipping should be handled by ledge slip logic
		return false

	var slip_direction := Vector3.ZERO
	var collider: Object = $RayCast.get_collider()
	if collider.get("foothold_radius"):
		# Spira is standing on something she might slip from
		slip_direction = translation - collider.translation
		slip_direction.y = 0
		if slip_direction.length() <= collider.foothold_radius:
			# Spira is close enough to the center and shouldn't slip
			slip_direction = Vector3.ZERO
	if slip_direction:
		_accelerate_player_xy(delta, Vector2(slip_direction.x, slip_direction.z),
				MAX_SLIP_ACCELERATION, MAX_NARROW_SLIP_SPEED)
	return slip_direction.length() > 0


"""
When Spira steps too close to a ledge, she slips off of the ledge.

This function triggers the slipping physics, and returns 'true' if Spira is slipping from a ledge. This occurs when
her center point is no longer above solid ground.

This function is important because Spira's collision shape is a box, but her sprite rarely fills the full box. Without
this logic she ends up hovering in space frequently.
"""
func _slip_from_ledges(delta: float) -> bool:
	if over_something():
		# don't slip; character is in mid-air, or squarely on the ground
		return false
	
	var slip_direction := Vector3.ZERO
	for i in range(LEDGE_RAY_COUNT):
		var ledge_direction := LEDGE_RAY_RADIUS * Vector3.RIGHT.rotated(Vector3.UP, TAU * i / LEDGE_RAY_COUNT)
		var ray_offset: Vector3 = $RayCast.global_transform.origin + ledge_direction
		if get_world().direct_space_state.intersect_ray( \
				$RayCast.translation + ray_offset, $RayCast.cast_to + ray_offset, [self]):
			slip_direction -= ledge_direction
	if slip_direction:
		_accelerate_player_xy(delta, Vector2(slip_direction.x, slip_direction.z),
				MAX_SLIP_ACCELERATION, MAX_LEDGE_SLIP_SPEED)
	return slip_direction.length() > 0


func _on_Customer_jumped() -> void:
	if _slipping:
		$HopSound.play()
	else:
		$JumpSound.play()
