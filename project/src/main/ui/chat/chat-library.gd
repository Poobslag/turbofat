extends Node
## Loads chat lines from files.
##
## Chat lines are stored as a set of chatscript resources. This class loads those resources into ChatTree instances so
## they can be fed into the UI.

const CHAT_EXTENSION := ".chat"

const PREROLL_SUFFIX := "000"
const POSTROLL_SUFFIX := "100"

## Returns the chat tree for the specified creature.
##
## Each creature has a sequence of conversations defined by their 'chat selectors'. This method goes through a
## creature's chat selectors until it finds one suitable for the current game state.
##
## Returns null if the chat tree cannot be found.
##
## Parameters:
## 	'creature': The creature whose conversation should be returned
##
## 	'forced_level_id': (Optional) The current level being chosen. If omitted, the level_id will be calculated based on
## 			the first unfinished unlocked level available.
func chat_tree_for_creature(creature: Creature) -> ChatTree:
	var filler_ids := filler_ids_for_creature(creature.creature_id)
	var chosen_chat := select_from_chat_selectors(creature.chat_selectors, creature.creature_id, filler_ids)

	var chat_tree := chat_tree_for_creature_chat_id(creature.creature_def, chosen_chat)
	if not chat_tree and has_preroll(chosen_chat):
		chat_tree = chat_tree_for_preroll(chosen_chat)

	return chat_tree


## Returns the chat tree for the specified creature and chat id.
##
## Returns null if the chat tree cannot be found.
func chat_tree_for_creature_chat_id(creature_def: CreatureDef, chat_id: String) -> ChatTree:
	var chat_tree: ChatTree
	if FileUtils.file_exists(_creature_chat_path(creature_def.creature_id, chat_id)):
		chat_tree = chat_tree_from_file(_creature_chat_path(creature_def.creature_id, chat_id))
	return chat_tree


## Returns the chat tree for the specified chat key, such as 'chat/marsh_prologue'.
##
## Parameters:
## 	'chat_key': A key such as 'chat/marsh_prologue' identifying a chat resource
func chat_tree_for_key(chat_key: String) -> ChatTree:
	var path := path_from_chat_key(chat_key)
	return chat_tree_from_file(path)


## Returns the chat tree for the cutscene which plays before the current level.
##
## Returns null if the current level does not have a preroll cutscene.
func chat_tree_for_preroll(level_id: String) -> ChatTree:
	if not has_preroll(level_id):
		return null
	
	return chat_tree_from_file(_preroll_path(level_id))


## Returns the chat tree for the cutscene which plays after the current level.
##
## Returns null if the current level does not have a postroll cutscene.
func chat_tree_for_postroll(level_id: String) -> ChatTree:
	if not has_postroll(level_id):
		return null
	
	return chat_tree_from_file(_postroll_path(level_id))


## Returns 'true' if the current level is preceded by a cutscene.
func has_preroll(level_id: String) -> bool:
	return FileUtils.file_exists(_preroll_path(level_id))


## Returns 'true' if the current level is followed by a cutscene.
func has_postroll(level_id: String) -> bool:
	return FileUtils.file_exists(_postroll_path(level_id))


## Returns a ChatIcon enum representing the creature's next conversation.
func chat_icon_for_creature(creature: Creature) -> int:
	var result := ChatIcon.NONE
	if creature == ChattableManager.sensei or creature == ChattableManager.player:
		# no chat icon for player or sensei
		pass
	elif LevelLibrary.next_creature_level(creature.creature_id):
		# food chat icon if the chat will launch a puzzle
		result = ChatIcon.FOOD
	else:
		# filler/speech icon for normal conversations
		var filler_ids := filler_ids_for_creature(creature.creature_id)
		var chosen_chat := select_from_chat_selectors(creature.chat_selectors, creature.creature_id, filler_ids)
		result = ChatIcon.FILLER if filler_ids.has(chosen_chat) else ChatIcon.SPEECH
	
	return result


## Loads the chat events from the specified file.
func chat_tree_from_file(path: String) -> ChatTree:
	var result: ChatTree
	if path.ends_with(CHAT_EXTENSION):
		result = _chat_tree_from_chatscript_file(path)
	else:
		push_error("Unrecognized cutscene suffix: %s" % [path])
	return result


## Calculates the chat id for the current conversation.
##
## This method goes through a creature's chat selectors until it finds one suitable for the current game state. If none
## are found, it returns a filler conversation instead.
func select_from_chat_selectors(chat_selectors: Array, creature_id: String, filler_ids: Array) -> String:
	var result: String
	
	# check the chat selectors for a notable conversation
	for chat_selector_obj in chat_selectors:
		var chat_selector: Dictionary = chat_selector_obj

		var repeat_age: int = chat_selector.get("repeat", 25)
		var chat_key := "creature/%s/%s" % [creature_id, chat_selector["chat"]]
		var chat_age: int = PlayerData.chat_history.get_chat_age(chat_key)
		if chat_age < repeat_age:
			# skip; we've had this conversation too recently
			continue
		
		var available_if_met := true
		if chat_selector.has("available_if"):
			available_if_met = BoolExpressionEvaluator.evaluate(chat_selector["available_if"], creature_id)
		if not available_if_met:
			# skip; if condition wasn't met
			continue
		
		var prioritized_if_met := false
		if chat_selector.has("prioritized_if"):
			prioritized_if_met = BoolExpressionEvaluator.evaluate(chat_selector["prioritized_if"], creature_id)
		
		# if we find a prioritized result, we overwrite any other result and stop searching
		if prioritized_if_met:
			result = chat_selector["chat"]
			break
		
		# if we find a non-prioritized result, the first one found 'wins' and is not overwritten
		if not result:
			result = chat_selector["chat"]
	
	if not result:
		# no notable conversation was found; find a filler conversation instead
		var result_chat_age: int
		
		for filler_id in filler_ids:
			var chat_key := "creature/%s/%s" % [creature_id, filler_id]
			var chat_age: int = PlayerData.chat_history.get_chat_age(chat_key)
			if not result or chat_age > result_chat_age:
				# found an older filler conversation; replace the current result
				result = filler_id
				result_chat_age = chat_age
			
			if result and result_chat_age == ChatHistory.CHAT_AGE_NEVER:
				break
	
	return result


