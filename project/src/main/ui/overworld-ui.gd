class_name OverworldUi
extends Control
"""
UI elements for the overworld.

This includes chats, buttons and debug messages.
"""

signal chat_started

signal chat_ended

# emitted when we present the player with a dialog choice
signal showed_chat_choices

# Characters involved in the current conversation. This includes the player, instructor and any other participants. We
# try to keep them all in frame and facing each other.
var chatters := []

# If 'true' the overworld is being used to play a cutscene. If 'false' the overworld is allowing free roam.
var cutscene := false

var _show_version := true setget set_show_version, is_show_version

# These two fields store details for the upcoming level. We store the level details during the dialog sequence
# and launch the level when the dialog window closes.
var _current_chat_tree: ChatTree
var _next_chat_tree: ChatTree

# A cache of ChatTree objects representing dialog the player's seen since this scene was loaded. This prevents the
# player from cycling through the dialog over and over if you talk to a creature multiple times repetitively.
var _chat_tree_cache: Dictionary

func _ready() -> void:
	ResourceCache.substitute_singletons()
	_update_visible()
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func start_chat(new_chat_tree: ChatTree, target: Node2D) -> void:
	_current_chat_tree = new_chat_tree
	
	var new_chatters := [ChattableManager.player, target]
	var chatter_names := {}
	for chat_events_obj in new_chat_tree.events.values():
		var chat_events: Array = chat_events_obj
		for chat_event_obj in chat_events:
			var chat_event: ChatEvent = chat_event_obj
			chatter_names[chat_event.who] = true
	
	for chatter_name_obj in chatter_names:
		var chatter_name: String = chatter_name_obj
		var chatter := ChattableManager.get_creature_by_chatter_name(chatter_name)
		if chatter and not new_chatters.has(chatter):
			new_chatters.append(chatter)
	
	chatters = new_chatters
	_update_visible()
	ChattableManager.set_focus_enabled(false)
	# emit 'chat_started' event first to prepare chatters before emoting
	emit_signal("chat_started")
	
	# reset state variables
	_next_chat_tree = null
	$ChatUi.play_chat_tree(_current_chat_tree)


func set_show_version(new_show_version: bool) -> void:
	_show_version = new_show_version
	_update_visible()


func is_show_version() -> bool:
	return _show_version


"""
Turn the the active chat participants towards each other, and make them face the camera.
"""
func make_chatters_face_eachother() -> void:
	var center_of_non_player_chatters := get_center_of_chatters(
			[], [ChattableManager.player, ChattableManager.instructor])
	
	for chatter in chatters:
		if chatter == ChattableManager.player:
			# the player faces the characters they're talking to
			if chatters.size() == 1 or is_drive_by_chat():
				# simple one-line chats don't interrupt the player
				pass
			elif chatter.get_movement_mode() != Creature.IDLE:
				# the player isn't interrupted if they're running around
				pass
			else:
				chatter.orient_toward(center_of_non_player_chatters)
		elif chatter == ChattableManager.instructor:
			# the instructor faces the characters the player is talking to
			chatter.orient_toward(center_of_non_player_chatters)
		elif chatter.has_method("orient_toward"):
			# other characters orient towards the player
			chatter.orient_toward(ChattableManager.player.position)


"""
Calculates the center of the characters involved in the current conversation.

Parameters:
	'include': (Optional) characters in the current conversation will only be included if they are in this list.
	
	'exclude': (Optional) Characters in the current conversation will be excluded if they are in this list.

Returns:
	The center of the smallest rectangle including all characters in the current conversation. If no characters meet
	this criteria, this returns an zero-size rectangle at (0, 0).
"""
func get_center_of_chatters(include: Array = [], exclude: Array = []) -> Vector2:
	var bounding_box: Rect2
	
	for chatter in chatters:
		if include and not chatter in include:
			continue
		if exclude and chatter in exclude:
			continue
		if bounding_box:
			bounding_box = bounding_box.expand(chatter.position)
		else:
			bounding_box = Rect2(chatter.position, Vector2.ZERO)
	return bounding_box.position + bounding_box.size * 0.5


