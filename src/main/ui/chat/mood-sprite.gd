extends Control
"""
Shows a little 'happy face' icon next to each chat choice.
"""

# the location of the mood icon; the right or left side of the dialog window
export (bool) var _mood_right: bool setget set_mood_right

var textures := {
	ChatEvent.Mood.DEFAULT: preload("res://assets/ui/chat/choice-mood-default.png"),
	ChatEvent.Mood.SMILE0: preload("res://assets/ui/chat/choice-mood-smile0.png"),
	ChatEvent.Mood.SMILE1: preload("res://assets/ui/chat/choice-mood-smile1.png"),
	ChatEvent.Mood.LAUGH0: preload("res://assets/ui/chat/choice-mood-laugh0.png"),
	ChatEvent.Mood.LAUGH1: preload("res://assets/ui/chat/choice-mood-laugh1.png"),
	ChatEvent.Mood.THINK0: preload("res://assets/ui/chat/choice-mood-think0.png"),
	ChatEvent.Mood.THINK1: preload("res://assets/ui/chat/choice-mood-think1.png"),
	ChatEvent.Mood.CRY0: preload("res://assets/ui/chat/choice-mood-cry0.png"),
	ChatEvent.Mood.CRY1: preload("res://assets/ui/chat/choice-mood-cry1.png"),
	ChatEvent.Mood.SWEAT0: preload("res://assets/ui/chat/choice-mood-sweat0.png"),
	ChatEvent.Mood.SWEAT1: preload("res://assets/ui/chat/choice-mood-sweat1.png"),
	ChatEvent.Mood.RAGE0: preload("res://assets/ui/chat/choice-mood-rage0.png"),
	ChatEvent.Mood.RAGE1: preload("res://assets/ui/chat/choice-mood-rage1.png")
}


"""
Sets which mood should be displayed.

Parameters:
	'mood': An enum in ChatEvent.Mood corresponding to the mood to show. '-1' is a valid value, and will result in no
		mood being shown.
"""
func set_mood(mood: int) -> void:
	if textures.has(mood):
		$Texture.texture = textures[mood]
	else:
		$Texture.texture = null


"""
Sets the location of the mood icon.
"""
func set_mood_right(mood_right: bool) -> void:
	_mood_right = mood_right
	if _mood_right:
		$Texture.rect_rotation = 8
		anchor_left = 1
		anchor_right = 1
		margin_left = -18
		margin_top = 1 + randi() % 16
	else:
		$Texture.rect_rotation = -8
		anchor_left = 0
		anchor_right = 0
		margin_left = -11
		margin_top = 4 + randi() % 16
	margin_right = margin_left + 28
	margin_bottom = margin_top + 28
