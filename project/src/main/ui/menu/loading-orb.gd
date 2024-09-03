class_name LoadingOrb
extends Sprite
## Orb which floats around the loading screen, launching puzzle pieces.
##
## The player can control the launched puzzle pieces with the direction/rotate buttons.

## Number of frames in our animation. Each frame launches a different puzzle piece.
const FRAME_COUNT := 8

## Rate at which to launch puzzle pieces. This is synchronized with the music track "Sugar Crash" for the end credits.
const PIECES_PER_SECOND := 4.10000

## The loading orb rotates and moves. This field is used to calculate the rotation/position
var _total_time := 0.0

## Sequential pieces launch in different directions. This field influences the launch direction.
var _launched_piece_count := randi() % 4

## Most recent direction the player pressed.
var _pressed_dir := Vector2.ZERO
var _orientation: float

func _ready() -> void:
	# initialize total_time so the wobble/position isn't always the same
	_total_time = rand_range(0, 100)
	
	if randf() < 0.5:
		# 50% of the time, the pieces are oriented to spell out 'T' 'u' 'r' 'b' 'o'...
		_orientation = 0.0
	else:
		# 50% of the time, their orientation is randomized
		_orientation = Utils.rand_value([0.0 * PI, 0.5 * PI, 1.0 * PI, 1.5 * PI])
	
	if randf() < 0.5:
		# 50% of the time, the pieces are ordered with the 'T' piece first.
		frame = 0
	else:
		# 50% of the time, their order is random
		frame = randi() % FRAME_COUNT
	
	_refresh()


## The player can control the direction/orientation of launched puzzle pieces with the rotate buttons.
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# If the player presses one or more directions, the pieces are launched in different directions.
		var new_pressed_dir := Utils.ui_pressed_dir()
		if new_pressed_dir != Vector2.ZERO:
			_pressed_dir = new_pressed_dir
		
		# If the player presses one or more rotate keys, the orb rotates.
		if event.is_action_pressed("rotate_cw") or event.is_action_pressed("rotate_ccw"):
			var should_rotate_cw := event.is_action_pressed("rotate_cw")
			
			# The player can press both rotate buttons to flip the orb, just like in the game.
			if Input.is_action_pressed("rotate_cw") and Input.is_action_pressed("rotate_ccw"):
				should_rotate_cw = not should_rotate_cw
			
			_orientation = fmod(_orientation + (PI / 2 if should_rotate_cw else -PI / 2), 2 * PI)


func _process(delta: float) -> void:
	_total_time += delta
	
	_refresh()


## Calculates the direction to launch the piece.
##
## If the orb is currently launching pieces in clockwise order, this also advances to the next sequential direction.
func pop_launch_dir() -> Vector2:
	var launch_dir: Vector2 = _pressed_dir
	if launch_dir == Vector2.ZERO:
		# launch pieces in a clockwise order
		launch_dir = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT][_launched_piece_count % 4]
	
	_launched_piece_count += 1
	return launch_dir


## Recalculates the orb's position, rotation and frame based on the elapsed time.
func _refresh() -> void:
	position = Global.window_size * 0.5
	
	# The orb's path follows a small circle within a big circle like a spirograph
	position += Vector2(40 * sin(2.3 * _total_time), 40 * cos(2.3 * _total_time)) # small circle
	position += Vector2(120 * sin(0.8 * _total_time), -60 * cos(0.8 * _total_time)) # big circle
	
	var wobble_amount := 0.09 + 0.06 * sin(0.97 * _total_time)
	rotation = PI * wobble_amount * sin(1.3 * _total_time) + _orientation
	
	var new_frame := int(_total_time * PIECES_PER_SECOND) % FRAME_COUNT
	if frame != new_frame:
		frame = new_frame
