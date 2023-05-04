extends Control
## Shows a little 'happy face' icon next to each chat choice.

## location of the mood icon; the right or left side of the chat window
@export var mood_right: bool: set = set_mood_right

var textures := {
	Creatures.Mood.DEFAULT: preload("res://assets/main/chat/ui/choice-mood-default.png"),
	Creatures.Mood.AWKWARD0: preload("res://assets/main/chat/ui/choice-mood-awkward0.png"),
	Creatures.Mood.AWKWARD1: preload("res://assets/main/chat/ui/choice-mood-awkward1.png"),
	Creatures.Mood.CRY0: preload("res://assets/main/chat/ui/choice-mood-cry0.png"),
	Creatures.Mood.CRY1: preload("res://assets/main/chat/ui/choice-mood-cry1.png"),
	Creatures.Mood.LAUGH0: preload("res://assets/main/chat/ui/choice-mood-laugh0.png"),
	Creatures.Mood.LAUGH1: preload("res://assets/main/chat/ui/choice-mood-laugh1.png"),
	Creatures.Mood.LOVE0: preload("res://assets/main/chat/ui/choice-mood-love0.png"),
	Creatures.Mood.LOVE1: preload("res://assets/main/chat/ui/choice-mood-love1.png"),
	Creatures.Mood.LOVE1_FOREVER: preload("res://assets/main/chat/ui/choice-mood-love1.png"),
	Creatures.Mood.NO0: preload("res://assets/main/chat/ui/choice-mood-no.png"),
	Creatures.Mood.NO1: preload("res://assets/main/chat/ui/choice-mood-no.png"),
	Creatures.Mood.RAGE0: preload("res://assets/main/chat/ui/choice-mood-rage0.png"),
	Creatures.Mood.RAGE1: preload("res://assets/main/chat/ui/choice-mood-rage1.png"),
	Creatures.Mood.RAGE2: preload("res://assets/main/chat/ui/choice-mood-rage2.png"),
	Creatures.Mood.SIGH0: preload("res://assets/main/chat/ui/choice-mood-sigh0.png"),
	Creatures.Mood.SIGH1: preload("res://assets/main/chat/ui/choice-mood-sigh1.png"),
	Creatures.Mood.SLY0: preload("res://assets/main/chat/ui/choice-mood-sly0.png"),
	Creatures.Mood.SLY1: preload("res://assets/main/chat/ui/choice-mood-sly1.png"),
	Creatures.Mood.SMILE0: preload("res://assets/main/chat/ui/choice-mood-smile0.png"),
	Creatures.Mood.SMILE1: preload("res://assets/main/chat/ui/choice-mood-smile1.png"),
	Creatures.Mood.SWEAT0: preload("res://assets/main/chat/ui/choice-mood-sweat0.png"),
	Creatures.Mood.SWEAT1: preload("res://assets/main/chat/ui/choice-mood-sweat1.png"),
	Creatures.Mood.THINK0: preload("res://assets/main/chat/ui/choice-mood-think0.png"),
	Creatures.Mood.THINK1: preload("res://assets/main/chat/ui/choice-mood-think1.png"),
	Creatures.Mood.WAVE0: preload("res://assets/main/chat/ui/choice-mood-default.png"),
	Creatures.Mood.WAVE1: preload("res://assets/main/chat/ui/choice-mood-smile0.png"),
	Creatures.Mood.WAVE2: preload("res://assets/main/chat/ui/choice-mood-smile0.png"),
	Creatures.Mood.YES0: preload("res://assets/main/chat/ui/choice-mood-yes.png"),
	Creatures.Mood.YES1: preload("res://assets/main/chat/ui/choice-mood-yes.png"),
}


## Sets which mood should be displayed.
##
## Parameters:
## 	'mood': Enum from Creatures.Mood corresponding to the mood to show. '-1' is a valid value, and will result in no
## 		mood being shown.
func set_mood(new_mood: Creatures.Mood) -> void:
	if textures.has(new_mood):
		$Texture2D.texture = textures[new_mood]
	else:
		$Texture2D.texture = null


## Sets the location of the mood icon.
func set_mood_right(new_mood_right: bool) -> void:
	mood_right = new_mood_right
	if mood_right:
		$Texture2D.rotation = 8
		anchor_left = 1
		anchor_right = 1
		offset_left = -18
		offset_top = 1 + randi() % 16
	else:
		$Texture2D.rotation = -8
		anchor_left = 0
		anchor_right = 0
		offset_left = -11
		offset_top = 4 + randi() % 16
	offset_right = offset_left + 28
	offset_bottom = offset_top + 28
