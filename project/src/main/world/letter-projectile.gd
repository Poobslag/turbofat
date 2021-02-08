class_name LetterProjectile
extends Node2D
"""
A letter emitted when a creature talks.
"""

# How fast the letter should move
const BASE_SPEED := 92.0

# Letters to cycle through when spawning projectiles.
# These spell out Turbofat in Katakana, sort of (ta-ru-bo-ha-to)
const LETTERS := ["タ", "ル", "ボ", "フ", "ト"]

# How fast the letter should move relative to the base speed. 1.0 = 100% speed. 0.0 = 0% speed.
export (float) var speed_scale := 1.0

# The direction the letter should move, in radians
var angle := 0.0

var speed := BASE_SPEED

"""
Initializes the letter's text, position and angle.

A small amount of noise is applied to the position and angle so that the letters don't move in a perfectly uniform
manner.

Parameters:
	'init_index': The letter's index. Used to cycle its appearance and behavior.
	
	'init_position': The approximate position where the letter should spawn.
	
	'init_angle': The approximate direction the letter should move, in radians
"""
func initialize(init_index: int, init_position: Vector2, init_angle: float) -> void:
	position = init_position + Vector2(rand_range(-4.0, 4.0), rand_range(-4.0, 4.0))
	angle = init_angle + rand_range(0.04, 0.10) * (1.0 if init_index % 2 == 0 else -1.0)
	speed = BASE_SPEED * rand_range(0.92, 1.08)
	$Letter.text = LETTERS[init_index % LETTERS.size()]


func _physics_process(delta: float) -> void:
	position += Vector2(speed * speed_scale, 0).rotated(angle) * delta