"""
Returns 'true' if the current chat is a quick one-liner chat.

Quick one-line chats don't interrupt the player or zoom the camera in; the player can just talk to someone and keep
running. That's why we call them 'drive by chats'.
"""
func is_drive_by_chat() -> bool:
	return _current_chat_tree.events.size() == 1


"""
Updates the different UI components to be visible/invisible based on the UI's current state.
"""
func _update_visible() -> void:
	$ChatUi.visible = true if chatters else false
	$Labels/SoutheastLabels/VersionLabel.visible = _show_version and not chatters


"""
Process a 'select_level_*' event, loading the appropriate level data or conversation to launch.
"""
func _process_select_level_meta_item(level_num: int = -1) -> void:
	var creature_chatters := []
	for chatter in chatters:
		if chatter is Creature and chatter != ChattableManager.player:
			creature_chatters.append(chatter)
	
	if creature_chatters.size() >= 2:
		push_warning("Too many (%s) creature_chatters found for select_level (%s)" \
				% [creature_chatters.size(), creature_chatters])
	elif creature_chatters.size() <= 0:
		push_warning("No creature_chatters found for select_level")
	else:
		var creature: Creature = creature_chatters[0]
		var chit_chat: bool = level_num < 1
		if not _chat_tree_cache.has(creature) or not chit_chat:
			_next_chat_tree = ChatLibrary.load_chat_events_for_creature(creature, level_num, chit_chat)
			if _next_chat_tree.meta.get("filler", false):
				PlayerData.chat_history.increment_filler_count(creature.creature_id)
			if _next_chat_tree.meta.get("notable", false):
				PlayerData.chat_history.reset_filler_count(creature.creature_id)
			_chat_tree_cache[creature] = _next_chat_tree
		
		_next_chat_tree = _chat_tree_cache[creature]
		
		if level_num >= 1:
			var level_ids := creature.get_level_ids()
			var level_id: String = level_ids[level_num - 1]
			Level.set_launched_level(level_id, creature.creature_id, level_num)


func _on_ChatUi_pop_out_completed() -> void:
	PlayerData.chat_history.add_history_item(_current_chat_tree.history_key)
	
	if _next_chat_tree:
		_current_chat_tree = _next_chat_tree
		# don't reset launched_level; this is currently set by the first of a series of chat trees
		_next_chat_tree = null
		$ChatUi.play_chat_tree(_current_chat_tree)
	else:
		# unset mood
		for chatter in chatters:
			if chatter and chatter.has_method("play_mood"):
				chatter.call("play_mood", ChatEvent.Mood.DEFAULT)
		
		chatters = []
		ChattableManager.set_focus_enabled(true)
		_update_visible()
		emit_signal("chat_ended")
		
		if Level.launched_level_id:
			ChattableManager.clear()
			Level.push_level_trail()
			
			if cutscene:
				# upon completing a puzzle, return to the level select screen
				Breadcrumb.trail.erase(Global.SCENE_OVERWORLD)


func _on_ChatUi_chat_event_played(chat_event: ChatEvent) -> void:
	make_chatters_face_eachother()
	
	# update the chatter's mood
	var chatter := ChattableManager.get_creature_by_chatter_name(chat_event.who)
	if chatter and chatter.has_method("play_mood"):
		chatter.call("play_mood", chat_event.mood)
	if chat_event.meta:
		var meta: Array = chat_event.meta
		for meta_item_obj in meta:
			var meta_item: String = meta_item_obj
			if meta_item.begins_with("select_level_"):
				_process_select_level_meta_item(int(StringUtils.substring_after(meta_item, "select_level_")))
			elif meta_item == "chit_chat":
				_process_select_level_meta_item()


func _on_ChatUi_showed_choices() -> void:
	emit_signal("showed_chat_choices")


func _on_SettingsMenu_quit_pressed() -> void:
	ChattableManager.clear()
	Breadcrumb.pop_trail()


func _on_Viewport_size_changed() -> void:
	rect_size = get_viewport_rect().size


func _on_CellPhoneButton_pressed() -> void:
	$CellPhoneMenu.show()


func _on_SettingsButton_pressed() -> void:
	$SettingsMenu.show()


func _on_TalkButton_pressed() -> void:
	if ChattableManager.get_focused():
		get_tree().set_input_as_handled()
		start_chat(ChattableManager.load_chat_events(), ChattableManager.get_focused())
