class_name OverworldUi
extends CanvasLayer
"""
UI elements for the overworld.

This includes chats, buttons and debug messages.
"""

signal chat_started
signal chat_ended

# emitted when we launch a creature's talk animation
signal chatter_talked(chatter)

# emitted when the player talks to a creature for the first time, caching their dialog
signal chat_cached(chattable)

# emitted when we present the player with a dialog choice
signal showed_chat_choices

# Characters involved in the current conversation. This includes the player, sensei and any other participants. We
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
	_refresh_rect_size()
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func start_chat(new_chat_tree: ChatTree, target: Node2D) -> void:
	_current_chat_tree = new_chat_tree
	
	var new_chatters := [ChattableManager.player, target]
	var chatter_ids := {}
	for chat_events_obj in new_chat_tree.events.values():
		var chat_events: Array = chat_events_obj
		for chat_event_obj in chat_events:
			var chat_event: ChatEvent = chat_event_obj
			chatter_ids[chat_event.who] = true
	
	for chatter_id_obj in chatter_ids:
		var chatter_id: String = chatter_id_obj
		var chatter := ChattableManager.get_creature_by_id(chatter_id)
		if chatter and not new_chatters.has(chatter):
			new_chatters.append(chatter)
	
	chatters = new_chatters
	_update_visible()
	ChattableManager.set_focus_enabled(false)
	# emit 'chat_started' event first to prepare chatters before emoting
	emit_signal("chat_started")
	
	# reset state variables
	_next_chat_tree = null
	$Control/ChatUi.play_chat_tree(_current_chat_tree)


func set_show_version(new_show_version: bool) -> void:
	_show_version = new_show_version
	_update_visible()


func is_show_version() -> bool:
	return _show_version


"""
Turn the the active chat participants towards each other, and make them face the camera.
"""
func make_chatters_face_eachother() -> void:
	var chatter_bounding_box := get_chatter_bounding_box(
			[], [ChattableManager.player, ChattableManager.sensei])
	var center_of_non_player_chatters := chatter_bounding_box.position + chatter_bounding_box.size * 0.5
	
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
		elif chatter == ChattableManager.sensei:
			# the sensei faces the characters the player is talking to
			chatter.orient_toward(center_of_non_player_chatters)
		elif chatter.has_method("orient_toward"):
			# other characters orient towards the player
			chatter.orient_toward(ChattableManager.player.position)


"""
Calculates the bounding box of the characters involved in the current conversation.

Parameters:
	'include': (Optional) characters in the current conversation will only be included if they are in this list.
	
	'exclude': (Optional) Characters in the current conversation will be excluded if they are in this list.

Returns:
	The smallest rectangle including all characters in the current conversation. If no characters meet this criteria,
	this returns an zero-size rectangle at (0, 0).
"""
func get_chatter_bounding_box(include: Array = [], exclude: Array = []) -> Rect2:
	var bounding_box: Rect2
	
	for chatter in chatters:
		if include and not chatter in include:
			continue
		if exclude and chatter in exclude:
			continue
		if not chatter.visible:
			continue
		if bounding_box:
			bounding_box = bounding_box.expand(chatter.position)
		else:
			bounding_box = Rect2(chatter.position, Vector2.ZERO)
	return bounding_box


"""
Returns 'true' if the current chat is a quick one-liner chat.

Quick one-line chats don't interrupt the player or zoom the camera in; the player can just talk to someone and keep
running. That's why we call them 'drive by chats'.
"""
func is_drive_by_chat() -> bool:
	return not _current_chat_tree.can_advance()


func is_chatting() -> bool:
	return not chatters.empty()


"""
Updates the different UI components to be visible/invisible based on the UI's current state.
"""
func _update_visible() -> void:
	$Control/ChatUi.visible = true if chatters else false
	$Control/Labels/SoutheastLabels/VersionLabel.visible = _show_version and not chatters


func _refresh_rect_size() -> void:
	$Control.rect_size = $Control.get_viewport_rect().size


"""
Returns the level id (if any) corresponding to the curently focused chattable.

This is relevant when the player talks to a creature with a food speech bubble.
"""
func _focused_chattable_level_id() -> String:
	var focused_creature: Creature = ChattableManager.focused_chattable as Creature
	if not focused_creature:
		return ""
	
	return LevelLibrary.first_unfinished_level_id_for_creature(focused_creature.creature_id)


"""
Returns the chat tree corresponding to the curently focused chattable.

This is relevant when the player talks to a creature with a non-food speech bubble.
"""
func _focused_chattable_chat_tree() -> ChatTree:
	var focused_chattable := ChattableManager.focused_chattable
	if not focused_chattable:
		return null
	
	if not _chat_tree_cache.has(focused_chattable):
		var chat_tree := ChattableManager.load_chat_tree()
		if chat_tree and focused_chattable is Creature:
			if chat_tree.meta.get("filler", false):
				PlayerData.chat_history.increment_filler_count(focused_chattable.creature_id)
			if chat_tree.meta.get("notable", false):
				PlayerData.chat_history.reset_filler_count(focused_chattable.creature_id)
		emit_signal("chat_cached", focused_chattable)
		_chat_tree_cache[focused_chattable] = chat_tree
	return _chat_tree_cache[focused_chattable]


