class_name ChatEvent
"""
Contains details for a line of spoken text shown to the player.
"""

enum Mood {
	NONE, # no particular mood
	DEFAULT, # neutral expression, neither positive nor negative
	SMILE0, # smiling a little
	SMILE1, # smiling a lot
	LAUGH0, # laughing a little
	LAUGH1, # laughing a lot
	THINK0, # pensive
	THINK1, # confused
	CRY0, # a little sad
	CRY1, # crying their eyes out
	SWEAT0, # a little nervous
	SWEAT1, # incredibly anxious
	RAGE0, # a little upset
	RAGE1 # infuriated
}

# The name of the person speaking, or blank if nobody is speaking
var who := ""

# The line of dialog
var text: String

# The behavior the chatter should perform while saying the text (laughing, sweating, etc)
var mood: int = Mood.NONE

# List of string keys corresponding to branches off of this chat event.
var links: Array

# List of dialog strings corresponding to branches off of this chat event.
var link_texts: Array

"""
The chat window changes its appearance based on who's talking. For example, one character's speech might be blue with
a black background, and giant blue soccer balls in the background. The 'accent_def' property defines the chat window's
appearance, such as 'blue', 'soccer balls' and 'giant'.

'accent_def/accent_scale': The scale of the accent's background texture
'accent_def/accent_swapped': If 'true', the accent's foreground/background colors will be swapped
'accent_def/accent_texture': A number in the range [0, 15] referring to a background texture
'accent_def/color': The color of the chat window
'accent_def/dark': True/false for whether the sentence window's background should be black/white
"""
var accent_def: Dictionary

"""
Populates this object from a dictionary. This is useful when loading event data from json.
"""
func from_dict(json: Dictionary) -> void:
	text = json["text"]
	who = json.get("who", "")
	mood = _mood(json.get("mood", ""))
	var json_links: Array = json.get("links", [])
	accent_def = InteractableManager.get_accent_def(who)
	
	links.clear()
	link_texts.clear()
	if json_links:
		for json_link in json_links:
			if typeof(json_link) == TYPE_DICTIONARY:
				links.append(json_link.keys()[0])
				link_texts.append(json_link.values()[0])
			elif typeof(json_link) == TYPE_STRING:
				links.append(json_link)
				link_texts.append(json_link)
			else:
				push_error("Invalid json link: " % json_link)
	
	if not json.has("who"):
		# Dialog with no speaker; decorate it as a thought bubble
		text = "(%s)" % text
		accent_def = InteractableManager.get_accent_def("Turbo")


"""
Parses a json mood string into an enum.
"""
func _mood(s: String) -> int:
	var m: int
	match s:
		"default": m = Mood.DEFAULT
		"smile0": m = Mood.SMILE0
		"smile1": m = Mood.SMILE1
		"laugh0": m = Mood.LAUGH0
		"laugh1": m = Mood.LAUGH1
		"think0": m = Mood.THINK0
		"think1": m = Mood.THINK1
		"cry0": m = Mood.CRY0
		"cry1": m = Mood.CRY1
		"sweat0": m = Mood.SWEAT0
		"sweat1": m = Mood.SWEAT1
		"rage0": m = Mood.RAGE0
		"rage1": m = Mood.RAGE1
		_: m = Mood.NONE
	return m


func _to_string() -> String:
	return ("%s:%s" % [who, text]) if who else text
