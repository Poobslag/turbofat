class_name LeafPoof
extends Sprite2D
## Leaf poof spawned when the player clears a row containing vegetables.

## duration the leaf poof remains visible.
const LIFETIME := 1.5

## leaf animations alternate between two frames; leaf_frame is always 0 or 1
var leaf_frame: int: set = set_leaf_frame

## leaf_type controls which pair of frames are selected from the sprite sheet
var leaf_type: int

## turns the leaf invisible
@onready var _tween: Tween

## animates and flips the leaf
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# The leaf is invisible and disabled from processing until initialized
	visible = false
	set_physics_process(false)
	_update_tween_and_animation()


## Makes the leaf poof visible and enables its physics processing.
##
## The leaf poof appears at the specified location, falls and sways back and forth, fades out and disables itself.
func initialize(init_leaf_type: int, init_position: Vector2) -> void:
	visible = true
	modulate = Color.WHITE
	set_physics_process(true)
	position = init_position
	leaf_type = init_leaf_type
	
	_refresh_frame()
	_update_tween_and_animation()


func set_leaf_frame(new_leaf_frame: int) -> void:
	leaf_frame = new_leaf_frame
	_refresh_frame()


func _update_tween_and_animation() -> void:
	if not is_inside_tree():
		return
	
	_animation_player.advance(randf() * 10)
	_tween = Utils.recreate_tween(self, _tween).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate", Utils.to_transparent(modulate), LIFETIME)
	_tween.tween_callback(Callable(self, "queue_free"))


func _refresh_frame() -> void:
	frame = 2 * leaf_type + leaf_frame


func _physics_process(delta: float) -> void:
	# sway left and right based on the animation state
	var velocity := Vector2(180 if leaf_frame == 0 else 90, 80)
	velocity.x *= -1 if flip_h else 1
	position += delta * velocity
