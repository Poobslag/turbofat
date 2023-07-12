extends Node
## Squishes the chat frame when the chat pops in or out.

signal pop_out_completed

## size the chat shrinks to when it disappears
const POP_OUT_SCALE := Vector2(0.5, 0.5)

## applies scale/modulate effects
var _tween: SceneTreeTween

onready var _chat_frame: Control = get_parent()

func _ready() -> void:
	_reset_chat_frame()


## Makes the chat window appear.
##
## Enlarges the chat frame in a bouncy way and makes it opaque.
func pop_in() -> void:
	_interpolate_pop(true)


## Makes the chat window disappear.
##
## Shrinks the chat frame in a bouncy way and makes it transparent.
func pop_out() -> void:
	_interpolate_pop(false)


## Presets the chat window to a known invisible state.
##
## This doesn't use a tween. It's meant for setup/teardown steps the player should never see.
func _reset_chat_frame() -> void:
	_tween = Utils.kill_tween(_tween)
	_chat_frame.modulate = Color.transparent
	_chat_frame.rect_scale = POP_OUT_SCALE


## Pops the chat window in/out.
func _interpolate_pop(popping_in: bool) -> void:
	_tween = Utils.recreate_tween(self, _tween).set_parallel()
	
	var chat_frame_modulate := Color.white if popping_in else Color.transparent
	var chat_frame_scale := Vector2.ONE if popping_in else POP_OUT_SCALE
	
	_tween.tween_property(_chat_frame, "modulate",
			chat_frame_modulate, 0.2).set_trans(Tween.TRANS_LINEAR)
	_tween.tween_property(_chat_frame, "rect_scale:x",
			chat_frame_scale.x, 0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_chat_frame, "rect_scale:y",
			chat_frame_scale.y, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	if not popping_in:
		_tween.tween_callback(self, "_on_Tween_pop_out_finished").set_delay(0.2)


func _on_Tween_pop_out_finished() -> void:
	# The frame was popping out and is now invisible. Interrupt the tweens and fire a signal.
	_reset_chat_frame()
	emit_signal("pop_out_completed")
