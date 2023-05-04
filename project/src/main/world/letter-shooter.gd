class_name LetterShooter
extends Node
## Emits letters from a particular position and direction.

## scene describing the letters to emit
@export var LetterProjectileScene: PackedScene

## Approximate direction the letter should move, in radians.
##
## Note: PI and TAU are not supported in export ranges, see Godot-Proposals #1147
## (https://github.com/godotengine/godot-proposals/issues/1147)
@export_range(-6.28318530717959, 6.28318530717959) var letter_angle := 0.0

## Approximate position where the letter should spawn.
@export var letter_position: Vector2

## Next letter's index. Used to cycle the letter's appearance and behavior.
var _letter_index := 0

func _ready() -> void:
	$ShootTimer.timeout.connect(_on_ShootTimer_timeout)


## Start emitting letters.
##
## Letters will emit continuously until stop() is called.
func start() -> void:
	$ShootTimer.start()


## Stop emitting letters.
func stop() -> void:
	$ShootTimer.stop()


## Returns 'true' if this LetterShooter is not currently emitting letters.
func is_stopped() -> bool:
	return $ShootTimer.is_stopped()


## Emit a new letter.
func _on_ShootTimer_timeout() -> void:
	var letter_projectile: LetterProjectile = LetterProjectileScene.instantiate()
	letter_projectile.initialize(_letter_index, letter_position, letter_angle)
	add_child(letter_projectile)
	
	# increment the letter index; wrap it to avoid an overflow error
	_letter_index = (_letter_index + 1) % 1000000000
