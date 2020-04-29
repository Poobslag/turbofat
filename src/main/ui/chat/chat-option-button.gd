class_name ChatOptionButton
extends Button
"""
Shows a button corresponding to a dialog branch the player can choose.
"""

# Text to show the player. We don't use the button's 'text' property because button text cannot wrap.
export (String) var _choice_text: String setget set_choice_text

func _ready() -> void:
	$Label.text = _choice_text
	$MoodSprite/AnimationPlayer.advance(randf() * 2.5)


"""
Sets the text corresponding to the dialog branch.

This is distinct from the button's 'text' property. We don't use the button's 'text' property because button text
cannot wrap.
"""
func set_choice_text(choice_text: String) -> void:
	_choice_text = choice_text
	if has_node("Label"):
		$Label.text = _choice_text


"""
Sets the mood corresponding to the dialog branch.
"""
func set_mood(mood: int) -> void:
	$MoodSprite.set_mood(mood)


"""
Sets the location of the mood icon.
"""
func set_mood_right(mood_right: bool) -> void:
	$MoodSprite.set_mood_right(mood_right)


func _on_focus_entered() -> void:
	$Label.set("custom_colors/font_color", Color.white)
	$MoodSprite/AnimationPlayer.play("focus")
	$MoodSprite/AnimationPlayer.advance(randf() * 2.5)


func _on_focus_exited() -> void:
	$Label.set("custom_colors/font_color", Color("501910"))
	$MoodSprite/AnimationPlayer.play("default")
	$MoodSprite/AnimationPlayer.advance(randf() * 2.5)
