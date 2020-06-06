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

# Metadata about the chat event, such as whether it should launch a scenario
var meta: Array

# List of string keys corresponding to branches off of this chat event.
var links: Array

# List of dialog strings corresponding to branches off of this chat event.
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

func from_json_dict(json: Dictionary) -> void:
	who = json.get("who", "")
	text = json.get("text", "")
	_parse_mood(json)
	_parse_links(json)
	_parse_meta(json)
	
	if json.has("who"):
		chat_theme_def = ChattableManager.get_chat_theme_def(who)
	else:
		# Dialog with no speaker; decorate it as a thought bubble
		text = "(%s)" % text
		chat_theme_def = ChattableManager.get_chat_theme_def("Spira")


"""
Stores the contents of the json 'meta' field into our meta property as a string array.
"""
func _parse_meta(json: Dictionary) -> void:
	var parsed_meta = json.get("meta", [])
	if typeof(parsed_meta) == TYPE_STRING:
		meta = [parsed_meta]
	elif typeof(parsed_meta) == TYPE_ARRAY:
		meta = parsed_meta
	else:
		push_error("Invalid json type: " % typeof(parsed_meta))


"""
Stores the json links into our link/link_texts properties as string arrays.
"""
func _parse_links(json: Dictionary) -> void:
	links.clear()
	link_texts.clear()
	var json_links: Array = json.get("links", [])
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


"""
Stores the json mood string into our mood property as an enum.
"""
func _parse_mood(json: Dictionary) -> void:
	match json.get("mood", ""):
		"default": mood = Mood.DEFAULT
		"smile0": mood = Mood.SMILE0
		"smile1": mood = Mood.SMILE1
		"laugh0": mood = Mood.LAUGH0
		"laugh1": mood = Mood.LAUGH1
		"think0": mood = Mood.THINK0
		"think1": mood = Mood.THINK1
		"cry0": mood = Mood.CRY0
		"cry1": mood = Mood.CRY1
		"sweat0": mood = Mood.SWEAT0
		"sweat1": mood = Mood.SWEAT1
		"rage0": mood = Mood.RAGE0
		"rage1": mood = Mood.RAGE1
		_: mood = Mood.NONE


func _to_string() -> String:
	return ("%s:%s" % [who, text]) if who else text
