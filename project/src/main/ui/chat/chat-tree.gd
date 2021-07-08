class_name ChatTree
"""
Tree of chat events the player can page through.

The tree includes a root node with one or more branches, each of which is associated with a key. Branches can redirect
to each other by referencing these keys. Chat lines start on the '' (empty string) branch.
"""

class Position:
	"""
	Current position in a chat tree.
	"""
	
	# The key of the chat branch being navigated.
	var key := ""
	
	# How far we are along the chat branch.
	var index := 0
	
	func _to_string() -> String:
		return ("(%s:%s)" % [key, index]) if key else ("(%s)" % index)
	
	
	func reset() -> void:
		key = ""
		index = 0

# Current version for saved chat data. Should be updated if and only if the chat format breaks backwards
# compatibility. This version number follows a 'ymdh' hex date format which is documented in issue #234.
const CHAT_DATA_VERSION := "1922"

# Scene paths corresponding to different ChatTree.location_id values
const LOCATION_SCENE_PATHS_BY_ID := {
	"indoors": "res://src/main/world/OverworldIndoors.tscn",
	"outdoors": "res://src/main/world/Overworld.tscn"
}

# unique key to identify this conversation in the chat history
var history_key: String

# metadata including whether the chat event is 'filler' or 'notable'
var meta: Dictionary

# tree of chat event objects
# key: chat id (String)
# value: array of sequential ChatEvent objects for a particular chat sequence
var events := {}

# a specific location where this conversation takes place, if any
var location_id: String

# Spawn locations for different creatures, if this ChatTree represents a cutscene. Spawn locations prefixed with a '!'
# indicate that the creature should spawn invisible.
#
# key: creature id
# value: spawn id
var spawn_locations := {}

# current position in this chat tree
var _position := Position.new()

"""
Adds a chat event to a new chat branch, or appends it to an existing branch.

Parameters:
	'key': The key of the chat branch to append to.
	
	'event': The chat event to append.
"""
func append(key: String, event: ChatEvent) -> void:
	if not events.has(key):
		events[key] = []
	events[key].append(event)


"""
Returns the chat event at the current position.
"""
func get_event() -> ChatEvent:
	return events[_position.key][_position.index]


"""
Advances the chat position deeper into the tree.

This can either involve navigating further down the current branch, or navigating to a new branch if any links are
available.

Returns 'true' if the position was advanced successfully, or 'false' if we hit a dead end. A dead end can indicate
that the chat tree cannot be advanced any further and the window should close.

Parameters:
	'link_index': Which chat branch to follow. This parameter is optional, and is ignored if the chat tree does not
		branch.
"""
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
	skip_unmet_conditions()
	return did_increment


"""
Skip any dialog lines whose 'say_if' conditions are unmet.

This is automatically called when dialog is advanced, but should manually be called before the first get_event() call
as well.
"""
func skip_unmet_conditions() -> void:
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


"""
Returns 'true' if the chat position can be advanced deeper into the tree.
"""
func can_advance() -> bool:
	var can_increment := false
	if get_event().links and events.has(get_event().links[-1]):
		# can reset to beginning of a new chat branch
		can_increment = true
	elif _position.index + 1 < events[_position.key].size():
		# can advance through the current chat branch
		can_increment = true
	return can_increment


func cutscene_scene_path() -> String:
	return LOCATION_SCENE_PATHS_BY_ID.get(location_id, Global.SCENE_OVERWORLD)


func reset() -> void:
	history_key = ""
	meta = {}
	events = {}
	location_id = ""
	spawn_locations = {}
	_position.reset()
