class_name ChatTree
## Tree of chat events the player can page through.
##
## The tree includes a root node with one or more branches, each of which is associated with a key. Branches can
## redirect to each other by referencing these keys. Chat lines start on the '' (empty string) branch.

class Position:
	## Current position in a chat tree.
	
	## Key of the chat branch being navigated.
	var key := ""
	
	## How far we are along the chat branch.
	var index := 0
	
	func _to_string() -> String:
		return ("(%s:%s)" % [key, index]) if key else ("(%s)" % index)
	
	
	func reset() -> void:
		key = ""
		index = 0

## Current version for saved chat data. Should be updated if and only if the chat format breaks backwards
## compatibility. This version number follows a 'ymdh' hex date format which is documented in issue #234.
const CHAT_DATA_VERSION := "1922"

const DEFAULT_ENVIRONMENT := "res://src/main/world/environment/EmptyEnvironment.tscn"

const DECORATED_RESTAURANT_PATH := "res://src/main/world/environment/restaurant/TurboFatEnvironment.tscn"
const UNDECORATED_RESTAURANT_PATH := "res://src/main/world/environment/restaurant/UndecoratedTurboFatEnvironment.tscn"

const ENVIRONMENT_SCENE_PATHS_BY_ID := {
	"inside_turbo_fat": "res://src/main/world/environment/restaurant/TurboFatEnvironment.tscn",
	
	"lava": "res://src/main/world/environment/lava/LavaEnvironment.tscn",
	"lava/zagma": "res://src/main/world/environment/lava/ZagmaEnvironment.tscn",
	"lemon": "res://src/main/world/environment/lemon/LemonEnvironment.tscn",
	"lemon/walk": "res://src/main/world/environment/LemonWalkEnvironment.tscn",
	"lemon_2": "res://src/main/world/environment/lemon/Lemon2Environment.tscn",
	"marsh": "res://src/main/world/environment/marsh/MarshEnvironment.tscn",
	"marsh/walk": "res://src/main/world/environment/marsh/MarshWalkEnvironment.tscn",
	"poki": "res://src/main/world/environment/poki/PokiEnvironment.tscn",
	"poki/walk": "res://src/main/world/environment/poki/PokiWalkEnvironment.tscn",
	"sand": "res://src/main/world/environment/sand/SandEnvironment.tscn",
	"sand/banana_hq": "res://src/main/world/environment/sand/BananaHqEnvironment.tscn",
	"sand/walk": "res://src/main/world/environment/sand/SandWalkEnvironment.tscn",
	"filming": "res://src/main/world/environment/sand/FilmingEnvironment.tscn",
}

## unique key to identify this conversation in the chat history
var chat_key: String

## metadata including whether the chat event is 'fixed_zoom'
var meta: Dictionary

## tree of chat event objects
## key: (String) chat id
## value: (Array, ChatEvent) events for a particular chat sequence
var events := {}

## specific location where this conversation takes place, if any
var location_id: String

## Spawn locations for different creatures, if this ChatTree represents a cutscene. Spawn locations prefixed with a '!'
## indicate that the creature should spawn invisible.
##
## key: (String) creature id
## value: (String) spawn id
var spawn_locations := {}

## Creature who acts as the chef for the cutscene, if any. This ensures levels are paired up with appropriate
## cutscenes.
var chef_id: String

## Creatures who act as the customers for the cutscene, if any. This ensures levels are paired up with appropriate
## cutscenes.
var customer_ids: Array

## Creature who acts as an observer for this cutscene, if any. This ensures levels are paired up with appropriate
## cutscenes.
var observer_id: String

## Puzzle environment applicable to this cutscene, if any. A cutscene might take place at another restaurant for
## example, in which case the puzzle should happen in that restaurant as well.
var puzzle_environment_name: String

## Creatures in this cutscene.
var creature_ids: Array

## current position in this chat tree
var _position := Position.new()

## 'true' if _position has already been initialized to the first event in the chat tree
var _did_prepare := false

## Adds a chat event to a new chat branch, or appends it to an existing branch.
##
## Parameters:
## 	'key': The key of the chat branch to append to.
##
## 	'event': The chat event to append.
func append(key: String, event: ChatEvent) -> void:
	Utils.put_if_absent(events, key, [])
	events[key].append(event)


