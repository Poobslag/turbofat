class_name PinupScroller
extends Node2D
## A pinup which scrolls vertically during the credits.

enum ScrollerState {
	VISIBLE,
	FADING_IN,
	FADING_OUT,
	INVISIBLE,
}

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

## tracks whether the pinup is currently fading in or out
var state: int = ScrollerState.VISIBLE

var velocity := Vector2(0, -50)
var _tween: SceneTreeTween

onready var pinup := $Pinup

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	position += velocity * delta
	
	if position.y < -100.0 and state in [ScrollerState.FADING_IN, ScrollerState.VISIBLE]:
		stop()


## Immediately hides the pinup and stops it from moving.
func reset() -> void:
	state = ScrollerState.INVISIBLE
	visible = false
	set_physics_process(false)


## Fades the pinup out and stops it from moving.
func stop() -> void:
	state = ScrollerState.FADING_OUT
	visible = true
	set_physics_process(true)
	
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "modulate", Color.transparent, FADE_DURATION)
	_tween.tween_callback(self, "set", ["state", ScrollerState.INVISIBLE])
	_tween.tween_callback(self, "set", ["visible", false])
	_tween.tween_callback(self, "set_physics_process", [false])


## Fades the pinup in and starts it moving.
func start() -> void:
	state = ScrollerState.FADING_IN
	visible = true
	set_physics_process(true)
	
	pinup.reset()
	modulate = Color.transparent
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "modulate", Color.white, FADE_DURATION)
	_tween.tween_callback(self, "set", ["state", ScrollerState.VISIBLE])