func _on_ChatUi_pop_out_completed() -> void:
	PlayerData.chat_history.add_history_item(_current_chat_tree.history_key)
	
	if _next_chat_tree:
		_current_chat_tree = _next_chat_tree
		# don't reset launched_level; this is currently set by the first of a series of chat trees
		_next_chat_tree = null
		$Control/ChatUi.play_chat_tree(_current_chat_tree)
	else:
		# unset mood
		for chatter in chatters:
			if chatter and chatter.has_method("play_mood"):
				chatter.call("play_mood", ChatEvent.Mood.DEFAULT)
		
		chatters = []
		ChattableManager.set_focus_enabled(true)
		_update_visible()
		emit_signal("chat_ended")
		
		if Breadcrumb.trail.size() >= 2 and Breadcrumb.trail[1] == Global.SCENE_CUTSCENE_DEMO:
			# don't launch the level; go back to CutsceneDemo after playing the cutscene
			SceneTransition.pop_trail()
		elif CurrentLevel.level_state == CurrentLevel.LevelState.BEFORE:
			# pre-level dialog or pre-level cutscene finished playing
			
			if cutscene:
				# remove redundant overworld cutscenes from the breadcrumb trail
				Breadcrumb.trail.remove(0)
			
			CurrentLevel.push_level_trail()
		elif CurrentLevel.level_state == CurrentLevel.LevelState.AFTER:
			# ending cutscene finished playing
			CurrentLevel.clear_launched_level()
			SceneTransition.pop_trail()


func _on_ChatUi_chat_event_played(chat_event: ChatEvent) -> void:
	make_chatters_face_eachother()
	
	for meta_item_obj in chat_event.meta:
		var meta_item: String = meta_item_obj
		if meta_item.begins_with("creature-enter "):
			var creature_id := StringUtils.substring_after(meta_item, "creature-enter ")
			var entering_creature := ChattableManager.get_creature_by_id(creature_id)
			entering_creature.fade_in()
		if meta_item.begins_with("creature-exit "):
			var creature_id := StringUtils.substring_after(meta_item, "creature-exit ")
			var exiting_creature := ChattableManager.get_creature_by_id(creature_id)
			exiting_creature.fade_out()
	
	# update the chatter's mood
	var chatter := ChattableManager.get_creature_by_id(chat_event.who)
	if chatter and chatter.has_method("play_mood"):
		chatter.call("play_mood", chat_event.mood)
	if chatter and StringUtils.has_letter(chat_event.text):
		chatter.talk()
		emit_signal("chatter_talked", chatter)


func _on_ChatUi_showed_choices() -> void:
	emit_signal("showed_chat_choices")
	ChattableManager.player.ui_has_focus = true


func _on_ChatUi_chat_choice_chosen(_chat_choice: int) -> void:
	ChattableManager.player.ui_has_focus = false


func _on_SettingsMenu_quit_pressed() -> void:
	SceneTransition.pop_trail()


func _on_Viewport_size_changed() -> void:
	_refresh_rect_size()


func _on_CellPhoneButton_pressed() -> void:
	$Control/CellPhoneMenu.show()


func _on_SettingsButton_pressed() -> void:
	$Control/SettingsMenu.show()


"""
When the player hits the 'talk' button we either launch a level or start a chat.
"""
func _on_TalkButton_pressed() -> void:
	var focused_chattable := ChattableManager.focused_chattable
	if not focused_chattable:
		return
	
	get_tree().set_input_as_handled()
	
	var level_id := _focused_chattable_level_id()
	var chat_tree := _focused_chattable_chat_tree()
	var pushed_cutscene_trail := false
	
	CurrentLevel.set_launched_level(level_id)
	if level_id:
		# launch a cutscene if necessary
		pushed_cutscene_trail = CurrentLevel.push_cutscene_trail()
	
	if chat_tree and not pushed_cutscene_trail:
		# if no cutscene was launched, start a chat
		start_chat(chat_tree, ChattableManager.focused_chattable)
	
	if not chat_tree and not pushed_cutscene_trail:
		# if no chat was launched, start a level
		CurrentLevel.push_level_trail()


func _on_CellPhoneMenu_show() -> void:
	ChattableManager.player.ui_has_focus = true


func _on_CellPhoneMenu_hide() -> void:
	ChattableManager.player.ui_has_focus = false


func _on_SettingsMenu_show() -> void:
	ChattableManager.player.ui_has_focus = true


func _on_SettingsMenu_hide() -> void:
	ChattableManager.player.ui_has_focus = false
