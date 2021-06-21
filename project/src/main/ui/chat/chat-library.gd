extends Node
"""
Loads chat lines from files.

Chat lines are stored as a set of chatscript resources. This class loads those resources into ChatTree instances so
they can be fed into the UI.
"""

const CHAT_EXTENSION := ".chat"

const PREROLL_SUFFIX := "000"
const POSTROLL_SUFFIX := "100"

"""
Loads a conversation for the specified creature.

Each creature has a sequence of conversations defined by their 'chat selectors'. This method goes through a creature's
chat selectors until it finds one suitable for the current game state.

Parameters:
	'creature': The creature whose conversation should be returned

	'forced_level_id': (Optional) The current level being chosen. If omitted, the level_id will be calculated based on
			the first unfinished unlocked level available.
"""
func chat_tree_for_creature(creature: Creature, forced_level_id: String = "") -> ChatTree:
	var state := _creature_chat_state(creature.creature_id, forced_level_id)
	var level_id: String = state["level_id"]
	var chat_tree := chat_tree_for_creature_def(creature.creature_def, state)

	if level_id:
		# schedule a level to launch when the chat completes
		CurrentLevel.set_launched_level(level_id)

	return chat_tree


"""
Returns the chat tree for the specified creature.

Returns null if the chat tree cannot be found.
"""
func chat_tree_for_creature_id(creature_id: String, forced_level_id: String = "") -> ChatTree:
	var creature_def: CreatureDef = PlayerData.creature_library.get_creature_def(creature_id)
	var state := _creature_chat_state(creature_id, forced_level_id)
	return chat_tree_for_creature_def(creature_def, state)


"""
Returns the chat tree for the specified creature.

Returns null if the chat tree cannot be found.
"""
func chat_tree_for_creature_def(creature_def: CreatureDef, state: Dictionary) -> ChatTree:
	var creature_id := creature_def.creature_id
	var filler_ids := filler_ids_for_creature(creature_id)
	var chosen_chat := select_from_chat_selectors(creature_def.chat_selectors, state, filler_ids)

	var chat_tree := chat_tree_for_chat_id(creature_def, chosen_chat)
	if not chat_tree and has_preroll(chosen_chat):
		chat_tree = chat_tree_for_preroll(chosen_chat)

	return chat_tree


"""
Returns the chat tree for the specified creature and chat id.

Returns null if the chat tree cannot be found.
"""
func chat_tree_for_chat_id(creature_def: CreatureDef, chat_id: String) -> ChatTree:
	var chat_tree: ChatTree
	if FileUtils.file_exists(_creature_chat_path(creature_def.creature_id, chat_id)):
		chat_tree = chat_tree_from_file(_creature_chat_path(creature_def.creature_id, chat_id))
	return chat_tree


"""
Returns the chat tree for the cutscene which plays before the current level.
"""
func chat_tree_for_preroll(level_id: String) -> ChatTree:
	return chat_tree_from_file(_preroll_path(level_id))


"""
Returns the chat tree for the cutscene which plays after the current level.
"""
func chat_tree_for_postroll(level_id: String) -> ChatTree:
	return chat_tree_from_file(_postroll_path(level_id))


"""
Returns 'true' if the current level is preceded by a cutscene.
"""
func has_preroll(level_id: String) -> bool:
	return FileUtils.file_exists(_preroll_path(level_id))


"""
Returns 'true' if the current level is followed by a cutscene.
"""
func has_postroll(level_id: String) -> bool:
	return FileUtils.file_exists(_postroll_path(level_id))


"""
Returns a ChatIcon enum representing the creature's next conversation.
"""
func chat_icon_for_creature(creature: Creature) -> int:
	var result := ChatIcon.NONE
	if creature == ChattableManager.sensei or creature == ChattableManager.player:
		# no chat icon for player or sensei
		pass
	elif LevelLibrary.first_unfinished_level_id_for_creature(creature.creature_id):
		# food chat icon if the chat will launch a puzzle
		result = ChatIcon.FOOD
	else:
		# filler/speech icon for normal conversations
		var state := _creature_chat_state(creature.creature_id)
		var filler_ids := filler_ids_for_creature(creature.creature_id)
		var chosen_chat := select_from_chat_selectors(creature.chat_selectors, state, filler_ids)
		result = ChatIcon.FILLER if filler_ids.has(chosen_chat) else ChatIcon.SPEECH
	
	return result


"""
Loads the chat events from the specified file.
"""
func chat_tree_from_file(path: String) -> ChatTree:
	var result: ChatTree
	if path.ends_with(CHAT_EXTENSION):
		result = _chat_tree_from_chatscript_file(path)
	else:
		push_error("Unrecognized cutscene suffix: %s" % [path])
	return result


