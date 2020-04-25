class_name ChatLibrary
"""
Loads dialog from files.

Dialog is stored as a set of json resources. This class parses those json resources and into ChatEvents so they can be
fed into the UI.
"""

"""
Loads the chat events for the currently focused interactable.

Returns an array of ChatEvent objects for the dialog sequence which the player should see.
"""
func load_chat_events() -> ChatTree:
	var chat_tree := ChatTree.new()
	var focused := InteractableManager.get_focused()
	if not focused.has_meta("chat_id"):
		# can't look up chat events without a chat_id; return an empty array
		push_warning("Interactable %s does not define a 'chat_id' property." % focused)
	else:
		var chat_id: String = focused.get_meta("chat_id")
		# open the json file for the currently focused interactable
		var file := File.new()
		file.open("res://assets/dialog/%s.json" % chat_id, File.READ)
		var json_tree := _parse_json_tree(file.get_as_text())
		chat_tree.from_dict(json_tree)
	return chat_tree

"""
Parses a json dialog tree from the specified json string.

Our dialog parser needs a dictionary wrapped in an array wrapped in a dictionary. We parse simpler json structures by
wrapping the parsed objects ourselves. This prevents trivial dialog sequences such as 'Tweet!' from requiring
two extra json wrapper objects.
"""
func _parse_json_tree(json: String) -> Dictionary:
	var json_tree: Dictionary
	var parsed = parse_json(json)
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has(""):
		json_tree = parsed
	elif typeof(parsed) == TYPE_DICTIONARY:
		# We were given a dictionary corresponding to a dialog line. Wrap it into a tree.
		json_tree = {"" : [parsed]}
	elif typeof(parsed) == TYPE_ARRAY:
		# We were given an array corresponding to a dialog branch. Wrap it into a tree.
		json_tree = {"" : parsed}
	else:
		push_error("Invalid json type: " % typeof(parsed))
	return json_tree
