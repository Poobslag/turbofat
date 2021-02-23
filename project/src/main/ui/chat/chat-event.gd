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

# The line of dialog
var text: String

# The behavior the chatter should perform while saying the text (laughing, sweating, etc)
var mood: int = Mood.NONE

# Metadata about the chat event, such as whether it should launch a level
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
	text = tr(json.get("text", ""))
	_parse_mood(json)
	_parse_links(json)
	_parse_meta(json)
	
	if json.has("who"):
		chat_theme_def = PlayerData.creature_library.get_creature_def(who).chat_theme_def
	else:
		# Dialog with no speaker; decorate it as a thought bubble
		if text:
			text = "(%s)" % text
		chat_theme_def = PlayerData.creature_library.get_creature_def(CreatureLibrary.PLAYER_ID).chat_theme_def


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
		push_error("Invalid json type: %s" % typeof(parsed_meta))


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
		"": mood = Mood.NONE
		"default": mood = Mood.DEFAULT
		"awkward0": mood = Mood.AWKWARD0
		"awkward1": mood = Mood.AWKWARD1
		"cry0": mood = Mood.CRY0
		"cry1": mood = Mood.CRY1
		"laugh0": mood = Mood.LAUGH0
		"laugh1": mood = Mood.LAUGH1
		"love0": mood = Mood.LOVE0
		"love1": mood = Mood.LOVE1
		"no0": mood = Mood.NO0
		"no1": mood = Mood.NO1
		"rage0": mood = Mood.RAGE0
		"rage1": mood = Mood.RAGE1
		"rage2": mood = Mood.RAGE2
		"sigh0": mood = Mood.SIGH0
		"sigh1": mood = Mood.SIGH1
		"smile0": mood = Mood.SMILE0
		"smile1": mood = Mood.SMILE1
		"sweat0": mood = Mood.SWEAT0
		"sweat1": mood = Mood.SWEAT1
		"think0": mood = Mood.THINK0
		"think1": mood = Mood.THINK1
		"wave0": mood = Mood.WAVE0
		"wave1": mood = Mood.WAVE1
		"yes0": mood = Mood.YES0
		"yes1": mood = Mood.YES1
		_:
			push_warning("Unrecognized mood: %s" % json.get("mood", ""))
			mood = Mood.NONE


func _to_string() -> String:
	return ("%s:%s" % [who, text]) if who else text