"""
Calculates the chat id for the current conversation.

This method goes through a creature's chat selectors until it finds one suitable for the current game state. If none
are found, it returns a filler conversation instead.
"""
func select_from_chat_selectors(chat_selectors: Array, state: Dictionary, filler_ids: Array) -> String:
	var creature_id: String = state.get("creature_id", "")
	var result: String
	
	var level_id: String = state.get("level_id", "")
	if not level_id:
		level_id = LevelLibrary.first_unfinished_level_id_for_creature(creature_id)
	if level_id:
		result = level_id

	if not result:
		# no level available; find a suitable conversation
		for chat_selector_obj in chat_selectors:
			var chat_selector: Dictionary = chat_selector_obj

			var repeat_age: int = chat_selector.get("repeat", 25)
			var history_key := "chat/%s/%s" % [creature_id, chat_selector["chat"]]
			var chat_age: int = PlayerData.chat_history.get_chat_age(history_key)
			if chat_age < repeat_age:
				# skip; we've had this conversation too recently
				continue
			
			var if_condition_met := true
			if chat_selector.has("if_condition"):
				var if_condition: String = chat_selector["if_condition"]
				if_condition_met = ChatBoolEvaluator.evaluate(if_condition, creature_id)
			if not if_condition_met:
				# skip; if condition wasn't met
				continue

			# success; return the current chat selector's chat
			result = chat_selector["chat"]
			break
	
	if not result:
		# no suitable conversation was found; find a suitable filler conversation instead
		var result_chat_age: int
		
		for filler_id in filler_ids:
			var history_key := "chat/%s/%s" % [creature_id, filler_id]
			var chat_age: int = PlayerData.chat_history.get_chat_age(history_key)
			if not result or chat_age > result_chat_age:
				# found an older filler conversation; replace the current result
				result = filler_id
				result_chat_age = chat_age
			
			if result and result_chat_age == -1:
				break
	
	return result


"""
Returns the chat filler IDs for the specified creature.

Examines the creature's chat and resource files, and returns any chat ids with names like 'filler_014'.
"""
func filler_ids_for_creature(creature_id: String) -> Array:
	var filler_ids := []
	for i in range(0, 1000):
		var filler_id := "filler_%03d" % i
		var chat_path := "res://assets/main/creatures/primary/%s/%s%s" % \
				[creature_id, StringUtils.underscores_to_hyphens(filler_id), CHAT_EXTENSION]
		if FileUtils.file_exists(chat_path):
			filler_ids.append(filler_id)
		else:
			break
	return filler_ids


"""
Add lull characters to the specified string.

Lull characters make the chat UI briefly pause at parts of the chat line. We add these after periods, commas and other
punctuation.
"""
func add_lull_characters(s: String) -> String:
	if "/" in s:
		# if the sentence already contains lull characters, we leave it alone
		return s
	
	var transformer := StringTransformer.new(s)
	
	# add pauses after certain kinds of punctuation
	transformer.sub("([!.?,])", "$1/")
	
	# add pauses after dashes, but not in hyphenated words
	transformer.sub("(-)(?=[/!.?,\\- ])", "$1/")
	
	# strip pauses from ellipses which conclude a line, unless the entire sentence is an ellipsis
	if transformer.search("[^/!.?,\\- ]"):
		for _i in range(0, 10):
			var old_transformed := transformer.transformed
			transformer.sub("/([/!.?,\\-]*)$", "$1")
			if old_transformed == transformer.transformed:
				break
	
	# remove lull character from the end of the line
	transformer.transformed = transformer.transformed.trim_suffix("/")
	
	return transformer.transformed


"""
Add many lull characters to the specified string to make it pause after every character.

This can be used for very short sentences like 'OH, MY!!!'
"""
func add_mega_lull_characters(s: String) -> String:
	var transformer := StringTransformer.new(s)
	
	# long pause between words
	transformer.sub(" ", "// ")
	
	# short pause between letters, punctuation
	transformer.sub("([^/ ])", "$1/")
	
	# remove lull character from the end of the line
	transformer.transformed = transformer.transformed.trim_suffix("/")
	return transformer.transformed


"""
Returns 'true' if the specified chat tree should be skipped, either because it is null or because its 'skip_if'
condition is met.
"""
func is_chat_skipped(chat_tree: ChatTree) -> bool:
	if chat_tree == null:
		return true
	if not chat_tree.meta or not chat_tree.meta.get("skip_if"):
		return false
	return ChatBoolEvaluator.evaluate(chat_tree.meta.get("skip_if"))


func _creature_chat_path(creature_id: String, chat_id: String) -> String:
	return "res://assets/main/creatures/primary/%s/%s%s" % \
			[creature_id, StringUtils.underscores_to_hyphens(chat_id), CHAT_EXTENSION]


"""
Loads the chat events from the specified chatscript file.
"""
func _chat_tree_from_chatscript_file(path: String) -> ChatTree:
	var chat_tree: ChatTree
	if not FileUtils.file_exists(path):
		push_error("File not found: %s" % path)
		chat_tree = ChatTree.new()
	else:
		var parser := ChatscriptParser.new()
		chat_tree = parser.chat_tree_from_file(path)
	
	return chat_tree


"""
Returns metadata about a creature's recent chats, and whether they're due for an interesting chat.
"""
func _creature_chat_state(creature_id: String, forced_level_id: String = "") -> Dictionary:
	var result := {
		"creature_id": creature_id,
		"level_id": forced_level_id
	}
	
	return result


func _preroll_path(level_id: String) -> String:
	return "res://assets/main/puzzle/levels/cutscenes/%s-%s%s" % \
			[StringUtils.underscores_to_hyphens(level_id), PREROLL_SUFFIX, CHAT_EXTENSION]


func _postroll_path(level_id: String) -> String:
	return "res://assets/main/puzzle/levels/cutscenes/%s-%s%s" % \
			[StringUtils.underscores_to_hyphens(level_id), POSTROLL_SUFFIX, CHAT_EXTENSION]
