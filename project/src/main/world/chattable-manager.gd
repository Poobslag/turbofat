extends Node
"""
Tracks the player's location and the location of all chattables. Handles questions like 'which chattable is focused'
and 'which chattables are nearby'.
"""

# emitted when focus changes to a new object, or when all objects are unfocused.
signal focus_changed

# Maximum range for the player to successfully interact with an object
const MAX_INTERACT_DISTANCE := 240.0

# Chat appearance for different characters
var _chat_theme_defs: Dictionary

# The player's sprite
var player: Player setget set_player

# The sensei's sprite
var sensei: Sensei setget set_sensei

# The overworld object which the player will currently interact with if they hit the button
var focused_chattable: Node2D setget set_focused_chattable

# 'false' if the player is temporarily disallowed from interacting with nearby objects, such as while chatting
var _focus_enabled := true setget set_focus_enabled, is_focus_enabled

# Mapping from chatter names to Creature objects. The player and sensei are omitted from this mapping, as the
# player can set their own name and it could conflict with overworld creatures.
#
# key: chatter name as it appears in dialog files
# value: Creature object corresponding to the chatter name 
var _creatures_by_chatter_name := {}

func _physics_process(_delta: float) -> void:
	var min_distance := MAX_INTERACT_DISTANCE
	var new_focused_chattable: Node2D

	if _focus_enabled and player:
		# iterate over all chattables and find the nearest one
		for chattable_obj in get_tree().get_nodes_in_group("chattables"):
			if not is_instance_valid(chattable_obj):
				continue
			if player == chattable_obj:
				continue
			var chattable: Node2D = chattable_obj
			
			var chattable_pos: Vector2 = chattable.global_transform.origin
			var player_pos: Vector2 = player.global_transform.origin
			
			if "chat_extents" in chattable:
				# if the chattable object has extents, we measure from its closest point
				var new_chattable_pos := chattable_pos
				new_chattable_pos.x += clamp(player_pos.x - chattable_pos.x,
						-chattable.chat_extents.x, chattable.chat_extents.x)
				new_chattable_pos.y += clamp(player_pos.y - chattable_pos.y,
						-chattable.chat_extents.y, chattable.chat_extents.y)
				chattable_pos = new_chattable_pos
			
			var distance: float = Global.from_iso(chattable_pos).distance_to(Global.from_iso(player_pos))
			if distance <= min_distance:
				min_distance = distance
				new_focused_chattable = chattable
	
	if new_focused_chattable != focused_chattable:
		set_focused_chattable(new_focused_chattable)


"""
Refreshes our state based on the creatures in the scene, and reconnects some signals.
"""
func refresh_creatures() -> void:
	_creatures_by_chatter_name.clear()
	for creature_obj in get_tree().get_nodes_in_group("creatures"):
		var creature: Creature = creature_obj
		_refresh_creature_name(creature)
		if not creature.is_connected("creature_name_changed", self, "_on_Creature_creature_name_changed"):
			creature.connect("creature_name_changed", self, "_on_Creature_creature_name_changed", [creature])


"""
Returns the Creature object corresponding to the specified chatter name.

A name of SENSEI_ID or PLAYER_ID will return the sensei or player object. To avoid
conflicts, the sensei or player cannot be retrieved by their actual name.
"""
func get_creature_by_chatter_name(chatter_name: String) -> Creature:
	var result: Creature
	match chatter_name:
		Global.SENSEI_ID: result = ChattableManager.sensei
		Global.PLAYER_ID: result = ChattableManager.player
		_:
			if _creatures_by_chatter_name.has(chatter_name):
				result = _creatures_by_chatter_name[chatter_name]
	return result


"""
Loads the chat events for the currently focused chattable.

Returns an array of ChatEvent objects for the dialog sequence which the player should see.
"""
func load_chat_events() -> ChatTree:
	var chat_tree: ChatTree
	if focused_chattable is Creature:
		chat_tree = ChatLibrary.load_chat_events_for_creature(focused_chattable)
	elif focused_chattable.has_meta("chat_path"):
		var chat_path: String = focused_chattable.get_meta("chat_path")
		chat_tree = ChatLibrary.load_chat_events_from_file(chat_path)
	else:
		# can't look up chat events without a chat_path; return an empty array
		push_warning("Chattable %s does not define a 'chat_path' property." % focused_chattable)
	return chat_tree


"""
Purges all node instances from the manager.

Because ChattableManager is a singleton, node instances must be purged before changing scenes. Otherwise it's
possible for an invisible object from a previous scene to receive focus.
"""
func clear() -> void:
	player = null
	focused_chattable = null


func set_player(new_player: Player) -> void:
	player = new_player
	_remove_from_creatures_by_chatter_name(player)
	add_chat_theme_def(Global.PLAYER_ID, player.get_meta("chat_theme_def"))


func set_sensei(new_sensei: Sensei) -> void:
	sensei = new_sensei
	_remove_from_creatures_by_chatter_name(sensei)
	add_chat_theme_def(Global.SENSEI_ID, sensei.get_meta("chat_theme_def"))


func set_focused_chattable(new_focused_chattable: Node2D) -> void:
	if focused_chattable == new_focused_chattable:
		return
	
	focused_chattable = new_focused_chattable
	emit_signal("focus_changed")


"""
Returns 'true' if the player will currently interact with the specified object if they hit the button.
"""
func is_focused(chattable: Node2D) -> bool:
	return chattable == focused_chattable


"""
Globally enables/disables focus for nearby objects.

Regardless of whether or not the focused object changed, this notifies all listeners with a 'focus_changed' event.
This is because some UI elements render themselves differently during chats when the player can't interact with
anything.
"""
func set_focus_enabled(new_focus_enabled: bool) -> void:
	_focus_enabled = new_focus_enabled
	
	if not _focus_enabled:
		set_focused_chattable(null)


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
	if chat_name == Global.PLAYER_ID:
		chatter = player
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


"""
Substitutes variables in player-visible text.

Text variables are pound sign delimited: 'Hello #player#'. This matches the syntax of Tracery.
"""
func substitute_variables(string: String, full_name: bool = false) -> String:
	var result := string
	if full_name:
		result = result.replace(Global.PLAYER_ID, PlayerData.creature_library.player_def.creature_name)
	else:
		result = result.replace(Global.PLAYER_ID, PlayerData.creature_library.player_def.creature_short_name)
	result = result.replace(Global.SENSEI_ID,
			PlayerData.creature_library.sensei_def.creature_short_name)
	return result


"""
Remove the specified creature from the '_creatures_by_chatter_name' mapping.
"""
func _remove_from_creatures_by_chatter_name(creature: Creature) -> void:
	for key in _creatures_by_chatter_name:
		if _creatures_by_chatter_name[key] == creature:
			_creatures_by_chatter_name.erase(key)


"""
Updates a creature's entry in the '_creatures_by_chatter_name' mapping.
"""
func _refresh_creature_name(creature: Creature) -> void:
	if creature == player or creature == sensei:
		# don't store player or sensei in the 'players by name' table, as it might conflict with other creatures
		return
	
	if creature.creature_name:
		_creatures_by_chatter_name[creature.creature_name] = creature
	if creature.creature_short_name:
		_creatures_by_chatter_name[creature.creature_short_name] = creature


func _on_Creature_creature_name_changed(creature: Creature) -> void:
	_refresh_creature_name(creature)
