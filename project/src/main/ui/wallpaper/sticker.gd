class_name Sticker
extends Sprite
"""
An image which scrolls by on the wallpaper.
"""

# The unmodified scale/rotation before pulsing/spinning
var base_scale := Vector2(1.0, 1.0) setget set_base_scale
var base_rotation := 0.0 setget set_base_rotation

# Stickers pulse and rotate. This field is used to calculate the pulse/rotation amount
var _total_time := 0.0

# How much the sticker should grow and shrink; 1.0 = grow from 0% to 200%
onready var _rescale_amount := 0.04 * rand_range(0.8, 1.2)

# How many seconds the sticker should take to grow and shrink once
onready var _rescale_period := 4.50 * rand_range(0.8, 1.2)

# How far the sticker should rotate; 1.0 = one full circle forward and backward
onready var _spin_amount := 0.04 * rand_range(0.8, 1.2)

# How many seconds the sticker should take to rotate back and forth once
onready var _spin_period := 4.50 * rand_range(0.8, 1.2)

func _ready() -> void:
	# ensure the scale and spin period aren't too similar
	if abs(_spin_period - _rescale_period) < 0.2:
		_spin_period += 0.5
	
	# randomly increment the total time so items don't spin/pulse in sync
	_total_time += rand_range(0, _spin_period)
	_refresh_scale()
	_refresh_rotation()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_total_time += delta
	_refresh_scale()
	_refresh_rotation()


func set_base_scale(new_base_scale: Vector2) -> void:
	base_scale = new_base_scale
	_refresh_scale()


func set_base_rotation(new_base_rotation: float) -> void:
	base_rotation = new_base_rotation
	_refresh_rotation()


func _refresh_scale() -> void:
	if not is_inside_tree():
		return
	var scale_modifier := _rescale_amount * sin(_total_time * TAU / _rescale_period)
	scale = base_scale + base_scale * scale_modifier


func _refresh_rotation() -> void:
	if not is_inside_tree():
		return
	var rotation_modifier := _spin_amount * PI * sin(_total_time * TAU / _spin_period)
	rotation = base_rotation + rotation_modifier


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if not Engine.is_editor_hint():
		queue_free()
