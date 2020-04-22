class_name ChatLibrary
"""
Loads dialog from files.

Dialog is stored as a set of json resources. This class parses those json resources and into ChatEvents so they can be
fed into the UI.
"""

# Chat appearance for different characters
var _accent_defs: Dictionary = {
	"Bort": {"accent_scale":1.3,"accent_swapped":false,"accent_texture":0,"color":"6f83db"},
	"Ebe": {"accent_scale":0.87,"accent_swapped":true,"accent_texture":15,"color":"b47922"},
	"Turbo": {"accent_scale":0.66,"accent_swapped":true,"accent_texture":13,"color":"b23823"}
}

"""
Loads the chat events for the currently focused interactable.

Returns an array of ChatEvent objects for the dialog sequence which the player should see.
"""
func load_chat_events() -> Array:
	var chat_events := []
	var chat_id: String = InteractableManager.get_focused().get_meta("chat_id")
	if not chat_id:
		# can't look up chat events without a chat_id; return an empty array
		push_warning("Interactable %s does not define a 'chat_id' property." % InteractableManager.get_focused())
	else:
		# open the json file for the currently focused interactable
		var file := File.new()
		file.open("res://assets/dialog/%s.json" % chat_id, File.READ)
		var json_items: Array = parse_json(file.get_as_text())
		for json_item in json_items:
			# convert the json items into ChatEvents
			chat_events.append(_parse_chat_event(json_item))
	return chat_events


"""
Converts a json item into a ChatEvent.
"""
func _parse_chat_event(json_item: Dictionary) -> ChatEvent:
	var chat_event := ChatEvent.new()
	if json_item.has("who"):
		# Ordinary dialog spoken by someone; decorate it appropriately
		chat_event.name = json_item["who"]
		chat_event.text = json_item["text"]
		if _accent_defs.has(chat_event.name):
			chat_event.accent_def = _accent_defs.get(chat_event.name)
	else:
		# Dialog with no speaker; decorate it as a thought bubble
		chat_event.name = ""
		chat_event.text = "(%s)" % json_item["text"]
		chat_event.accent_def = _accent_defs.get("Turbo")
	
	match json_item.get("mood"):
		"default": chat_event.mood = ChatEvent.Mood.DEFAULT
		"smile0": chat_event.mood = ChatEvent.Mood.SMILE0
		"smile1": chat_event.mood = ChatEvent.Mood.SMILE1
		"laugh0": chat_event.mood = ChatEvent.Mood.LAUGH0
		"laugh1": chat_event.mood = ChatEvent.Mood.LAUGH1
		"think0": chat_event.mood = ChatEvent.Mood.THINK0
		"think1": chat_event.mood = ChatEvent.Mood.THINK1
		"cry0": chat_event.mood = ChatEvent.Mood.CRY0
		"cry1": chat_event.mood = ChatEvent.Mood.CRY1
		"sweat0": chat_event.mood = ChatEvent.Mood.SWEAT0
		"sweat1": chat_event.mood = ChatEvent.Mood.SWEAT1
		"rage0": chat_event.mood = ChatEvent.Mood.RAGE0
		"rage1": chat_event.mood = ChatEvent.Mood.RAGE1
	
	return chat_event
