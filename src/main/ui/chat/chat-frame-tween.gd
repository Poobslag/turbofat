extends Tween
"""
Squishes the chat frame when the chat pops in or out.
"""

signal pop_out_completed

# the size the chat shrinks to when it disappears
const POP_OUT_SCALE := Vector2(0.5, 0.5)

onready var _chat_frame: Control = get_parent()
onready var _sentence_sprite := $"../SentenceSprite"
onready var _sentence_label := $"../SentenceLabel"

func _ready() -> void:
	_reset_chat_frame()

"""
Makes the chat window appear.

Enlarges the chat frame in a bouncy way and makes it opaque.
"""
func pop_in() -> void:
	_interpolate_pop(true)


"""
Makes the chat window disappear.

Shrinks the chat frame in a bouncy way and makes it transparent.
"""
func pop_out() -> void:
	_interpolate_pop(false)


"""
Squishes the chat window aside to prompt the player.
"""
func squish() -> void:
	_interpolate_squish(true)
	start()


"""
Moves the chat window back to the center after prompting the player.
"""
func unsquish() -> void:
	_interpolate_squish(false)
	start()


"""
Presets the chat window to a known invisible state.

This doesn't use a tween. It's meant for setup/teardown steps the player should never see.
"""
func _reset_chat_frame() -> void:
	remove_all()
	_chat_frame.modulate = Color.transparent
	_chat_frame.rect_scale = POP_OUT_SCALE


"""
Squishes/unsquishes the chat window when prompting the player.
"""
func _interpolate_squish(squished: bool) -> void:
	remove(_chat_frame, "rect_position:x")
	interpolate_property(_chat_frame, "rect_position:x", _chat_frame.rect_position.x,
			-100 if squished else 0, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)


"""
Pops the chat window in/out.
"""
func _interpolate_pop(popping_in: bool) -> void:
	remove(_chat_frame, "modulate")
	remove(_chat_frame, "rect_scale:x")
	remove(_chat_frame, "rect_scale:y")
	
	var chat_frame_modulate := Color.white if popping_in else Color.transparent
	var chat_frame_scale := Vector2(1.0, 1.0) if popping_in else POP_OUT_SCALE
	
	interpolate_property(_chat_frame, "modulate", _chat_frame.modulate,
			chat_frame_modulate, 0.2, Tween.TRANS_LINEAR)
	interpolate_property(_chat_frame, "rect_scale:x", _chat_frame.rect_scale.x,
			chat_frame_scale.x, 0.8, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	interpolate_property(_chat_frame, "rect_scale:y", _chat_frame.rect_scale.y,
			chat_frame_scale.y, 0.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	start()


func _on_tween_completed(object: Object, key: NodePath) -> void:
	if object == _chat_frame and key.get_concatenated_subnames() == "modulate" \
			and _chat_frame.modulate == Color.transparent:
		# The frame was popping out and is now invisible. Interrupt the tweens and fire a signal.
		_reset_chat_frame()
		emit_signal("pop_out_completed")
