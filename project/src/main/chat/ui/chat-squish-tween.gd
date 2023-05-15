extends Node
## Squishes the chat frame when the chat pops in or out.

var _tween: Tween

@onready var _chat_frame: Control = get_parent()

## Squishes the chat window aside to prompt the player.
func squish() -> void:
	_interpolate_squish(true)


## Moves the chat window back to the center after prompting the player.
func unsquish() -> void:
	_interpolate_squish(false)


## Squishes/unsquishes the chat window when prompting the player.
func _interpolate_squish(squished: bool) -> void:
	_tween = Utils.recreate_tween(self, _tween).set_parallel()
	_tween.tween_property(_chat_frame, "position:x", -100 if squished else 0, 0.2) \
			super.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
