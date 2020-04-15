extends Customer3D
"""
Script for manipulating the player-controlled character 'Turbo' in the 3D overworld.
"""

# Number from [0.0, 1.0] which determines how quickly Turbo slows down
const FRICTION := 0.15

# How fast can Turbo move
const MAX_RUN_SPEED := 60

# How fast can Turbo slip
const MAX_NARROW_SLIP_SPEED := 90

# How fast can Turbo slip
const MAX_LEDGE_SLIP_SPEED := 40

# How fast Turbo slips off of slippery platforms
const MAX_SLIP_ACCELERATION := 2200

# How fast can Turbo accelerate
const MAX_RUN_ACCELERATION := 1500

# How slow can Turbo move before she stops
const MIN_RUN_SPEED := 40

# How fast does gravity accelerate Turbo
const GRAVITY := 400.0

# Vertical force applied to Turbo when she jumps
const JUMP_SPEED := 160

# Default position of camera relative to Turbo. The camera is above and in front.
const DEFAULT_CAMERA_TRANSLATION := Vector3(300, 250, 300)

# How far the camera should lead Turbo's movement when Turbo is walking/jumping
const CAMERA_LEAD_DISTANCE := 60

# Number from [0.0, 1.0] for how tight the camera should snap to Turbo's movement
const CAMERA_JERKINESS := 0.04

# How many rays we should cast when determining how Turbo falls from a ledge
const LEDGE_RAY_COUNT := 16

# How far apart the rays should be when determining how Turbo falls from a ledge
const LEDGE_RAY_RADIUS := 12.0

# Turbo's (X, Y, Z) velocity
var _velocity := Vector3.ZERO

# 'true' if the controls should be rotated 45 degrees, giving the player orthographic controls.
# 'false' if the controls should not be rotated, giving the player isometric controls.
var _rotate_controls := true

# 'true' if Turbo is currently mid-air after having jumped
var _jumping := false

# 'true' if Turbo is either slipping, or mid-air after having slipped
var _slipping := false

# The direction Turbo is walking in (X, Y) coordinates, where 'Y' is forward.
var _walk_direction := Vector2.ZERO

func _ready() -> void:
	._ready()
	$CollisionShape.disabled = false

func _physics_process(delta):
	var was_on_floor = is_on_floor()
	
	_apply_friction()
	_apply_gravity(delta)
	_apply_player_input(delta)
	_update_animation()
	_update_camera_target()
	
	move_and_slide(_velocity, Vector3.UP)
	
	if is_on_floor():
		var did_slip := _slip_from_narrow_surfaces(delta)
		if not did_slip:
			did_slip = _slip_from_ledges(delta)
		_slipping = did_slip
	
	if is_on_floor():
		if (Input.is_action_pressed("jump") or not $JumpBuffer.is_stopped()) and not _slipping:
			jump()
		else:
			_jumping = false
	
	if not is_on_floor() and was_on_floor and not _jumping and not _slipping:
		$CoyoteTimer.start()


"""
Turbo is dark red with black eyes.
"""
func get_customer_definition() -> Dictionary:
	return {
		"line_rgb": "6c4331", "body_rgb": "b23823", "eye_rgb": "282828 dedede", "horn_rgb": "f1e398",
		"ear": "0", "horn": "1", "mouth": "1", "eye": "0"
	}


func _update_animation():
	if _slipping:
		play_movement_animation("jump", _get_xy_velocity())
	elif _jumping:
		play_movement_animation("jump", _walk_direction)
	elif _walk_direction.length() > 0:
		play_movement_animation("run", _walk_direction)
	else:
		play_movement_animation("idle", _walk_direction)


func _update_camera_target():
	var new_translation := DEFAULT_CAMERA_TRANSLATION \
			+ Vector3(_walk_direction.x, 0, _walk_direction.y) * CAMERA_LEAD_DISTANCE
	$CameraTarget.translation = lerp($CameraTarget.translation, new_translation, CAMERA_JERKINESS)


func _apply_gravity(delta: float) -> void:
	if is_on_floor() and not _jumping:
		_velocity.y = 0
	_velocity += Vector3.DOWN * GRAVITY * delta


func _apply_friction() -> void:
	if Input.is_action_pressed("ui_left") \
		or Input.is_action_pressed("ui_right") \
		or Input.is_action_pressed("ui_up") \
		or Input.is_action_pressed("ui_down"):
		# Turbo is currently running; no friction when they're running
		pass
	elif $CoyoteTimer.is_stopped() and not is_on_floor():
		# Turbo is in mid-air; no friction in mid-air
		pass
	elif _slipping:
		# Turbo is slipping; no friction when slipping
		pass
	else:
		# apply friction
		var xy_velocity: Vector2 = lerp(_get_xy_velocity(), Vector2.ZERO, FRICTION)
		if xy_velocity.length() < MIN_RUN_SPEED:
			xy_velocity = Vector2()
		_set_xy_velocity(xy_velocity)


"""
Gets Turbo's (X, Y, Z) velocity where 'Y' is up as an (X, Y) movement vector where 'Y' is forward.
"""
func _get_xy_velocity() -> Vector2:
	return Vector2(_velocity.x, _velocity.z)


