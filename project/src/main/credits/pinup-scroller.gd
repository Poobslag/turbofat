class_name PinupScroller
extends Node2D
## A pinup which scrolls vertically during the credits.

## which side of the screen the pinup appears on
enum Side {
	LEFT,
	RIGHT
}

const SIDE_LEFT := Side.LEFT
const SIDE_RIGHT := Side.RIGHT
const FADE_DURATION := 0.5

## Height in units. Used for calculating the scroll speed.
export (float) var line_height: float

var velocity := Vector2(0, -50)
var _tween: SceneTreeTween

onready var pinup := $Pinup

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	position += velocity * delta
	
	if global_position.y < -100.0:
		stop()


## Hides the pinup and stops it from moving.
func stop() -> void:
	visible = false
	set_physics_process(false)


## Shows the pinup and starts it moving.
func start() -> void:
	visible = true
	
	modulate = Color.transparent
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "modulate", Color.white, FADE_DURATION)
	
	set_physics_process(true)
