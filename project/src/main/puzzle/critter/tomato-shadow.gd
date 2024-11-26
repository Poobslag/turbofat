class_name TomatoShadow
extends Sprite
## Shadow which appears behind tomatoes, obscuring a playfield row with a dark red glow.

## States the shadow goes through when showing/hiding
enum State {
	NONE,
	SHOWING,
	HIDING,
}

## Duration in seconds for the 'fade in' animation.
const FADE_IN_DURATION := 0.50

## Duration in seconds for the 'fade out' animation.
##
## Should be shorter than the CritterPoof animation duration, otherwise the shadow sprite will be freed before its
## animation completes.
const FADE_OUT_DURATION := 0.25

## Duration in seconds for the 'fade in/fade out' loop animation.
const LOOP_DURATION := 5.0

var _state: int = State.NONE
var _tween: SceneTreeTween

func _ready() -> void:
	visible = false


## Makes the shadow visible and starts its animation.
func start() -> void:
	if _state == State.SHOWING:
		return
	
	_state = State.SHOWING
	
	if not visible:
		visible = true
		modulate = Utils.to_transparent(Color("630000"), 0.0)
	
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "modulate", Utils.to_transparent(Color("630000"), 0.6), FADE_IN_DURATION)
	_tween.tween_callback(self, "_schedule_looped_tween")


## Starts the 'fade in/fade out' loop animation.
func _schedule_looped_tween() -> void:
	_tween = Utils.recreate_tween(self, _tween)
	_tween.set_loops()
	_tween.tween_property(self, "modulate", Utils.to_transparent(Color("630000"), 0.3), LOOP_DURATION / 2) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "modulate", Utils.to_transparent(Color("630000"), 0.6), LOOP_DURATION / 2) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Makes the shadow invisible and stops its animation.
func stop() -> void:
	if _state in [State.HIDING, State.NONE]:
		return
	
	_state = State.HIDING
	
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "modulate", Utils.to_transparent(Color("630000"), 0.0), FADE_OUT_DURATION)
	_tween.tween_callback(self, "set", ["visible", false])