"""
Sets Turbo's (X, Y, Z) velocity where 'Y' is up from an (X, Y) movement vector where 'Y' is forward.
"""
func _set_xy_velocity(xy_velocity: Vector2):
	_velocity.x = xy_velocity.x
	_velocity.z = xy_velocity.y


"""
Applies Turbo's jump/movement input for most cases. Some edge cases such as buffered jumps are handled outside this
function.
"""
func _apply_player_input(delta: float) -> void:
	if _slipping:
		_walk_direction = Vector2.ZERO
		return

	if $CoyoteTimer.is_stopped() and not is_on_floor():
		# Turbo is in mid-air; no movement allowed in mid-air
		pass
	else:
		_walk_direction = Vector2.ZERO
		# calculate the direction the player wants to move
		if Input.is_action_pressed("ui_left"):
			_walk_direction += Vector2.LEFT
		if Input.is_action_pressed("ui_right"):
			_walk_direction += Vector2.RIGHT
		if Input.is_action_pressed("ui_up"):
			_walk_direction += Vector2.UP
		if Input.is_action_pressed("ui_down"):
			_walk_direction += Vector2.DOWN
		if _rotate_controls:
			_walk_direction = _walk_direction.rotated(-PI / 4)
		# move Turbo towards the direction the player wants to move
		accelerate_player_xy(delta, _walk_direction, MAX_RUN_ACCELERATION, MAX_RUN_SPEED)
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not $CoyoteTimer.is_stopped():
			jump()
		else:
			$JumpBuffer.start()


"""
Accelerates Turbo horizontally.

If Turbo would be accelerated beyond the specified maximum speed, Turbo's acceleration is reduced.
"""
func accelerate_player_xy(delta: float, push_direction: Vector2, acceleration: float, max_speed: float):
	var accel_vector = push_direction * acceleration
	if accel_vector.length() > acceleration:
		accel_vector = accel_vector.normalized() * acceleration
	
	var old_xy_velocity := _get_xy_velocity()
	var old_xy_speed := old_xy_velocity.length()
	var xy_velocity = old_xy_velocity + accel_vector
	if xy_velocity.length() > old_xy_speed and xy_velocity.length() > max_speed:
		xy_velocity = xy_velocity.normalized() * max_speed
	_set_xy_velocity(xy_velocity)
	
	_velocity.x += accel_vector.x * delta
	_velocity.z += accel_vector.y * delta


func jump() -> void:
	# 'CoyoteTimer' and 'JumpBuffer' make jumping easier when active. They're disabled after a successful jump.
	$CoyoteTimer.stop()
	$JumpBuffer.stop()
	_velocity.y = JUMP_SPEED
	_jumping = true
	# change the movement animation to ensure the jump animation restarts even if we were already jumping
	play_movement_animation("idle")


"""
When Turbo attempts to jump onto a narrow surface (such as someone's head) she slips off unless she lands very
squarely in the middle of it.

This function triggers the slipping physics, and returns 'true' if Turbo is slipping from a narrow surface.
"""
func _slip_from_narrow_surfaces(delta: float) -> bool:
	var just_slipped = false
	if get_slide_count() > 0:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.get("foothold_radius") and translation.y > collision.collider.translation.y + 0.2:
				# Turbo is standing on something she might slip from
				var slip_velocity: Vector3 = translation - collision.collider.translation
				slip_velocity.y = 0
				if slip_velocity.length() > collision.collider.foothold_radius:
					# Turbo is too far from the center, and should slip
					just_slipped = true
					accelerate_player_xy(delta, Vector2(slip_velocity.x, slip_velocity.z), MAX_SLIP_ACCELERATION, MAX_NARROW_SLIP_SPEED)
	return just_slipped


"""
When Turbo steps too close to a ledge, she slips off of the ledge.

This function triggers the slipping physics, and returns 'true' if Turbo is slipping from a ledge. This occurs when
her center point is no longer above solid ground.

This function is important because Turbo's collision shape is a box, but her sprite rarely fills the full box. Without
this logic she ends up hovering in space frequently.
"""
func _slip_from_ledges(delta: float) -> bool:
	if $RayCast.is_colliding():
		# don't slip; character is sitting squarely on the ground
		return false
	
	var slip_direction = Vector3.ZERO
	for i in range(LEDGE_RAY_COUNT):
		var ledge_direction: Vector3 = (Vector3.RIGHT * LEDGE_RAY_RADIUS).rotated(Vector3.UP, 2 * PI * i / LEDGE_RAY_COUNT)
		var ray_offset: Vector3 = $RayCast.global_transform.origin + ledge_direction
		if get_world().direct_space_state.intersect_ray( \
				$RayCast.translation + ray_offset, $RayCast.cast_to + ray_offset, [self]):
			slip_direction -= ledge_direction
	if slip_direction:
		accelerate_player_xy(delta, Vector2(slip_direction.x, slip_direction.z), MAX_SLIP_ACCELERATION, MAX_LEDGE_SLIP_SPEED)
	return slip_direction.length() > 0
