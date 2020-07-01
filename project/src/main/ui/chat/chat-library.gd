class_name ChatLibrary
"""
Loads dialog from files.

Dialog is stored as a set of json resources. This class parses those json resources into ChatEvents so they can be fed
into the UI.
"""

# Current version for saved dialog data. Should be updated if and only if the dialog format changes.
# This version number follows a 'ymdh' hex date format which is documented in issue #234.
const DIALOG_DATA_VERSION := "15d2"

"""
Loads the chat events from the specified json file.
"""
static func load_chat_events_from_file(path: String) -> ChatTree:
	var chat_tree := ChatTree.new()
	
	if not FileUtils.file_exists(path):
		push_error("File not found: %s" % path)
	else:
		var tree_text: String = FileUtils.get_file_as_text(path)
		var json_tree := _parse_json_tree(tree_text)
		chat_tree.from_json_dict(json_tree)
	
	return chat_tree


"""
Parses a json dialog tree from the specified json string.

Our dialog parser needs a dictionary wrapped in an array wrapped in a dictionary. We parse simpler json structures by
wrapping the parsed objects ourselves. This prevents trivial dialog sequences such as 'Tweet!' from requiring
two extra json wrapper objects.
"""
static func _parse_json_tree(json: String) -> Dictionary:
	var json_tree: Dictionary
	var parsed = parse_json(json)
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has(""):
		json_tree = parsed
	elif typeof(parsed) == TYPE_DICTIONARY:
		# We were given a dictionary corresponding to a dialog line. Wrap it into a tree.
		var parsed_dict: Dictionary = parsed
		json_tree = {"" : [parsed]}
		
		# move the version to the root
		if parsed_dict.has("version"):
			json_tree["version"] = parsed_dict.get("version")
			parsed_dict.erase("version")
	elif typeof(parsed) == TYPE_ARRAY:
		var parsed_array: Array = parsed
		# We were given an array corresponding to a dialog branch. Wrap it into a tree.
		json_tree = {"" : parsed}
		
		# move the version to the root
		for item_obj in parsed_array:
			var item_dict: Dictionary = item_obj
			if item_dict.has("version"):
				json_tree["version"] = item_dict.get("version")
				item_dict.erase("version")
	else:
		push_error("Invalid json type: " % typeof(parsed))
	
	# verify and strip the version tag; we don't want it to be treated as a dialog branch
	if json_tree.get("version") != DIALOG_DATA_VERSION:
		push_warning("Unrecognized dialog data version: '%s'" % json_tree.get("version"))
	json_tree.erase("version")
	
	return json_tree
