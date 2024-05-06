class_name OverworldUi
extends CanvasLayer
## UI elements for the overworld.
##
## This includes chats, buttons and debug messages.

signal chat_started
signal chat_ended

## emitted when we launch a creature's talk animation
signal chatter_talked(chatter)

## emitted when a chat event is played containing metadata
##
## Parameters:
## 	'meta_item': (String) Single meta item
signal chat_event_meta_played(meta_item)

## emitted when creatures enter or exit a conversation
signal visible_chatters_changed

## emitted when we present the player with a chat choice
signal showed_chat_choices

export (NodePath) var overworld_environment_path: NodePath setget set_overworld_environment_path

## Characters involved in the current conversation. This includes the player, sensei and any other participants. We
## try to keep them all in frame and facing each other.
var chatters := []

## true if there is an active chat tree
var chatting := false

var _show_version := true setget set_show_version, is_show_version

## These two fields store details for the upcoming level. We store the level details during the chat sequence
## and launch the level when the chat window closes.
var _current_chat_tree: ChatTree

var _overworld_environment: OverworldEnvironment

onready var _chat_ui := $ChatUi

func _ready() -> void:
	ResourceCache.substitute_singletons()
	_refresh_overworld_environment_path()
	_update_visible()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func set_overworld_environment_path(new_overworld_environment_path: NodePath) -> void:
	overworld_environment_path = new_overworld_environment_path
	_refresh_overworld_environment_path()


## Plays the specified chat tree.
##
## Parameters:
## 	'new_chat_tree': The chat tree to play.
func start_chat(new_chat_tree: ChatTree) -> void:
	_current_chat_tree = new_chat_tree
	
	chatters = _find_creatures_in_chat_tree(new_chat_tree)
	chatting = true
	
	# We always add the player and target to the list of chatters. The player might talk to someone who says a
	# one-liner, but the camera should still include the player. The player might also 'talk' to an inanimate object
	# which doesn't talk back, but the camera should still include the object.
	if _overworld_environment.player:
		chatters.append(_overworld_environment.player)
	
	_update_visible()
	# emit 'chat_started' event first to prepare chatters before emoting
	emit_signal("chat_started")
	
	# reset state variables
	$ChatUi.play_chat_tree(_current_chat_tree)


func set_show_version(new_show_version: bool) -> void:
	_show_version = new_show_version
	_update_visible()


func is_show_version() -> bool:
	return _show_version


## Calculates the bounding box of the characters involved in the current conversation.
##
## Parameters:
## 	'include': (Optional) characters in the current conversation will only be included if they are in this list.
##
## 	'exclude': (Optional) Characters in the current conversation will be excluded if they are in this list.
##
## Returns:
## 	The smallest rectangle including all characters in the current conversation. If no characters meet this criteria,
## 	this returns an zero-size rectangle at (0, 0).
func get_chatter_bounding_box(include: Array = [], exclude: Array = []) -> Rect2:
	var bounding_box: Rect2
	
	for chatter in chatters:
		if include and not chatter in include:
			continue
		if exclude and chatter in exclude:
			continue
		if not chatter.visible:
			continue
		
		var adjusted_chatter_position: Vector2 = chatter.position
		if "elevation" in chatter:
			adjusted_chatter_position += chatter.elevation * Vector2.UP * Global.CREATURE_SCALE
		if bounding_box:
			var chat_extents: Vector2 = chatter.chat_extents if "chat_extents" in chatter else Vector2.ZERO
			var chatter_box := Rect2(adjusted_chatter_position - chat_extents / 2, chat_extents)
			bounding_box = bounding_box.merge(chatter_box)
		else:
			bounding_box = Rect2(adjusted_chatter_position, Vector2.ZERO)
	return bounding_box


func _refresh_overworld_environment_path() -> void:
	if not is_inside_tree():
		return
	
	if not _chat_ui:
		return
	
	_overworld_environment = \
			get_node(overworld_environment_path) if overworld_environment_path else null
	
	_chat_ui.overworld_environment_path = \
			_chat_ui.get_path_to(_overworld_environment) if overworld_environment_path else NodePath()


func _find_creatures_in_chat_tree(chat_tree: ChatTree) -> Array:
	var creatures := []
	# calculate which creature ids are involved in this chat
	var chatter_ids := {}
	for chat_events_obj in chat_tree.events.values():
		var chat_events: Array = chat_events_obj
		for chat_event_obj in chat_events:
			var chat_event: ChatEvent = chat_event_obj
			chatter_ids[chat_event.who] = true
	
	# find the creatures associated with the creature ids
	for chatter_id in chatter_ids:
		var chatter: Creature = _overworld_environment.get_creature_by_id(chatter_id)
		if chatter and not creatures.has(chatter):
			creatures.append(chatter)
	
	return creatures


## Updates the different UI components to be visible/invisible based on the UI's current state.
func _update_visible() -> void:
	$ChatUi.visible = true if chatting else false
	$Labels/SoutheastLabels/VersionLabel.visible = _show_version and not chatting


