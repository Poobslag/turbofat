class_name ChatEvent
"""
Contains details for a line of spoken text shown to the player.
"""

enum Mood {
	NONE,
	DEFAULT, # neutral expression, neither positive nor negative
	AWKWARD0, # apprehensive
	AWKWARD1, # visibly uncomfortable
	CRY0, # a little sad
	CRY1, # crying their eyes out
	LAUGH0, # laughing a little
	LAUGH1, # laughing a lot
	LOVE0, # finding something cute
	LOVE1, # fawning over something
	NO0, # shaking their head once
	NO1, # shaking their head a few times
	RAGE0, # annoyed
	RAGE1, # a little upset
	RAGE2, # infuriated
	SIGH0, # unamused
	SIGH1, # exasperated
	SMILE0, # smiling a little
	SMILE1, # smiling a lot
	SWEAT0, # a little nervous
	SWEAT1, # incredibly anxious
	THINK0, # pensive
	THINK1, # confused
	WAVE0, # casual greeting (or pointing)
	WAVE1, # enthusiastic greeting
	YES0, # nodding once
	YES1, # nodding a few times
}

# The name of the person speaking, or blank if nobody is speaking
var who := ""

# The chat line
var text: String

# The behavior the chatter should perform while saying the text (laughing, sweating, etc)
var mood: int = Mood.NONE

# Metadata about the chat event, such as whether it should launch a level
var meta: Array

# List of string keys corresponding to branches off of this chat event.
var links: Array

# List of chat strings corresponding to branches off of this chat event.
var link_texts: Array

"""
The chat window changes its appearance based on who's talking. For example, one character's speech might be blue with
a black background, and giant blue soccer balls in the background. The 'chat_theme_def' property defines the chat
window's appearance, such as 'blue', 'soccer balls' and 'giant'.

'chat_theme_def/accent_scale': The scale of the accent's background texture
'chat_theme_def/accent_swapped': If 'true', the accent's foreground/background colors will be swapped
'chat_theme_def/accent_texture': A number in the range [0, 15] referring to a background texture
'chat_theme_def/color': The color of the chat window
'chat_theme_def/dark': True/false for whether the chat line window's background should be black/white
"""
var chat_theme_def: Dictionary

func add_link(link: String, link_text: String) -> void:
	links.append(link)
	link_texts.append(link_text)


func _to_string() -> String:
	return ("%s:%s" % [who, text]) if who else text
