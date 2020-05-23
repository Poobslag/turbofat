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

# tree of chat events
var events: Dictionary = {}

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
	if get_event().links:
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
Populates this object with json data.
"""
func from_dict(json: Dictionary) -> void:
	for key in json.keys():
		for json_chat_event in json[key]:
			var event := ChatEvent.new()
			event.from_dict(json_chat_event)
			append(key, event)
