class_name GoopGlob
extends Sprite
## Goop glob which appears when the player clears a line or builds a box.

## emitted when the glob collides with one of the four outer walls
signal hit_wall(glob)

## emitted when the glob smears against the playfield area behind the blocks
signal hit_playfield(glob)

## emitted when the glob smears against the next piece area
signal hit_next_pieces(glob)

const MAX_INITIAL_VELOCITY := Vector2(600, -500)
const GRAVITY := 2400

## how long globs are visible while falling
const FALL_DURATION := 0.6

## how long it takes for globs to start fading after stuck to walls
const FADE_DELAY := 4.5

## how long it takes globs fade completely after stuck to walls
const FADE_DURATION := 1.5

## duration when a glob should be recycled, even if it's somehow still visible
const MAX_AGE := 7.0

var puzzle_areas: PuzzleAreas

## PuzzleTileMap food color index for this glob (brown, pink, bread, white, cake)
var box_type := -1

## remaining time in seconds before this glob will smear against the background
var smear_time := 0.0

## true if this glob is being affected by gravity
var falling := false

var velocity := Vector2.ZERO

## time in milliseconds between the engine starting and this node being initialized
var _creation_time := 0.0

var _tween: SceneTreeTween

onready var _fade_timer: Timer = $FadeTimer

## Populates this object from another GoopGlob instance.
##
## Parameters:
## 	'glob': The GoopGlob instance to copy from.
func copy_from(glob: GoopGlob) -> void:
	initialize(glob.box_type, glob.position)
	puzzle_areas = glob.puzzle_areas
	falling = glob.falling
	velocity = glob.velocity
	smear_time = glob.smear_time
	modulate = glob.modulate


## Returns the time in seconds since this glob was initialized.
func get_age() -> float:
	return (Time.get_ticks_msec() - _creation_time) / 1000


func is_rainbow() -> bool:
	return Foods.is_cake_box(box_type)


## Resets this goop glob's state, including its color and position.
func initialize(new_box_type: int, new_position: Vector2) -> void:
	_creation_time = Time.get_ticks_msec()
	box_type = new_box_type
	falling = true
	set_process(true)
	
	# calculate color, launch opacity tween
	if is_rainbow():
		modulate = Color.white
	elif Foods.is_snack_box(new_box_type):
		modulate = Foods.COLORS_ALL[new_box_type]
	
	position = new_position
	scale = Vector2.ONE
	rotation = 0
	velocity = Vector2.ZERO
	# add x velocity twice so that its distribution is more of a bell curve
	velocity.x += rand_range(-MAX_INITIAL_VELOCITY.x * 0.5, MAX_INITIAL_VELOCITY.x * 0.5)
	velocity.x += rand_range(-MAX_INITIAL_VELOCITY.x * 0.5, MAX_INITIAL_VELOCITY.x * 0.5)
	velocity.y = MAX_INITIAL_VELOCITY.y * rand_range(0.4, 1.0)
	
	scale = Vector2(0.25, 0.25)
	# randomly flip the sprite vertically/horizontally for variance
	if randf() < 0.5:
		scale *= Vector2(-1.0, 1.0)
	if randf() < 0.5:
		scale *= Vector2(1.0, -1.0)


## Makes this goop glob fall and disappear.
##
## Called when a goop glob is first spawned.
func fall() -> void:
	falling = true
	smear_time = min(rand_range(0.0, FALL_DURATION * 0.7), rand_range(0.0, FALL_DURATION * 1.2))
	
	_tween = Utils.recreate_tween(self, _tween).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate", Utils.to_transparent(modulate), FALL_DURATION * rand_range(0.8, 1.2))
	_tween.tween_callback(self, "queue_free")


## Makes this goop glob fade away and disappear.
##
## Called when a goop glob hits a wall or smears against the background.
func fade() -> void:
	falling = false
	_fade_timer.start(FADE_DELAY * rand_range(0.8, 1.2))


## Applies gravity and checks for collisions.
func _process(delta: float) -> void:
	if not falling:
		return
	
	velocity.y += GRAVITY * delta
	position += velocity * delta
	
	if smear_time > 0.0:
		smear_time -= delta
		if smear_time <= 0.0:
			if puzzle_areas.playfield_area.has_point(position):
				emit_signal("hit_playfield", self)
			elif puzzle_areas.next_pieces_area.has_point(position):
				emit_signal("hit_next_pieces", self)
	
	if not puzzle_areas.walled_area.has_point(position):
		emit_signal("hit_wall", self)


func _on_FadeTimer_timeout() -> void:
	_tween = Utils.recreate_tween(self, _tween).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate", Utils.to_transparent(modulate), \
			FADE_DURATION * rand_range(0.8, 1.2))
	_tween.tween_callback(self, "queue_free")
