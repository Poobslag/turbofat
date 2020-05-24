extends Tween
"""
Squishes the tutorial message frame when the chat pops in or out.
"""

signal pop_out_completed

# the size the chat shrinks to when it disappears
const POP_OUT_SCALE := Vector2(0.5, 0.5)

onready var _message := get_parent()

func _ready() -> void:
	_reset_message()

"""
Makes the window appear.

Enlarges the chat frame in a bouncy way and makes it opaque.
"""
func pop_in() -> void:
	_message.visible = true
	_interpolate_pop(true)


"""
Makes the window disappear.

Shrinks the chat frame in a bouncy way and makes it transparent.
"""
func pop_out() -> void:
	_interpolate_pop(false)


"""
Presets the window to a known invisible state.

This doesn't use a tween. It's meant for setup/teardown steps the player should never see.
"""
func _reset_message() -> void:
	remove_all()
	_message.modulate = Color.transparent
	_message.rect_scale = POP_OUT_SCALE


"""
Pops the chat window in/out.
"""
func _interpolate_pop(popping_in: bool) -> void:
	remove_all()
	var message_modulate := Color.white if popping_in else Color.transparent
	var message_scale := Vector2(1.0, 1.0) if popping_in else POP_OUT_SCALE
	
	interpolate_property(_message, "modulate", _message.modulate,
			message_modulate, 0.2, Tween.TRANS_LINEAR)
	interpolate_property(_message, "rect_scale:x", _message.rect_scale.x,
			message_scale.x, 0.8, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	interpolate_property(_message, "rect_scale:y", _message.rect_scale.y,
			message_scale.y, 0.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	start()


func _on_tween_completed(object: Object, key: NodePath) -> void:
	if object == _message and key.get_concatenated_subnames() == "modulate" \
			and _message.modulate == Color.transparent:
		# The frame was popping out and is now invisible. Interrupt the tweens and fire a signal.
		_reset_message()
		emit_signal("pop_out_completed")
