tool
class_name CreditsLetter
extends Node2D
## A bubbly block letter which replaces the "Turbo Fat" header in the credits.
##
## When the letter spawns, it immediately animates itself with particles and a squash/stretch effect.

## The average amount the letter should wobble back and forth when idle.
const ROTATION_AMOUNT := 8.0

## The amount of time it takes the letter to wobble back and forth when idle.
const ROTATION_PERIOD := 3.33

const PARTICLE_COLORS_BY_FRAME := [
	Color("ff636d"), # T (V-Block)
	Color("ffb474"), # u (U-Block)
	Color("ffef7d"), # r (L-Block)
	Color("94ff82"), # b (Q-Block)
	Color("82fffb"), # o (O-Block)
	Color("82baff"), # f (J-Block)
	Color("b182ff"), # a (P-Block)
	Color("ff7afb"), # t (T-Block)
]

export (int, 0, 7) var piece_index: int = 0 setget set_piece_index

## Handles the letter's ongoing wobble animation
var _spin_tween: SceneTreeTween

## Handles the letter's initial squash and stretch animation
onready var _animation_player: AnimationPlayer = $AnimationPlayer

onready var _sprite: Sprite = $Sprite
onready var _particles: Particles2D = $Particles

func _ready() -> void:
	_refresh_piece_index()
	_particles.emitting = true
	_animation_player.play("pop-in")
	
	# launch the letter's ongoing wobble animation
	if not Engine.editor_hint:
		_spin_tween = create_tween()
		_spin_tween.set_loops()
		var rotation_amount := ROTATION_AMOUNT * rand_range(0.8, 1.2)
		rotation_amount *= -1 if randf() < 0.5 else 1
		var rotation_period := ROTATION_PERIOD * rand_range(0.8, 1.2)
		_spin_tween.tween_property(_sprite, "rotation_degrees",
				rotation_amount * 0.5, rotation_period * 0.5) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_spin_tween.tween_property(_sprite, "rotation_degrees",
				rotation_amount * -0.5, rotation_period * 0.5) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_initialize_onready_variables()


func set_piece_index(new_piece_index: int) -> void:
	piece_index = new_piece_index
	_refresh_piece_index()


## Preemptively initializes onready variables to avoid null references.
func _initialize_onready_variables() -> void:
	_animation_player = $AnimationPlayer
	_particles = $Particles


## Updates our visuals based on the piece_index.
func _refresh_piece_index() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint:
		if not _particles:
			_initialize_onready_variables()
	
	_sprite.frame = piece_index
	_particles.modulate = PARTICLE_COLORS_BY_FRAME[piece_index]