## Applies the specified ChatEvent metadata to the scene.
##
## ChatEvents can include metadata making creatures appear, disappear, laugh or turn around. This method locates the
## creature referenced by the metadata and performs the appropriate action.
##
## Parameters:
## 	'chat_event': (Unused) Chat event whose metadata should be applied. This is unused by OverworldUi but can be
## 		utilized by subclasses who extend this method.
##
## 	'meta_item': The metadata item to apply.
func _apply_chat_event_meta(_chat_event: ChatEvent, meta_item: String) -> void:
	var meta_item_split := meta_item.split(" ")
	match(meta_item_split[0]):
		"next_scene":
			# schedule another cutscene to happen after this cutscene
			var next_scene_key := meta_item_split[1]
			var next_scene_chat_tree: ChatTree = ChatLibrary.chat_tree_for_key(next_scene_key)
			# insert the chat tree to ensure it happens before any enqueued levels
			PlayerData.cutscene_queue.insert_cutscene(0, next_scene_chat_tree)
		"creature_enter":
			var creature_id := meta_item_split[1]
			var creature: Creature = _overworld_environment.get_creature_by_id(creature_id)
			creature.fade_in()
			emit_signal("visible_chatters_changed")
		"creature_exit":
			var creature_id := meta_item_split[1]
			var creature: Creature = _overworld_environment.get_creature_by_id(creature_id)
			creature.fade_out()
			if not creature.is_connected("fade_out_finished", self, "_on_Creature_fade_out_finished"):
				creature.connect("fade_out_finished", self, "_on_Creature_fade_out_finished", [creature])
		"creature_mood":
			var creature_id: String = meta_item_split[1]
			var creature: Creature = _overworld_environment.get_creature_by_id(creature_id)
			var mood: int = int(meta_item_split[2])
			creature.play_mood(mood)
		"creature_orientation":
			var creature_id: String = meta_item_split[1]
			var creature: Creature = _overworld_environment.get_creature_by_id(creature_id)
			var orientation: int = int(meta_item_split[2])
			creature.set_orientation(orientation)
		"play_credits":
			# the credits lead directly into the main menu, so we immediately end the current career day and advance
			# the calendar.
			PlayerData.career.hours_passed = Careers.HOURS_PER_CAREER_DAY
			PlayerData.career.advance_calendar()
			PlayerSave.schedule_save()
			
			PlayerData.cutscene_queue.insert_credits(0)
	
	emit_signal("chat_event_meta_played", meta_item)


func _on_ChatUi_chat_finished() -> void:
	chatting = false
	PlayerData.chat_history.add_history_item(_current_chat_tree.chat_key)
	CurrentCutscene.clear_launched_cutscene()
	if not CurrentCutscene.chat_tree \
			and Breadcrumb.trail.size() >= 2 and Breadcrumb.trail[1] in [Global.SCENE_CUTSCENE_DEMO]:
		# go back to CutsceneDemo after playing the cutscene
		if PlayerData.cutscene_queue.is_front_cutscene():
			PlayerData.cutscene_queue.replace_trail()
		else:
			SceneTransition.pop_trail()
	elif PlayerData.career.is_career_mode():
		# launch the next scene in career mode after playing the cutscene
		PlayerData.career.push_career_trail()
		
		# save data to record the cutscene as viewed
		PlayerSave.schedule_save()
	else:
		push_warning("Unexpected state after chat finished: %s" % [Breadcrumb.trail])
		SceneTransition.pop_trail()
	emit_signal("chat_ended")


func _on_ChatUi_chat_event_played(chat_event: ChatEvent) -> void:
	for meta_item in chat_event.meta:
		# Apply the chat event's metadata. This can make creatures appear, disappear, laugh or turn around
		_apply_chat_event_meta(chat_event, meta_item)
	
	# update the chatter's mood
	var chatter: Creature = _overworld_environment.get_creature_by_id(chat_event.who)
	if chatter and chatter.has_method("play_mood"):
		chatter.call("play_mood", chat_event.mood)
	if chatter and StringUtils.has_non_parentheses_letter(chat_event.text):
		chatter.talk()
		emit_signal("chatter_talked", chatter)


func _on_Creature_fade_out_finished(_creature: Creature) -> void:
	if _creature.is_connected("fade_out_finished", self, "_on_Creature_fade_out_finished"):
		_creature.disconnect("fade_out_finished", self, "_on_Creature_fade_out_finished")
	emit_signal("visible_chatters_changed")


func _on_ChatUi_showed_choices() -> void:
	emit_signal("showed_chat_choices")


func _on_SettingsMenu_quit_pressed() -> void:
	SceneTransition.pop_trail()


func _on_SettingsButton_pressed() -> void:
	$SettingsMenu.show()


func _on_OverworldWorld_overworld_environment_changed(value: OverworldEnvironment) -> void:
	set_overworld_environment_path(get_path_to(value))
