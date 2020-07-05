tool
class_name FoodItem
extends PackedSprite
"""
A food item which appears when the player clears a box in puzzle mode.
"""

# Scale/rotation modifiers applied by our animation
export (Vector2) var scale_modifier := Vector2(1.0, 1.0)
export (float) var rotation_modifier := 0.0

# The unmodified scale/rotation before pulsing/spinning
var base_scale := Vector2(1.0, 1.0) setget set_base_scale
var base_rotation := 0.0 setget set_base_rotation

# Food items pulse and rotate. This field is used to calculate the pulse/rotation amount
var _total_time := 0.0

# How far the sprite should rotate; 1.0 = one full circle forward and backward
onready var _spin_amount := 0.08 * rand_range(0.8, 1.2)

# How many seconds the sprite should take to rotate back and forth once
onready var _spin_period := 2.50 * rand_range(0.8, 1.2)

func _ready() -> void:
	# randomly increment the total time so items don't spin/pulse in sync
	_total_time += rand_range(0, _spin_period)
	_refresh_scale()
	_refresh_rotation()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_total_time += delta
	position.y -= 25 * delta
	_refresh_scale()
	_refresh_rotation()


func set_base_scale(new_base_scale: Vector2) -> void:
	base_scale = new_base_scale
	_refresh_scale()


func set_base_rotation(new_base_rotation: float) -> void:
	base_rotation = new_base_rotation
	_refresh_rotation()


func _refresh_scale() -> void:
	scale = base_scale * scale_modifier


func _refresh_rotation() -> void:
	rotation_modifier = _spin_amount * PI * sin(_total_time * TAU / _spin_period)
	rotation = base_rotation + rotation_modifier


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if not Engine.is_editor_hint():
		queue_free()
