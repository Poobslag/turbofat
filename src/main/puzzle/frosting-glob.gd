class_name FrostingGlob
extends Sprite
"""
A frosting glob which appears when the player clears a line or makes a box.
"""


# how long the frosting globs are visible
const DURATION := 0.6

const MAX_INITIAL_VELOCITY := Vector2(600, -500)

const GRAVITY := 2400

var velocity := Vector2.ZERO

func _ready() -> void:
	frame = randi() % (hframes * vframes)
	visible = false
	set_process(false)


"""
Resets this frosting glob's state, including its color and position.
"""
func initialize(color: Color, new_position: Vector2) -> void:
	visible = true
	set_process(true)
	
	modulate = color
	$Tween.remove_all()
	$Tween.interpolate_property(self, "modulate", color, Global.to_transparent(color), \
			DURATION, Tween.TRANS_CIRC, Tween.EASE_IN)
	$Tween.start()
	
	position = new_position
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



func _process(delta: float)  -> void:
	velocity.y += GRAVITY * delta
	position += velocity * delta


func _on_Tween_tween_all_completed() -> void:
	visible = false
	set_process(false)
