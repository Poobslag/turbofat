extends Node
"""
Tracks Spira's location and the location of all chattables. Handles questions like 'which chattable is focused' and
'which chattables are nearby'.
"""

# emitted when focus changes to a new object, or when all objects are unfocused.
signal focus_changed

# Maximum range for Spira to successfully interact with an object
const MAX_INTERACT_DISTANCE := 240.0

# Chat appearance for different characters
var _chat_theme_defs: Dictionary

# The player's sprite
var spira: Spira setget set_spira

# The currently focused object
var _focused: Node2D setget ,get_focused

# 'false' if the player is temporarily disallowed from interacting with nearby objects, such as while chatting
var _focus_enabled := true setget set_focus_enabled, is_focus_enabled

func _physics_process(_delta: float) -> void:
	var min_distance := MAX_INTERACT_DISTANCE
	var new_focus: Node2D

	if _focus_enabled and spira:
		# iterate over all chattables and find the nearest one
		for chattable_obj in get_tree().get_nodes_in_group("chattables"):
			if not is_instance_valid(chattable_obj):
				continue
			if spira == chattable_obj:
				continue
			var chattable: Node2D = chattable_obj
			var distance: float = Global.from_iso(chattable.global_transform.origin) \
					.distance_to(Global.from_iso(spira.global_transform.origin))
			if distance <= min_distance:
				min_distance = distance
				new_focus = chattable
	
	if new_focus != _focused:
		_focused = new_focus
		emit_signal("focus_changed")

"""
Loads the chat events for the currently focused chatter.

Returns an array of ChatEvent objects for the dialog sequence which the player should see.
"""
func load_chat_events() -> ChatTree:
	var chat_tree: ChatTree
	var focused: Node = get_focused()
	if focused.has_meta("chat_path"):
		var chat_path: String = focused.get_meta("chat_path")
		chat_tree = ChatLibrary.load_chat_events_from_file(chat_path)
	else:
		# can't look up chat events without a chat_path; return an empty array
		push_warning("Chattable %s does not define a 'chat_path' property." % focused)
	return chat_tree


"""
Purges all node instances from the manager.

Because ChattableManager is a singleton, node instances must be purged before changing scenes. Otherwise it's
possible for an invisible object from a previous scene to receive focus.
"""
func clear() -> void:
	spira = null
	_focused = null


func set_spira(new_spira: Spira) -> void:
	spira = new_spira
	add_chat_theme_def(spira.get_meta("chat_name"), spira.get_meta("chat_theme_def"))


"""
Returns the overworld object which the player will currently interact with if they hit the button.
"""
func get_focused() -> Node2D:
	return _focused


"""
Returns 'true' if the player will currently interact with the specified object if they hit the button.
"""
func is_focused(chattable: Node2D) -> bool:
	return chattable == _focused


"""
Globally enables/disables focus for nearby objects.

Regardless of whether or not the focused object changed, this notifies all listeners with a 'focus_changed' event.
This is because some UI elements render themselves differently during chats when the player can't interact with
anything.
"""
func set_focus_enabled(new_focus_enabled: bool) -> void:
	_focus_enabled = new_focus_enabled
	
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
func get_chatter(chat_name: String) -> Node2D:
	var chatter: Node2D
	if chat_name == "Spira":
		chatter = spira
	else:
		for chattable_obj in get_tree().get_nodes_in_group("chattables"):
			var chattable: Node = chattable_obj
			if chattable.is_class("Node2D") and chattable.has_meta("chat_name") \
					and chattable.get_meta("chat_name") == chat_name:
				chatter = chattable
				break
	return chatter


"""
Returns the accent definition for the overworld object which has the specified 'chat name'.
"""
func get_chat_theme_def(chat_name: String) -> Dictionary:
	if chat_name and not _chat_theme_defs.has(chat_name):
		# refresh our cache of accent definitions
		for chattable in get_tree().get_nodes_in_group("chattables"):
			if chattable.has_meta("chat_name") and chattable.has_meta("chat_theme_def"):
				add_chat_theme_def(chattable.get_meta("chat_name"), chattable.get_meta("chat_theme_def"))
	
		if not _chat_theme_defs.has(chat_name):
			# report a warning and store a stub definition to prevent repeated errors
			_chat_theme_defs[chat_name] = {}
			push_error("Missing chat_theme_def for chattable '%s'" % chat_name)
	
	return _chat_theme_defs.get(chat_name, {})


func add_chat_theme_def(chat_name: String, chat_theme_def: Dictionary) -> void:
	_chat_theme_defs[chat_name] = chat_theme_def
