extends KinematicBody
"""
The 3D object representing 'Turbo', the player-controlled character who moves around the overworld.
"""

# Number from [0.0, 1.0] which determines how quickly Turbo slows down
const FRICTION := 0.15

# How fast can Turbo move
const MAX_RUN_SPEED := 6

# How fast can Turbo slip
const MAX_SLIP_SPEED := 9

# How fast Turbo slips off of slippery platforms
const MAX_SLIP_ACCELERATION := 220

# How fast can Turbo accelerate
const MAX_RUN_ACCELERATION := 150

# How slow can Turbo move before she stops
const MIN_RUN_SPEED := 4

# How fast does gravity accelerate Turbo
const GRAVITY := 40.0

# Vertical force applied to Turbo when she jumps
const JUMP_SPEED := 16

# Turbo's (X, Y, Z) velocity
var _velocity := Vector3(0, 0, 0)

# 'true' if the controls should be rotated 45 degrees, giving the player orthographic controls.
# 'false' if the controls should not be rotated, giving the player isometric controls.
var _rotate_controls := true

# 'true' if Turbo is currently mid-air after having jumped
var _jumping := false

# 'true' if Turbo is either slipping, or mid-air after having slipped
var _slipping := false

func _physics_process(delta):
	var was_on_floor = is_on_floor()
	
	_apply_friction()
	_apply_gravity(delta)
	_apply_player_input(delta)

	move_and_slide(_velocity, Vector3.UP)
	
	_slide_from_narrow_surfaces(delta)

	if is_on_floor():
		if (Input.is_action_pressed("jump") or not $JumpBuffer.is_stopped()) and not _slipping:
			jump()
		else:
			_jumping = false
	
	if is_on_floor() and not _jumping:
		# the character visibly jitters between y values of [1.06, 1.10] if we do not smooth the value
		translation.y = stepify(translation.y, 0.2)
		
	if not is_on_floor() and was_on_floor and not _jumping and not _slipping:
		$CoyoteTimer.start()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
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
		var xy_velocity: Vector2 = lerp(_get_xy_velocity(), Vector2(0, 0), FRICTION)
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
		# Turbo is slipping; all input is ignored
		return

	if $CoyoteTimer.is_stopped() and not is_on_floor():
		# Turbo is in mid-air; no movement allowed in mid-air
		pass
	else:
		# calculate the direction the player wants to move
		var player_input := Vector2(0, 0)
		if Input.is_action_pressed("ui_left"):
			player_input += Vector2.LEFT
		if Input.is_action_pressed("ui_right"):
			player_input += Vector2.RIGHT
		if Input.is_action_pressed("ui_up"):
			player_input += Vector2.UP
		if Input.is_action_pressed("ui_down"):
			player_input += Vector2.DOWN
		if _rotate_controls:
			player_input = player_input.rotated(-PI / 4)
		
		# move Turbo towards the direction the player wants to move
		accelerate_player_xy(delta, player_input, MAX_RUN_ACCELERATION, MAX_RUN_SPEED)
	
	
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


"""
When Turbo attempts to jump onto a narrow surface, she slides off unless she lands very squarely in the middle of it.
"""
func _slide_from_narrow_surfaces(delta: float) -> void:
	var was_slipping := _slipping
	if is_on_floor():
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
						_slipping = true
						just_slipped = true
						accelerate_player_xy(delta, Vector2(slip_velocity.x, slip_velocity.z), MAX_SLIP_ACCELERATION, MAX_SLIP_SPEED)
						$CoyoteTimer.stop()
						$JumpBuffer.stop()
		
		if _slipping and not just_slipped:
			# Turbo was slipping, but they've landed on something non-slippery.
			_slipping = false