## Returns the chat filler IDs for the specified creature.
##
## Examines the creature's chat and resource files, and returns any chat ids with names like 'filler_014'.
func filler_ids_for_creature(creature_id: String) -> Array:
	var filler_ids := []
	for i in range(1000):
		var filler_id := "filler_%03d" % i
		var chat_path := "res://assets/main/creatures/primary/%s/%s%s" % \
				[creature_id, StringUtils.underscores_to_hyphens(filler_id), CHAT_EXTENSION]
		if FileUtils.file_exists(chat_path):
			filler_ids.append(filler_id)
		else:
			break
	return filler_ids


## Add lull characters to the specified string.
##
## Lull characters make the chat UI briefly pause at parts of the chat line. We add these after periods, commas and
## other punctuation.
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
		for _i in range(10):
			var old_transformed := transformer.transformed
			transformer.sub("/([/!.?,\\-]*)$", "$1")
			if old_transformed == transformer.transformed:
				break
	
	# remove lull character from the end of the line
	transformer.transformed = transformer.transformed.trim_suffix("/")
	
	return transformer.transformed


## Add many lull characters to the specified string to make it pause after every character.
##
## This can be used for very short sentences like 'OH, MY!!!'
func add_mega_lull_characters(s: String) -> String:
	var transformer := StringTransformer.new(s)
	
	# long pause between words
	transformer.sub(" ", "// ")
	
	# short pause between letters, punctuation
	transformer.sub("([^/ ])", "$1/")
	
	# remove lull character from the end of the line
	transformer.transformed = transformer.transformed.trim_suffix("/")
	return transformer.transformed


func _creature_chat_path(creature_id: String, chat_id: String) -> String:
	return "res://assets/main/creatures/primary/%s/%s%s" % \
			[creature_id, StringUtils.underscores_to_hyphens(chat_id), CHAT_EXTENSION]


## Loads the chat events from the specified chatscript file.
func _chat_tree_from_chatscript_file(path: String) -> ChatTree:
	var chat_tree: ChatTree
	if not FileUtils.file_exists(path):
		push_error("File not found: %s" % path)
		chat_tree = ChatTree.new()
	else:
		var parser := ChatscriptParser.new()
		chat_tree = parser.chat_tree_from_file(path)
	
	return chat_tree


func _preroll_path(level_id: String) -> String:
	return "res://assets/main/puzzle/levels/cutscenes/%s-%s%s" % \
			[StringUtils.underscores_to_hyphens(level_id), PREROLL_SUFFIX, CHAT_EXTENSION]


func _postroll_path(level_id: String) -> String:
	return "res://assets/main/puzzle/levels/cutscenes/%s-%s%s" % \
			[StringUtils.underscores_to_hyphens(level_id), POSTROLL_SUFFIX, CHAT_EXTENSION]


## Converts a path like 'res://assets/main/creatures/primary/bones/filler-001.chat' into a chat key like
## 'chat/bones/filler_001'.
##
## Using these chat keys has many benefits. Most notably they aren't invalidated if we move files or change extensions.
##
## Parameters:
## 	'path': The path of a chat resource.
##
## Returns:
## 	A key such as 'chat/marsh_prologue' corresponding to the specified chat resource
static func chat_key_from_path(path: String) -> String:
	var chat_key := path
	chat_key = chat_key.trim_suffix(".chat")
	chat_key = chat_key.trim_prefix("res://assets/main/")
	if chat_key.begins_with("creatures/primary/"):
		chat_key = "creature/" + chat_key.trim_prefix("creatures/primary/")
	elif chat_key.begins_with("puzzle/levels/cutscenes"):
		chat_key = "level/" + chat_key.trim_prefix("puzzle/levels/cutscenes/")
	chat_key = StringUtils.hyphens_to_underscores(chat_key)
	return chat_key


## Converts a chat key like 'creature/bones/filler_001' into a path like
## 'res://assets/main/creatures/primary/bones/filler-001.chat'
##
## Parameters:
## 	'chat_key': A chat key such as 'chat/marsh_prologue'
##
## Returns:
## 	The path of the resource identified by the specified chat key.
static func path_from_chat_key(chat_key: String) -> String:
	var path := chat_key
	path = StringUtils.underscores_to_hyphens(chat_key)
	if chat_key.begins_with("creature/"):
		path = path.replace("creature/", "creatures/primary/")
	elif chat_key.begins_with("level/"):
		path = path.replace("level/", "puzzle/levels/cutscenes/")
	path = "res://assets/main/%s.chat" % [path]
	return path
