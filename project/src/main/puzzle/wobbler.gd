class_name Wobbler
extends Sprite
"""
Sprite which wobbles and pulses.
"""

# How far the sprite should rotate; 1.0 = one full circle forward and backward
export (float) var avg_spin_amount := 0.5

# How many seconds the sprite should take to rotate back and forth once
export (float) var avg_spin_period := 3.0

# How far the sprite should shrink; 0.21 = shrink down to 79% scale
export (float) var avg_pulse_amount := 0.2

# How many seconds the sprite should take to shrink to minimum/maximum scale
export (float) var avg_pulse_period := 3.0

# Slightly randomize inputs so each object is slightly unique
onready var _spin_amount := avg_spin_amount * rand_range(0.8, 1.2)
onready var _spin_period := avg_spin_period * rand_range(0.8, 1.2)
onready var _pulse_amount := avg_pulse_amount * rand_range(0.8, 1.2)
onready var _pulse_period := avg_pulse_period * rand_range(0.8, 1.2)

# The unmodified scale/rotation before pulsing/spinning
var base_scale := Vector2(1.0, 1.0) setget set_base_scale
var base_rotation := 0.0 setget set_base_rotation

# Stars/seeds pulse and rotate. This field is used to calculate the pulse/rotation amount
var _total_time := 0.0

func _ready() -> void:
	frame = randi() % (hframes * vframes)
	# randomly increment the total time so items don't spin/pulse in sync
	_total_time += rand_range(0, _spin_period * _pulse_period)
	_refresh_scale()
	_refresh_rotation()


func _physics_process(delta: float) -> void:
	_total_time += delta
	_refresh_scale()
	_refresh_rotation()


func set_base_scale(new_base_scale: Vector2) -> void:
	base_scale = new_base_scale
	if is_inside_tree():
		_refresh_scale()


func set_base_rotation(new_base_rotation: float) -> void:
	base_rotation = new_base_rotation
	if is_inside_tree():
		_refresh_rotation()


func _refresh_scale() -> void:
	scale = base_scale * (1 - _pulse_amount * (0.5 + 0.5 * sin(_total_time * TAU / _pulse_period)))


func _refresh_rotation() -> void:
	rotation = base_rotation + _spin_amount * PI * sin(_total_time * TAU / _spin_period)
