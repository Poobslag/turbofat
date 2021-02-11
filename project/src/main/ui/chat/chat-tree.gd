class_name ChatTree
"""
Tree of chat events the player can page through.

The tree includes a root node with one or more branches, each of which is associated with a key. Branches can redirect
to each other by referencing these keys. Dialog starts on the '' (empty string) branch.
"""

class Position:
	"""
	Current position in a dialog tree.
	"""
	
	# The key of the dialog branch being navigated.
	var key := ""
	
	# How far we are along the dialog branch.
	var index := 0
	
	func _to_string():
		return ("(%s:%s)" % [key, index]) if key else ("(%s)" % index)

# Current version for saved dialog data. Should be updated if and only if the dialog format breaks backwards
# compatibility. This version number follows a 'ymdh' hex date format which is documented in issue #234.
const DIALOG_DATA_VERSION := "1922"

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
# key: dialog id (String)
# value: array of sequential ChatEvent objects for a particular dialog sequence
var events: Dictionary = {}

# a specific location where this conversation takes place, if any
var location_id: String

# Spawn locations for different creatures, if this ChatTree represents a cutscene. Spawn locations prefixed with a '!'
# indicate that the creature should spawn invisible.
#
# key: creature id
# value: spawn id
var spawn_locations: Dictionary = {}

# current position in this dialog tree
var _position := Position.new()

"""
Adds a chat event to a new dialog branch, or appends it to an existing branch.

Parameters:
	'key': The key of the dialog branch to append to.
	
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
that the dialog cannot be advanced any further and the window should close.

Parameters:
	'link_index': Which dialog branch to follow. This parameter is optional, and is ignored if the dialog does not
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
	return did_increment


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


func from_json_dict(json: Dictionary) -> void:
	for key in json.keys():
		match key:
			"version":
				if json[key] != DIALOG_DATA_VERSION:
					push_warning("Unrecognized dialog data version: '%s'" % [json[key]])
			"meta":
				meta = json[key]
			"location":
				location_id = json[key].get("location_id", "")
				spawn_locations = json[key].get("spawn_locations", {})
			_:
				for json_chat_event in json[key]:
					var event := ChatEvent.new()
					event.from_json_dict(json_chat_event)
					append(key, event)
