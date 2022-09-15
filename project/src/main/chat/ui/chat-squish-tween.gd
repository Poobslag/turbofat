extends Tween
## Squishes the chat frame when the chat pops in or out.

onready var _chat_frame: Control = get_parent()

## Squishes the chat window aside to prompt the player.
func squish() -> void:
	_interpolate_squish(true)
	start()


## Moves the chat window back to the center after prompting the player.
func unsquish() -> void:
	_interpolate_squish(false)
	start()


## Squishes/unsquishes the chat window when prompting the player.
func _interpolate_squish(squished: bool) -> void:
	remove(_chat_frame, "rect_position:x")
	interpolate_property(_chat_frame, "rect_position:x", _chat_frame.rect_position.x,
			-100 if squished else 0, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
