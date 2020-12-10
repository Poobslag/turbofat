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
	
	'level_num': (Optional) The current level being chosen; '1' being the creature's first level. If specified, this
			allows the creature to say something about the upcoming level.
"""
func load_chat_events_for_creature(creature: Creature, level_num: int = -1) -> ChatTree:
	var state := {
		"creature_id": creature.creature_id,
		"notable_chat": PlayerData.chat_history.get_filler_count(creature.creature_id) > 0,
		"level_num": level_num
	}
	
	if state["level_num"] == -1:
		state["level_num"] = _first_unfinished_level_num(creature)
	
	# returning dialog for the creature
	var filler_ids := _filler_ids_for_creature(creature)
	var chosen_dialog := choose_dialog_from_chat_selectors(creature.chat_selectors, state, filler_ids)
	
	var chat_tree: ChatTree
	if creature.dialog.has(chosen_dialog):
		chat_tree = ChatTree.new()
		chat_tree.from_json_dict(creature.dialog[chosen_dialog])
		chat_tree.history_key = "dialog/%s/%s" % [creature.creature_id, chosen_dialog]
	else:
		var path := "res://assets/main/creatures/primary/%s/%s.json" % \
				[creature.creature_id, chosen_dialog.replace("_", "-")]
		chat_tree = load_chat_events_from_file(path)
	
	if state["level_num"] >= 1:
		# schedule a level to launch when the dialog completes
		var level_ids := creature.get_level_ids()
		var level_id: String = level_ids[state["level_num"] - 1]
		Level.set_launched_level(level_id, creature.creature_id, state["level_num"])
	
	return chat_tree


"""
Loads the chat events from the specified json file.
"""
func load_chat_events_from_file(path: String) -> ChatTree:
	var chat_tree := ChatTree.new()
	var history_key := path
	history_key = StringUtils.remove_end(history_key, ".json")
	history_key = StringUtils.remove_start(history_key, "res://assets/main/")
	history_key = history_key.replace("creatures/primary", "dialog")
	history_key = history_key.replace("-", "_")
	chat_tree.history_key = history_key
	
	if not FileUtils.file_exists(path):
		push_error("File not found: %s" % path)
	else:
		var tree_text: String = FileUtils.get_file_as_text(path)
		var json_tree := _parse_json_tree(tree_text)
		chat_tree.from_json_dict(json_tree)
	
	return chat_tree


"""
Calculates the dialog id for the current conversation.

This method goes through a creature's chat selectors until it finds one suitable for the current game state. If none
are found, it returns a filler conversation instead.
"""
func choose_dialog_from_chat_selectors(chat_selectors: Array, state: Dictionary, filler_ids: Array) -> String:
	var creature_id: String = state.get("creature_id", "")
	var result: String
	
	# search the chat_selectors for a suitable conversation
	for chat_selector_obj in chat_selectors:
		var chat_selector: Dictionary = chat_selector_obj
		
		var repeat_age: int = chat_selector.get("repeat", 25)
		var history_key := "dialog/%s/%s" % [creature_id, chat_selector["dialog"]]
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
	
	if not result:
		# no suitable conversation was found; find a suitable filler conversation instead
		var result_chat_age: int
		
		for filler_id in filler_ids:
			var history_key := "dialog/%s/%s" % [creature_id, filler_id]
			var chat_age: int = PlayerData.chat_history.get_chat_age(history_key)
			if not result or chat_age == -1 or chat_age > result_chat_age:
				# found an older filler conversation; replace the current result
				result = filler_id
				result_chat_age = chat_age
			
			if result and result_chat_age == -1:
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
			result = state.get("level_num", -1) == int(if_split[1])
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
		push_error("Invalid json type: %s" % typeof(parsed))
	return json_tree


"""
Returns the dialog filler IDs for the specified creature.

Examines the creature's dialog and resource files, and returns any dialog ids with names like 'filler_014'.
"""
func _filler_ids_for_creature(creature: Creature) -> Array:
	var filler_ids := []
	for i in range(0, 1000):
		var filler_id := "filler_%03d" % i
		var path := "res://assets/main/creatures/primary/%s/%s.json" % \
				[creature.creature_id, filler_id.replace("_", "-")]
		if creature.dialog.has(filler_id) or FileUtils.file_exists(path):
			filler_ids.append(filler_id)
		else:
			break
	return filler_ids


"""
Returns the first available level for this creature which hasn't been finished.

Returns -1 if all levels are locked, or if the player's finished all the available levels.
"""
func _first_unfinished_level_num(creature: Creature) -> int:
	var level_num := -1
	var level_ids := creature.get_level_ids()
	for level_id_index in range(0, level_ids.size()):
		var creature_level: String = level_ids[level_id_index]
		if LevelLibrary.is_locked(creature_level):
			continue
		if PlayerData.level_history.finished_levels.has(creature_level):
			continue
		
		level_num = level_id_index + 1
		break
	return level_num
