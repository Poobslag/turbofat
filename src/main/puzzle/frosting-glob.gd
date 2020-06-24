class_name FrostingGlob
extends Sprite
"""
A frosting glob which appears when the player clears a line or builds a box.
"""

# emitted when the glob collides with one of the four outer walls
signal hit_wall(glob)

# emitted when the glob smears against the playfield area behind the blocks
signal hit_playfield(glob)

# emitted when the glob smears against the next piece area
signal hit_next_pieces(glob)

# emitted when the glob smears against the gutter below the next piece area
signal hit_gutter(glob)

const MAX_INITIAL_VELOCITY := Vector2(600, -500)
const GRAVITY := 2400

# the area within the four outer walls
const WALLED_AREA := Rect2(364, 28, 388, 544)

# the playfield area behind the blocks
const PLAYFIELD_AREA := Rect2(364, 28, 324, 544)

const NEXT_PIECES_AREA := Rect2(688, 28, 64, 484)

# the gutter below the next piece area
const GUTTER_AREA := Rect2(688, 512, 64, 60)

# how long globs are visible while falling
const FALL_DURATION := 0.6

# how long it takes for globs to start fading after stuck to walls
const FADE_DELAY := 4.5

# how long it takes globs fade completely after stuck to walls
const FADE_DURATION := 1.5

# the duration when a glob should be recycled, even if it's somehow still visible
const MAX_AGE := 7.0

# the PuzzleTileMap food color index for this glob (brown, pink, bread, white, cake)
var color_int := -1

# remaining time in seconds before this glob will smear against the background
var smear_time := 0.0

# true if this glob is being affected by gravity
var falling := false

var velocity := Vector2.ZERO

# time in milliseconds between the engine starting and this node being initialized
var _creation_time := 0.0

func _ready() -> void:
	frame = randi() % (hframes * vframes)
	visible = false
	set_process(false)


"""
Populates this object from another FrostingGlob instance.

Note: While the 'glob' parameter should always be a FrostingGlob object, statically typing it as such causes errors at
game close due to Godot #30668 (https://github.com/godotengine/godot/issues/30668)

Parameters:
	'glob': The FrostingGlob instance to copy from.
"""
func copy_from(glob: Node) -> void:
	initialize(glob.color_int, glob.position)
	falling = glob.falling
	velocity = glob.velocity
	smear_time = glob.smear_time
	modulate = glob.modulate


"""
Returns the time in seconds since this glob was initialized.
"""
func get_age() -> float:
	return (OS.get_ticks_msec() - _creation_time) / 1000


func is_rainbow() -> bool:
	return PuzzleTileMap.is_cake_box(color_int)


"""
Resets this frosting glob's state, including its color and position, and adds it to the scene tree.
"""
func initialize(new_color_int: int, new_position: Vector2) -> void:
	_creation_time = OS.get_ticks_msec()
	visible = true
	color_int = new_color_int
	falling = true
	set_process(true)
	
	# calculate color, launch opacity tween
	if is_rainbow():
		modulate = Color.white
	elif PuzzleTileMap.is_snack_box(new_color_int):
		modulate = Playfield.FOOD_COLORS[new_color_int]
	
	position = new_position
	scale = Vector2(1, 1)
	rotation = 0
	velocity = Vector2.ZERO
	# add x velocity twice so that its distribution is more of a bell curve
	velocity.x += rand_range(-MAX_INITIAL_VELOCITY.x * 0.5, MAX_INITIAL_VELOCITY.x * 0.5)
	velocity.x += rand_range(-MAX_INITIAL_VELOCITY.x * 0.5, MAX_INITIAL_VELOCITY.x * 0.5)
	velocity.y = MAX_INITIAL_VELOCITY.y * rand_range(0.4, 1.0)
	
	scale = Vector2(0.25, 0.25)
	# randomly flip the sprite vertically/horizontally for variance
	if randf() > 0.5:
		scale *= Vector2(-1.0, 1.0)
	if randf() > 0.5:
		scale *= Vector2(1.0, -1.0)


"""
Makes this frosting glob fall and disappear.

Called when a frosting glob is first spawned.
"""
func fall() -> void:
	falling = true
	smear_time = min(rand_range(0.0, FALL_DURATION * 1.0), rand_range(0.0, FALL_DURATION * 1.5))
	
	$Tween.remove_all()
	$Tween.interpolate_property(self, "modulate", modulate, Utils.to_transparent(modulate), \
			FALL_DURATION * rand_range(0.8, 1.2), Tween.TRANS_CIRC, Tween.EASE_IN)
	$Tween.start()


"""
Makes this frosting glob fade away and disappear.

Called when a frosting glob hits a wall or smears against the background.
"""
func fade() -> void:
	falling = false
	$FadeTimer.start(FADE_DELAY * rand_range(0.8, 1.2))
	
	# No Tween.start() call; Tween is started once timer finishes
	$Tween.remove_all()
	$Tween.interpolate_property(self, "modulate", modulate, Utils.to_transparent(modulate), \
			FADE_DURATION * rand_range(0.8, 1.2), Tween.TRANS_LINEAR, Tween.EASE_IN)


"""
Move this frosting glob to a new location in the scene tree.

The same glob might be spawned in the playfield, but get splattered onto a wall which is a different node.
"""
func reparent(new_parent: Node) -> void:
	if new_parent == get_parent():
		return
	
	# removing a node from the tree unsets some flags; we store them so they can be restored
	var old_process := is_processing()
	var old_visible := visible
	
	if is_inside_tree():
		get_parent().remove_child(self)
	if new_parent:
		new_parent.add_child(self)
		set_process(old_process)
		visible = old_visible


"""
Applies gravity and checks for collisions.
"""
func _process(delta: float)  -> void:
	if not falling:
		return
	
	velocity.y += GRAVITY * delta
	position += velocity * delta
	
	if smear_time > 0.0:
		smear_time -= delta
		if smear_time <= 0.0:
			if PLAYFIELD_AREA.has_point(position):
				emit_signal("hit_playfield", self)
			elif NEXT_PIECES_AREA.has_point(position):
				emit_signal("hit_next_pieces", self)
			elif GUTTER_AREA.has_point(position):
				emit_signal("hit_gutter", self)
	
	if not WALLED_AREA.has_point(position):
		emit_signal("hit_wall", self)


func _on_Tween_tween_all_completed() -> void:
	hide()
	set_process(false)


func _on_FadeTimer_timeout() -> void:
	$Tween.start()
