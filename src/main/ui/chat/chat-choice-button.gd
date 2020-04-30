class_name ChatChoiceButton
extends Button
"""
Shows a button corresponding to a dialog branch the player can choose.
"""

# signal emitted after pop_choose() is invoked and the animation completes
signal pop_choose_completed

# Text to show the player. We cannot use the button's text property because it does not support multiline text.
export (String) var _choice_text: String setget set_choice_text

func _ready() -> void:
	$Label.text = _choice_text
	$Label.pick_largest_font()
	$MoodSprite/AnimationPlayer.advance(randf() * 2.5)
	_set_pivot_to_center()


"""
Sets the text corresponding to the dialog branch.

This is distinct from the button's 'text' property. We don't use the button's 'text' property because button text
cannot wrap.
"""
func set_choice_text(choice_text: String) -> void:
	_choice_text = choice_text
	if has_node("Label"):
		$Label.text = _choice_text
		$Label.pick_largest_font()


"""
Makes the chat choice appear.
"""
func pop_in() -> void:
	$PopTween.pop_in()


"""
Makes the chat choice disappear.
"""
func pop_out() -> void:
	$PopTween.pop_out()


"""
Called when this chat choice is chosen by the player. Animates it and makes it disappear.
"""
func pop_choose() -> void:
	$PopTween.remove_all()
	$PopAnimation.play("choose")
	$MoodSprite/AnimationPlayer.play("choose")


"""
Sets the mood corresponding to the chat choice.
"""
func set_mood(mood: int) -> void:
	$MoodSprite.set_mood(mood)


"""
Sets the location of the mood icon.
"""
func set_mood_right(mood_right: bool) -> void:
	$MoodSprite.set_mood_right(mood_right)


"""
Centers the pivot in the button's rectangle.
"""
func _set_pivot_to_center() -> void:
	rect_pivot_offset = rect_size * 0.5


"""
When the chat choice is focused, it animates more visibly. The MoodSprite also becomes more transparent so the player
can read the text behind it.
"""
func _on_focus_entered() -> void:
	$Label.set("custom_colors/font_color", Color.white)
	$MoodSprite/AnimationPlayer.play("focus")
	$MoodSprite/AnimationPlayer.advance(randf() * 2.5)


"""
When the chat choice is unfocused, its animations are subtler.
"""
func _on_focus_exited() -> void:
	$Label.set("custom_colors/font_color", Color("6c4331"))
	$MoodSprite/AnimationPlayer.play("default")
	$MoodSprite/AnimationPlayer.advance(randf() * 2.5)


func _on_resized() -> void:
	_set_pivot_to_center()


func _on_PopAnimation_animation_finished(anim_name: String) -> void:
	emit_signal("pop_choose_completed")
