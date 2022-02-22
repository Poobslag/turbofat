class_name ChatTree
## Tree of chat events the player can page through.
##
## The tree includes a root node with one or more branches, each of which is associated with a key. Branches can
## redirect to each other by referencing these keys. Chat lines start on the '' (empty string) branch.

class Position:
	## Current position in a chat tree.
	
	## The key of the chat branch being navigated.
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

const ENVIRONMENT_SCENE_PATHS_BY_ID := {
	"indoors": "res://src/main/world/environment/OverworldIndoorsEnvironment.tscn",
	"outdoors": "res://src/main/world/environment/OverworldEnvironment.tscn",
	"outdoors_walk": "res://src/main/world/environment/OverworldWalkEnvironment.tscn",
	
	"marsh/walk": "res://src/main/world/environment/OverworldWalkEnvironment.tscn",
	"marsh/inside_turbo_fat": "res://src/main/world/environment/OverworldIndoorsEnvironment.tscn",
	"marsh/outside_turbo_fat": "res://src/main/world/environment/MarshEnvironment.tscn",
	"marsh/buttercup_cafe": "res://src/main/world/environment/MarshEnvironment.tscn",
}

## unique key to identify this conversation in the chat history
var chat_key: String

## metadata including whether the chat event is 'filler', 'notable' or 'inplace'
var meta: Dictionary

## tree of chat event objects
## key: chat id (String)
## value: array of sequential ChatEvent objects for a particular chat sequence
var events := {}

## a specific location where this conversation takes place, if any
var location_id: String

## a specific location where the player ends up after this conversation, if any
var destination_id: String

## Spawn locations for different creatures, if this ChatTree represents a cutscene. Spawn locations prefixed with a '!'
## indicate that the creature should spawn invisible.
#
## key: creature id
## value: spawn id
var spawn_locations := {}

## The creature who acts as the chef for the cutscene, if any. This ensures levels are paired up with appropriate
## cutscenes.
var chef_id: String

## The creature(s) who acts as the customer(s) for the cutscene, if any. This ensures levels are paired up with
## appropriate cutscenes.
var customer_ids := []

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
	if not events.has(key):
		events[key] = []
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
	if not ENVIRONMENT_SCENE_PATHS_BY_ID.has(location_id):
		push_warning("Invalid location_id: %s" % [location_id])
	return ENVIRONMENT_SCENE_PATHS_BY_ID.get(location_id, DEFAULT_ENVIRONMENT)


## Returns the scene path which should be loaded after this cutscene.
##
## If no destination scene path is defined, this returns the chat scene path.
func destination_environment_path() -> String:
	var result: String
	if destination_id:
		if not ENVIRONMENT_SCENE_PATHS_BY_ID.has(destination_id):
			push_warning("Invalid location_id: %s" % [location_id])
		result = ENVIRONMENT_SCENE_PATHS_BY_ID.get(destination_id, DEFAULT_ENVIRONMENT)
	else:
		result = chat_environment_path()
	return result


func reset() -> void:
	chat_key = ""
	meta = {}
	events = {}
	location_id = ""
	destination_id = ""
	spawn_locations = {}
	_position.reset()


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
			start_keys.push_back(key)
	
	if start_keys:
		# if a 'start_if' condition is met, move to that chat branch
		_position.key = start_keys[0]
		_position.index = 0
	
	if start_keys.size() >= 2:
		# if two or more 'start_if' conditions are met, report a warning
		push_warning("Multiple start_if conditions were met: %s" % [[start_keys]])


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
