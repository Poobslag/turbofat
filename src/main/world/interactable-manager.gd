extends Node
"""
Tracks Spira's location and the location of all interactables. Handles questions like 'which interactable is focused'
and 'which interactables are nearby'.
"""

# Signal emitted when focus changes to a new object, or when all objects are unfocused.
signal focus_changed

# Maximum range for Spira to successfully interact with an object
const MAX_INTERACT_DISTANCE := 50.0

# Chat appearance for different characters
var _accent_defs := {
	"Spira": {"accent_scale":0.66,"accent_swapped":true,"accent_texture":13,"color":"b23823"}
}

# The player's sprite
var _spira: Spira setget set_spira

# A list of all interactable objects which can be focused and interacted with
var _interactables := []

# The currently focused object
var _focused: Spatial setget ,get_focused

# 'false' if the player is temporarily disallowed from interacting with nearby objects, such as while chatting
var _focus_enabled := true setget set_focus_enabled, is_focus_enabled

func _physics_process(_delta: float) -> void:
	var min_distance := MAX_INTERACT_DISTANCE
	var new_focus: Spatial

	if _focus_enabled and _spira and _interactables:
		# iterate over all interactables and find the nearest one
		for interactable_object in _interactables:
			if not is_instance_valid(interactable_object):
				continue
			var interactable: Spatial = interactable_object
			var distance := interactable.global_transform.origin.distance_to(_spira.global_transform.origin)
			if distance <= min_distance:
				min_distance = distance
				new_focus = interactable
	
	if new_focus != _focused:
		_focused = new_focus
		emit_signal("focus_changed")


"""
Purges all node instances from the manager.

Because InteractableManager is a singleton, node instances must be purged before changing scenes. Otherwise it's
possible for an invisible object from a previous scene to receive focus.
"""
func clear() -> void:
	_spira = null
	_interactables.clear()
	_focused = null


func set_spira(spira: Spira) -> void:
	_spira = spira


"""
Adds an overworld object which Spira can interact with.
"""
func add_interactable(interactable: Spatial) -> void:
	_interactables.append(interactable)


"""
Returns the overworld object which the player will currently interact with if they hit the button.
"""
func get_focused() -> Spatial:
	return _focused


"""
Returns 'true' if the player will currently interact with the specified object if they hit the button.
"""
func is_focused(interactable: Spatial) -> bool:
	return interactable == _focused


"""
Globally enables/disables focus for nearby objects.

Regardless of whether or not the focused object changed, this notifies all listeners with a 'focus_changed' event.
This is because some UI elements render themselves differently during chats when the player can't interact with
anything.
"""
func set_focus_enabled(focus_enabled: bool) -> void:
	_focus_enabled = focus_enabled
	
	if not _focus_enabled:
		_focused = null
		# when focus is globally disabled, chat icons vanish. emit a signal to notify listeners
		emit_signal("focus_changed")


"""
Returns 'true' if focus is globally enabled/disabled for all objects.
"""
func is_focus_enabled() -> bool:
	return _focus_enabled


"""
Returns the overworld object which has the specified 'chat name'.

During dialog sequences, we sometimes need to know which overworld object corresponds to the person saying the current
dialog line. This function facilitates that.
"""
func get_chatter(chat_name: String) -> Spatial:
	var chatter: Spatial
	if chat_name == "Spira":
		chatter = _spira
	else:
		for interactable in _interactables:
			var spatial: Spatial = interactable
			if interactable.has_meta("chat_name") and interactable.get_meta("chat_name") == chat_name:
				chatter = interactable
				break
	return chatter


"""
Returns the accent definition for the overworld object which has the specified 'chat name'.
"""
func get_accent_def(chat_name: String) -> Dictionary:
	if chat_name and not _accent_defs.has(chat_name):
		# refresh our cache of accent definitions
		for interactable in _interactables:
			if interactable.has_meta("chat_name") and interactable.has_meta("accent_def"):
				add_accent_def(interactable.get_meta("chat_name"), interactable.get_meta("accent_def"))
	
		if not _accent_defs.has(chat_name):
			# report a warning and store a stub definition to prevent repeated errors
			_accent_defs[chat_name] = {}
			push_error("Missing accent_def for interactable '%s'" % chat_name)
	
	return _accent_defs.get(chat_name, {})


func add_accent_def(chat_name: String, accent_def: Dictionary) -> void:
	_accent_defs[chat_name] = accent_def