## Returns the chat event at the current position.
func get_event() -> ChatEvent:
	return events[_position.key][_position.index]


## Advances the chat position deeper into the tree.
##
## This can either involve navigating further down the current branch, or navigating to a new branch if any links are
## available.
##
## Returns 'true' if the position was advanced successfully, or 'false' if we hit a dead end. A dead end can indicate
## that the chat tree cannot be advanced any further and the window should close.
##
## Parameters:
## 	'link_index': Which chat branch to follow. This parameter is optional, and is ignored if the chat tree does not
## 		branch.
func advance(link_index := -1) -> bool:
	var did_increment := false
	if get_event().links and events.has(get_event().links[link_index]):
		# reset to beginning of a new chat branch
		_position.key = get_event().links[link_index]
		_position.index = 0
		did_increment = true
	elif _position.index + 1 < events[_position.key].size():
		# advance through the current chat branch
		_position.index += 1
		did_increment = true
	_apply_say_if_conditions()
	_assign_flags_and_phrases()
	return did_increment


## Relocates the position within the chat tree to start a new chat.
##
## The first time this is called, the position is relocated. The second and subsequent times, this has no effect. This
## allows subsequent overworld conversations with the same person to repeat the last line of dialog instead of
## repeating the entire dialog sequence.
func prepare_first_chat_event() -> void:
	if _did_prepare:
		return
	
	_apply_start_if_conditions()
	_apply_say_if_conditions()
	_assign_flags_and_phrases()
	_did_prepare = true


## Returns 'true' if the chat position can be advanced deeper into the tree.
func can_advance() -> bool:
	var can_increment := false
	if get_event().links and events.has(get_event().links[-1]):
		# can reset to beginning of a new chat branch
		can_increment = true
	elif _position.index + 1 < events[_position.key].size():
		# can advance through the current chat branch
		can_increment = true
	return can_increment


## Returns the scene path where this chat takes place.
func chat_environment_path() -> String:
	var result: String
	
	if not ENVIRONMENT_SCENE_PATHS_BY_ID.has(location_id):
		warn("Invalid location_id: %s" % [location_id])
	
	result = ENVIRONMENT_SCENE_PATHS_BY_ID.get(location_id, DEFAULT_ENVIRONMENT)
	
	# if the player hasn't gotten far enough in the story, they don't have a nice decorated restaurant
	if result == DECORATED_RESTAURANT_PATH \
			and not PlayerData.career.is_restaurant_decorated():
		result = UNDECORATED_RESTAURANT_PATH
	
	return result


func reset() -> void:
	chat_key = ""
	meta = {}
	events = {}
	location_id = ""
	spawn_locations = {}
	chef_id = ""
	customer_ids = []
	observer_id = ""
	puzzle_environment_name = ""
	creature_ids = []
	_position.reset()
	_did_prepare = false


## Returns 'true' if this cutscene is set inside the restaurant.
##
## This signifies that this cutscene should not be played if the player does not have a restaurant.
func inside_restaurant() -> bool:
	return location_id in ["inside_turbo_fat"]


## Returns 'true' if this cutscene features Fat Sensei.
##
## This signifies that this cutscene should not be played if Fat Sensei is not following the player.
func has_sensei() -> bool:
	return creature_ids.has(CreatureLibrary.SENSEI_ID)


## Suppresses warnings from showing up on the console.
##
## This is only used during utilities to suppress duplicate messages.
func suppress_warnings() -> void:
	meta["suppress_warnings"] = true


## Adds a warning about something potentially harmful with this chat tree.
##
## This could be something like a line spoken by a character who isn't in the scene.
func warn(warning: String) -> void:
	Utils.put_if_absent(meta, "warnings", [])
	meta["warnings"].append(warning)
	
	if not meta.get("suppress_warnings", false):
		push_warning(warning)


## Jump to any chat sequences whose 'start_if' conditions are met.
func _apply_start_if_conditions() -> void:
	# look for 'start_if' conditions...
	var start_keys := []
	for key in events:
		var chat_event: ChatEvent = events[key][0]
		var start_condition := ""
		for meta_item_obj in chat_event.meta:
			var meta_item: String = meta_item_obj
			if meta_item.begins_with("start_if "):
				start_condition = meta_item.trim_prefix("start_if ")
				break
		if start_condition and BoolExpressionEvaluator.evaluate(start_condition):
			start_keys.append(key)
	
	if start_keys:
		# if a 'start_if' condition is met, move to that chat branch
		_position.key = start_keys[0]
		_position.index = 0
	
	if start_keys.size() >= 2:
		# if two or more 'start_if' conditions are met, report a warning
		warn("Multiple start_if conditions were met: %s" % [[start_keys]])


