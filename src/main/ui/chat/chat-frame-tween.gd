extends Tween
"""
Squishes the chat frame when the chat pops in or out.
"""

signal pop_out_completed

# the size the chat shrinks to when it disappears
const POP_OUT_SCALE := Vector2(0.5, 0.5)

# either 'pop_in' or 'pop_out', depending on which function was called more recently
var _previous_tween_action: String

onready var _chat_frame := get_parent()

func _ready() -> void:
	_reset_chat_frame()

"""
Makes the chat window appear.

Enlarges the chat frame in a bouncy way and makes it opaque.
"""
func pop_in() -> void:
	remove_all()
	_previous_tween_action = "pop_in"
	interpolate_property(_chat_frame, "modulate", _chat_frame.modulate,
			Color.white, 0.2, Tween.TRANS_LINEAR)
	interpolate_property(_chat_frame, "rect_scale:x", _chat_frame.rect_scale.x,
			1.0, 0.8, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	interpolate_property(_chat_frame, "rect_scale:y", _chat_frame.rect_scale.y,
			1.0, 0.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	start()


"""
Makes the chat window disappear.

Shrinks the chat frame in a bouncy way and makes it transparent.
"""
func pop_out() -> void:
	remove_all()
	_previous_tween_action = "pop_out"
	interpolate_property(_chat_frame, "modulate", _chat_frame.modulate,
			Color.transparent, 0.2, Tween.TRANS_LINEAR)
	interpolate_property(_chat_frame, "rect_scale:x", _chat_frame.rect_scale.x,
			POP_OUT_SCALE.x, 0.8, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	interpolate_property(_chat_frame, "rect_scale:y", _chat_frame.rect_scale.y,
			POP_OUT_SCALE.y, 0.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	start()


"""
Presets the chat window to a known invisible state.

This doesn't use a tween. It's meant for setup/teardown steps the player should never see.
"""
func _reset_chat_frame() -> void:
	remove_all()
	_chat_frame.modulate = Color.transparent
	_chat_frame.rect_scale = POP_OUT_SCALE


func _on_tween_completed(object: Object, key: NodePath) -> void:
	if _previous_tween_action == "pop_out" and key.get_concatenated_subnames() == "modulate":
		# Tweening the :modulate property renders the chat frame invisible before the tween finishes. Once the chat
		# frame is invisible, we immediately interrupt the tween and fire a signal.
		_reset_chat_frame()
		emit_signal("pop_out_completed")
