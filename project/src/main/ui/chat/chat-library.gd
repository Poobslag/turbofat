extends Node
"""
Loads dialog from files.

Dialog is stored as a set of json resources. This class parses those json resources into ChatEvents so they can be fed
into the UI.
"""

"""
Loads a conversation for the specified creature.

Each creature has a sequence of conversations defined by their 'chat selectors'. This method goes through a creature's
chat selectors until it finds one suitable for the current game state.

Parameters:
	'creature': The creature whose conversation should be returned
	
	'level_int': (Optional) The current level being chosen; '1' being the creature's first level. If specified, this
			allows the creature to say something about the upcoming level.
"""
func load_chat_events_for_creature(creature: Creature, level_int: int = -1) -> ChatTree:
	var state := {
		"creature_id": creature.creature_id,
		"notable_chat": PlayerData.chat_history.get_filler_count(creature.creature_id) > 0
	}
	if level_int != -1:
		state["level_int"] = 1
	
	var chat_tree: ChatTree
	var level_names := creature.get_level_names()
	if level_names.size() == 2 and level_int == -1:
		# talking to a creature with two or more levels results in a selection menu (for now)
		chat_tree = load_chat_events_from_file("res://assets/main/dialog/level-select-2.json")
	elif level_names.size() <= 2:
		var chosen_dialog := choose_dialog_from_chat_selectors(creature.chat_selectors, state)
		if creature.dialog.has(chosen_dialog):
			chat_tree = ChatTree.new()
			chat_tree.from_json_dict(creature.dialog[chosen_dialog])
			chat_tree.history_key = "dialog/%s/%s" % [creature.creature_id, chosen_dialog]
		else:
			var path := "res://assets/main/dialog/%s/%s.json" % [creature.creature_id, chosen_dialog.replace("_", "-")]
			chat_tree = load_chat_events_from_file(path)
	else:
		push_warning("Unexpected level names count: %s" % level_names.size())
	return chat_tree


"""
Loads the chat events from the specified json file.
"""
func load_chat_events_from_file(path: String) -> ChatTree:
	var chat_tree := ChatTree.new()
	var history_key := path
	history_key = StringUtils.remove_end(history_key, ".json")
	history_key = StringUtils.remove_start(history_key, "res://assets/main/")
	chat_tree.history_key = history_key
	
	if not FileUtils.file_exists(path):
		push_error("File not found: %s" % path)
	else:
		var tree_text: String = FileUtils.get_file_as_text(path)
		var json_tree := _parse_json_tree(tree_text)
		chat_tree.from_json_dict(json_tree)
	
	return chat_tree


func choose_dialog_from_chat_selectors(chat_selectors: Array, state: Dictionary) -> String:
	var result := "filler"
	for chat_selector_obj in chat_selectors:
		var chat_selector: Dictionary = chat_selector_obj
		
		var repeat_age: int = chat_selector.get("repeat", 25)
		var history_key := "dialog/%s/%s" % [state.get("creature_id", ""), chat_selector["dialog"]]
		var chat_age: int = PlayerData.chat_history.get_chat_age(history_key)
		if chat_age != -1 and chat_age < repeat_age:
			# skip; we've had this conversation too recently
			continue
		
		var if_conditions: Array = chat_selector.get("if_conditions", [])
		var if_conditions_met := true
		for if_condition in if_conditions:
			if not _if_condition_met(if_condition, state):
				if_conditions_met = false
				break
		if not if_conditions_met:
			# skip; one or more if conditions weren't met
			continue
		
		# success; return the current chat selector's dialog
		result = chat_selector["dialog"]
		break
	
	return result


"""
Returns 'true' if the specified if condition is met by the current game state.
"""
func _if_condition_met(if_condition: String, state: Dictionary) -> bool:
	var if_split := if_condition.split("/")
	var if_match := "%s:%s" % [if_split[0], if_split.size()]
	
	var result := false
	match if_match:
		"current_level:2":
			result = state.get("level_int", -1) == int(if_split[1])
		_:
			result = state.get(if_condition, false)
	return result


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
	return json_tree