## Skip any dialog lines whose 'say_if' conditions are unmet.
func _apply_say_if_conditions() -> void:
	var did_increment := true
	while did_increment:
		did_increment = false
		var chat_condition: String
		for meta_item in get_event().meta:
			if meta_item.begins_with("say_if "):
				chat_condition = meta_item.trim_prefix("say_if ")
				break
		if chat_condition \
				and not BoolExpressionEvaluator.evaluate(chat_condition) \
				and _position.index + 1 < events[_position.key].size():
			# advance through the current chat branch
			_position.index += 1
			did_increment = true


## Processes meta items which manipulate flags and phrases.
func _assign_flags_and_phrases() -> void:
	for meta_item in get_event().meta:
		var tokens: Array = meta_item.split(" ")
		var args: Array = tokens.slice(1, tokens.size())
		if tokens:
			match tokens[0]:
				"default_phrase": _process_default_phrase_statement(args)
				"set_flag": _process_set_flag_statement(args)
				"set_phrase": _process_set_phrase_statement(args)
				"unset_flag": _process_unset_flag_statement(args)
				"unset_phrase": _process_unset_phrase_statement(args)


## Processes a default_phrase statement like 'default_phrase dog_breed Labrador Retriever'
##
## Assigns the specified value to the specified chat history phrase if the phrase is currently unset.
##
## Parameters:
## 	'args': The statement's arguments, such as ['dog_breed', 'Labrador' 'Retriever']
func _process_default_phrase_statement(args: Array) -> void:
	if args.size() < 2:
		warn("Invalid argument count for default_phrase call. Expected at least 2 but was %s"
				% [args.size()])
		return
	
	if not PlayerData.chat_history.has_phrase(args[0]):
		PlayerData.chat_history.set_phrase(
				args[0], PoolStringArray(args.slice(1, args.size())).join(" "))


## Processes a set_flag statement like 'set_flag foo' or 'set_flag foo bar'
##
## Assigns the specified value to the specified chat history flag. If no value is specified, it is set to the word
## 'true'.
##
## Parameters:
## 	'args': The statement's arguments, such as ['foo'] or ['foo', 'bar']
func _process_set_flag_statement(args: Array) -> void:
	match args.size():
		1:
			PlayerData.chat_history.set_flag(args[0])
		2:
			PlayerData.chat_history.set_flag(args[0], args[1])
		_:
			warn("Invalid argument count for set_flag call. Expected 1 or 2 but was %s"
					% [args.size()])


## Processes a set_phrase statement like 'set_phrase dog_breed Labrador Retriever'
##
## Assigns the specified value to the specified chat history phrase.
##
## Parameters:
## 	'args': The statement's arguments, such as ['dog_breed', 'Labrador', 'Retriever]
func _process_set_phrase_statement(args: Array) -> void:
	if args.size() < 2:
		warn("Invalid argument count for set_phrase call. Expected at least 2 but was %s"
				% [args.size()])
		return
	
	PlayerData.chat_history.set_phrase(
			args[0], PoolStringArray(args.slice(1, args.size())).join(" "))


## Processes an unset_phrase statement like 'unset_phrase dog_breed'
##
## Unassigns the specified value from the specified chat history phrase.
##
## Parameters:
## 	'args': The statement's arguments, such as ['dog_breed']
func _process_unset_phrase_statement(args: Array) -> void:
	if args.size() != 1:
		warn("Invalid argument count for unset_phrase call. Expected 1 but was %s"
				% [args.size()])
		return
	
	PlayerData.chat_history.set_phrase(args[0], "")


## Processes an unset_flag statement like 'unset_flag foo'
##
## Unassigns the specified chat history flag.
##
## Parameters:
## 	'args': The statement's arguments, such as ['foo'].
func _process_unset_flag_statement(args: Array) -> void:
	if args.size() != 1:
		warn("Invalid argument count for unset_flag call. Expected 1 but was %s"
				% [args.size()])
	
	PlayerData.chat_history.unset_flag(args[0])
