class_name CreditsOrb
extends Sprite
## Orb which floats around the credits screen, launching puzzle pieces.
##
## The player can control the launched puzzle pieces with the direction/rotate buttons.
##
## This must be placed inside a container defining the orb's boundaries.

## Number of frames in our animation. Each frame launches a different puzzle piece.
const FRAME_COUNT := 8

## Rate at which to launch puzzle pieces. This is synchronized with the music track "Sugar Crash" for the end credits.
const PIECES_PER_SECOND := 4.10000

export (NodePath) var wallpaper_path: NodePath

## The loading orb rotates and moves. These fields are used to calculate the rotation/position.
var _total_time := 0.0
var _time_offset := 0.0

## Sequential pieces launch in different directions. This field influences the launch direction.
var _launched_piece_count := randi() % 4

## Most recent direction the player pressed.
var _pressed_dir := Vector2.ZERO
var _orientation: float

## The position the orb should be at when it is floating around over the credits.
var _onscreen_position: Vector2

## The position the orb should hide when it is hiding offscreen.
var _offscreen_position: Vector2

## A number from [0.0, 1.0] corresponding to whether the orb should be offscreen or onscreen.
var _offscreen_amount: float

var _tween: SceneTreeTween

onready var _wallpaper := get_node(wallpaper_path)

func _ready() -> void:
	# start offscreen
	_offscreen_position = Vector2(-500, 500)
	_offscreen_amount = 1.0
	modulate = Color.transparent
	
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


func initialize_time(time_offset: float) -> void:
	_total_time = 0.0
	_time_offset = time_offset


## Returns 'true' if the orb is more than halfway out of the credits area.
##
## The player can resize the window in very silly ways, so this might not literally be offscreen.
func is_offscreen() -> bool:
	return _offscreen_amount > 0.5


## Returns the number of times a piece should have been launched since the orb was created.
##
## The orb launches a piece at regular launch intervals, synced with music.
func elapsed_launch_intervals() -> int:
	return int(floor(PIECES_PER_SECOND * (_total_time + fmod(_time_offset, 1.0 / PIECES_PER_SECOND))))


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


## Moves the orb onscreen from the specified location, making it visible.
func show_onscreen(new_offscreen_position: Vector2) -> void:
	_offscreen_position = new_offscreen_position
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "_offscreen_amount", 0.0, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "modulate", _wallpaper.light_color.lightened(0.5), 1.0)


## Moves the orb offscreen from the specified location, making it transparent.
func hide_offscreen(new_offscreen_position: Vector2) -> void:
	_offscreen_position = new_offscreen_position
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "_offscreen_amount", 1.0, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "modulate", Color.transparent, 1.0).set_delay(2.0)


## Recalculates the orb's position, rotation and frame based on the elapsed time.
func _refresh() -> void:
	var time_with_offset := _total_time + _time_offset
	
	_onscreen_position = get_parent().rect_position + get_parent().rect_size * 0.5
	
	# The orb's path follows a small circle within a big circle like a spirograph
	_onscreen_position += Vector2(40 * sin(2.3 * time_with_offset), 40 * cos(2.3 * time_with_offset)) # small circle
	_onscreen_position += Vector2(120 * sin(0.8 * time_with_offset), -60 * cos(0.8 * time_with_offset)) # big circle
	
	position = lerp(_onscreen_position, _offscreen_position, _offscreen_amount)
	
	var wobble_amount := 0.09 + 0.06 * sin(0.97 * time_with_offset)
	rotation = PI * wobble_amount * sin(1.3 * time_with_offset) + _orientation
	
	var new_frame := int(time_with_offset * PIECES_PER_SECOND) % FRAME_COUNT
	if frame != new_frame:
		frame = new_frame
