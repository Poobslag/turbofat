class_name LetterShooter
extends Node
## Emits letters from a particular position and direction.

## the scene describing the letters to emit
export (PackedScene) var LetterProjectileScene: PackedScene

## The approximate direction the letter should move, in radians
export (float) var letter_angle := 0.0

## The approximate position where the letter should spawn.
export (Vector2) var letter_position: Vector2

## The next letter's index. Used to cycle the letter's appearance and behavior.
var _letter_index := 0

func _ready() -> void:
	$ShootTimer.connect("timeout", self, "_on_ShootTimer_timeout")


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
	var letter_projectile: LetterProjectile = LetterProjectileScene.instance()
	letter_projectile.initialize(_letter_index, letter_position, letter_angle)
	add_child(letter_projectile)
	
	# increment the letter index; wrap it to avoid an overflow error
	_letter_index = (_letter_index + 1) % 1000000000
