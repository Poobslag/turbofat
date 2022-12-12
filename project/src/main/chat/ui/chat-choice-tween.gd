extends Tween
## Tweens pop-in/pop-out effects for chat choices.

## the size the chat shrinks to when it disappears
const POP_OUT_SCALE := Vector2(0.5, 0.5)

onready var _chat_choice := get_parent()

func _ready() -> void:
	_reset_chat_choice()


## Makes the chat choice appear.
##
## Enlarges the chat choice in a bouncy way and makes it opaque.
func pop_in() -> void:
	# All container controls in Godot reset the scale of their children to their own scale. If we don't reassign the
	# scale before launching the tween then the rect_scale property won't be interpolated.
	_chat_choice.rect_scale = POP_OUT_SCALE
	
	_interpolate_pop(true)


## Makes the chat choice disappear.
##
## Shrinks the chat choice in a bouncy way and makes it transparent.
func pop_out() -> void:
	_interpolate_pop(false)


## Pops the chat choice in/out.
func _interpolate_pop(popping_in: bool) -> void:
	remove(_chat_choice, "modulate")
	remove(_chat_choice, "rect_scale:x")
	remove(_chat_choice, "rect_scale:y")
	
	var chat_choice_modulate := Color.white if popping_in else Color.transparent
	var chat_choice_scale := Vector2.ONE if popping_in else POP_OUT_SCALE
	
	interpolate_property(_chat_choice, "modulate", _chat_choice.modulate,
			chat_choice_modulate, 0.1, Tween.TRANS_LINEAR)
	interpolate_property(_chat_choice, "rect_scale:x", _chat_choice.rect_scale.x,
			chat_choice_scale.x, 0.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	interpolate_property(_chat_choice, "rect_scale:y", _chat_choice.rect_scale.y,
			chat_choice_scale.y, 0.2, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	start()


## Presets the chat choice to a known invisible state.
##
## This doesn't use a tween. It's meant for setup/teardown steps the player should never see.
func _reset_chat_choice() -> void:
	remove_all()
	_chat_choice.modulate = Color.transparent
	_chat_choice.rect_scale = POP_OUT_SCALE
