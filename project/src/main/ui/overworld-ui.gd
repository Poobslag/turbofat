class_name OverworldUi
extends CanvasLayer
## UI elements for the overworld.
##
## This includes chats, buttons and debug messages.

signal chat_started
signal chat_ended

## emitted when we launch a creature's talk animation
signal chatter_talked(chatter)

## emitted when the player talks to a creature for the first time, caching their chat
signal chat_cached(chattable)

## emitted when creatures enter or exit a conversation
signal visible_chatters_changed()

## emitted when we present the player with a chat choice
signal showed_chat_choices

## when starting an inplace conversation, all participants must be within this
## radius. Otherwise a separate cutscene will launch.
const MAX_INPLACE_CHAT_DISTANCE := 600

## Characters involved in the current conversation. This includes the player, sensei and any other participants. We
## try to keep them all in frame and facing each other.
var chatters := []

## If 'true' the overworld is being used to play a cutscene. If 'false' the overworld is allowing free roam.
var cutscene := false

var _show_version := true setget set_show_version, is_show_version

## These two fields store details for the upcoming level. We store the level details during the chat sequence
## and launch the level when the chat window closes.
var _current_chat_tree: ChatTree

## A cache of ChatTree objects representing chat the player's seen since this scene was loaded. This prevents the
## player from cycling through the chat over and over if you talk to a creature multiple times repetitively.
var _chat_tree_cache: Dictionary

func _ready() -> void:
	ResourceCache.substitute_singletons()
	_update_visible()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func start_chat(new_chat_tree: ChatTree, target: Node2D) -> void:
	_current_chat_tree = new_chat_tree
	
	chatters = _find_creatures_in_chat_tree(new_chat_tree)
	
	# We always add the player and target to the list of chatters. The player might talk to someone who says a
	# one-liner, but the camera should still include the player. The player might also 'talk' to an inanimate object
	# which doesn't talk back, but the camera should still include the object.
	if ChattableManager.player:
		chatters.append(ChattableManager.player)
	if target:
		chatters.append(target)
	
	_assign_nametag_sides(new_chat_tree)
	
	_update_visible()
	ChattableManager.set_focus_enabled(false)
	# emit 'chat_started' event first to prepare chatters before emoting
	emit_signal("chat_started")
	
	# reset state variables
	$Control/ChatUi.play_chat_tree(_current_chat_tree)


func set_show_version(new_show_version: bool) -> void:
	_show_version = new_show_version
	_update_visible()


func is_show_version() -> bool:
	return _show_version


## Turn the the active chat participants towards each other, and make them face the camera.
func make_chatters_face_eachother() -> void:
	var chatter_bounding_box: Rect2
	chatter_bounding_box = get_chatter_bounding_box([], [ChattableManager.player, ChattableManager.sensei])
	if not chatter_bounding_box:
		# for conversations between the player and the sensei, the sensei faces their midpoint
		chatter_bounding_box = get_chatter_bounding_box([], [])
		
	var center_of_non_player_chatters := chatter_bounding_box.position + chatter_bounding_box.size * 0.5
	
	for chatter in chatters:
		if chatter == ChattableManager.player:
			# the player faces the characters they're talking to
			if chatters.size() == 1 or is_drive_by_chat():
				# simple one-line chats don't interrupt the player
				pass
			elif chatter.get_movement_mode() != Creatures.IDLE:
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
		if bounding_box:
			var chat_extents: Vector2 = chatter.chat_extents if "chat_extents" in chatter else Vector2.ZERO
			var chatter_box := Rect2(chatter.position - chat_extents / 2, chat_extents)
			bounding_box = bounding_box.merge(chatter_box)
		else:
			bounding_box = Rect2(chatter.position, Vector2.ZERO)
	return bounding_box


## Returns 'true' if the current chat is a quick one-liner chat.
##
## Quick one-line chats don't interrupt the player or zoom the camera in; the player can just talk to someone and keep
## running. That's why we call them 'drive by chats'.
func is_drive_by_chat() -> bool:
	return not _current_chat_tree.can_advance()


func is_chatting() -> bool:
	return not chatters.empty()


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
		var chatter: Creature = ChattableManager.get_creature_by_id(chatter_id)
		if chatter and not creatures.has(chatter):
			creatures.append(chatter)
	
	return creatures


## Assign nametag sides for each chat line.
##
## We calculate the midpoint of the chatters. Creatures to the right of the midpoint have their nametags on the right.
## Creatures to the left have their nametags on the left.
##
## This information is stored back into the chat tree so that it can be utilized by the chat ui.
func _assign_nametag_sides(new_chat_tree: ChatTree) -> void:
	var chatter_bounding_box := get_chatter_bounding_box([], [])
	var center_of_chatters: Vector2 = chatter_bounding_box.position + chatter_bounding_box.size * 0.5
	
	for chat_events_obj in new_chat_tree.events.values():
		var chat_events: Array = chat_events_obj
		for chat_event_obj in chat_events:
			var chat_event: ChatEvent = chat_event_obj
			if not chat_event.who:
				continue
			var chatter: Creature = ChattableManager.get_creature_by_id(chat_event.who)
			if not chatter:
				continue
			if chatter.position.x > center_of_chatters.x:
				chat_event.nametag_side = ChatEvent.NametagSide.RIGHT
			else:
				chat_event.nametag_side = ChatEvent.NametagSide.LEFT


## Updates the different UI components to be visible/invisible based on the UI's current state.
func _update_visible() -> void:
	$Control/ChatUi.visible = true if chatters else false
	$Control/Labels/SoutheastLabels/VersionLabel.visible = _show_version and not chatters


## Returns the chat tree corresponding to the curently focused chattable.
##
## This is relevant when the player talks to a creature with a non-food speech bubble.
func _focused_chattable_chat_tree() -> ChatTree:
	var focused_chattable: Node2D = ChattableManager.focused_chattable
	if not focused_chattable:
		return null
	
	if not _chat_tree_cache.has(focused_chattable):
		var chat_tree: ChatTree = ChattableManager.load_chat_tree()
		if chat_tree and ChattableManager.focused_chattable is Creature:
			if chat_tree.meta.get("filler", false):
				PlayerData.chat_history.increment_filler_count(ChattableManager.focused_chattable_creature_id())
			if chat_tree.meta.get("notable", false):
				PlayerData.chat_history.reset_filler_count(ChattableManager.focused_chattable_creature_id())
		emit_signal("chat_cached", focused_chattable)
		_chat_tree_cache[focused_chattable] = chat_tree
	return _chat_tree_cache[focused_chattable]


## Applies the specified ChatEvent metadata to the scene.
##
## ChatEvents can include metadata making creatures appear, disappear, laugh or turn around. This method locates the
## creature referenced by the metadata and performs the appropriate action.
##
## Parameters:
## 	'chat_event': (Unused) The chat event whose metadata should be applied. This is unused by OverworldUi but can be
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
			CutsceneManager.insert_chat_tree(0, next_scene_chat_tree)
		"creature_enter":
			var creature_id := meta_item_split[1]
			var creature: Creature = ChattableManager.get_creature_by_id(creature_id)
			creature.fade_in()
			emit_signal("visible_chatters_changed")
		"creature_exit":
			var creature_id := meta_item_split[1]
			var creature: Creature = ChattableManager.get_creature_by_id(creature_id)
			creature.fade_out()
			creature.connect("fade_out_finished", self, "_on_Creature_fade_out_finished", [creature])
		"creature_mood":
			var creature_id: String = meta_item_split[1]
			var creature: Creature = ChattableManager.get_creature_by_id(creature_id)
			var mood: int = int(meta_item_split[2])
			creature.play_mood(mood)
		"creature_orientation":
			var creature_id: String = meta_item_split[1]
			var creature: Creature = ChattableManager.get_creature_by_id(creature_id)
			var orientation: int = int(meta_item_split[2])
			creature.set_orientation(orientation)


func _start_cutscene(chat_tree: ChatTree) -> void:
	CutsceneManager.enqueue_chat_tree(chat_tree)
	
	if cutscene:
		# if we're already in a cutscene, we replace the current scene
		CutsceneManager.replace_cutscene_trail()
	else:
		# if we're not in a cutscene, we push the cutscene on top of the overworld scene
		CutsceneManager.push_cutscene_trail()


func _on_ChatUi_chat_finished() -> void:
	PlayerData.chat_history.add_history_item(_current_chat_tree.chat_key)
	
	if not CutsceneManager.is_front_chat_tree() \
			and Breadcrumb.trail.size() >= 2 and Breadcrumb.trail[1] == Global.SCENE_CUTSCENE_DEMO:
		# don't launch the level; go back to CutsceneDemo after playing the cutscene
		SceneTransition.pop_trail()
	elif cutscene:
		if Breadcrumb.trail[1] == Global.SCENE_CUTSCENE_DEMO:
			# don't modify the breadcrumb path; we're not returning to the overworld after
			pass
		else:
			# modify the overworld path and spawn IDs to preserve the player's position from the cutscene
			var new_scene_path := _current_chat_tree.destination_scene_path()
			Breadcrumb.trail[1] = new_scene_path
			
			if _current_chat_tree.destination_scene_path() == _current_chat_tree.chat_scene_path():
				# preserve spawn ids from cutscene
				CutsceneManager.assign_player_spawn_ids(_current_chat_tree)
			else:
				# erase spawn IDs to avoid 'could not locate spawn' warnings when playing multiple cutscenes
				# consecutively
				Global.player_spawn_id = ""
				Global.sensei_spawn_id = ""
		
		if CutsceneManager.is_front_level_id():
			# continue to a level (preroll cutscene finished playing)
			
			# [menu > overworld_1 > cutscene] -> [menu > overworld_2 > puzzle]
			Breadcrumb.trail.remove(0)
			CurrentLevel.level_id = CutsceneManager.pop_level_id()
			CurrentLevel.piece_speed = ""
			CurrentLevel.push_level_trail()
		elif CutsceneManager.is_front_chat_tree():
			# continue to another cutscene (first of multiple cutscenes finished playing)
			
			# [menu > overworld > cutscene_1] -> [menu > overworld > cutscene_2]
			CutsceneManager.replace_cutscene_trail()
		else:
			# return to the overworld (postroll/misc cutscene finished playing)
			
			# [menu > overworld_1 > cutscene] -> [menu > overworld_2]
			SceneTransition.pop_trail()
			
			# immediately save the player data. the player might quit from the overworld, but we want to save
			# their progress
			PlayerSave.save_player_data()
	elif CurrentLevel.level_id:
		# continue to a level (non-cutscene pre-level dialog finished playing)
		
		# [menu > overworld_1] -> [menu > overworld_2 > puzzle]
		CurrentLevel.push_level_trail()
	else:
		# if we're in a regular overworld conversation and not a cutscene,
		# restore the ui so the player can interact again
		chatters = []
		emit_signal("chat_ended")
		ChattableManager.set_focus_enabled(true)
		_update_visible()


func _on_ChatUi_chat_event_played(chat_event: ChatEvent) -> void:
	if cutscene:
		# don't automatically orient characters during cutscenes
		pass
	elif chat_event.is_thought():
		# don't automatically orient characters in response to the player's thoughts
		pass
	else:
		make_chatters_face_eachother()
	
	for meta_item in chat_event.meta:
		# Apply the chat event's metadata. This can make creatures appear, disappear, laugh or turn around
		_apply_chat_event_meta(chat_event, meta_item)
	
	# update the chatter's mood
	var chatter: Creature = ChattableManager.get_creature_by_id(chat_event.who)
	if chatter and chatter.has_method("play_mood"):
		chatter.call("play_mood", chat_event.mood)
	if chatter and StringUtils.has_letter(chat_event.text):
		chatter.talk()
		emit_signal("chatter_talked", chatter)


func _on_Creature_fade_out_finished(_creature: Creature) -> void:
	emit_signal("visible_chatters_changed")


func _on_ChatUi_showed_choices() -> void:
	emit_signal("showed_chat_choices")
	if ChattableManager.player is Player:
		ChattableManager.player.ui_has_focus = true


func _on_ChatUi_chat_choice_chosen(_chat_choice: int) -> void:
	if ChattableManager.player is Player:
		ChattableManager.player.ui_has_focus = false


func _on_SettingsMenu_quit_pressed() -> void:
	SceneTransition.pop_trail()


func _on_CellPhoneButton_pressed() -> void:
	$Control/CellPhoneMenu.show()


func _on_SettingsButton_pressed() -> void:
	$Control/SettingsMenu.show()


## When the player hits the 'talk' button we either launch a level or start a chat.
func _on_TalkButton_pressed() -> void:
	var focused_chattable: Node2D = ChattableManager.focused_chattable
	if not focused_chattable:
		return
	
	get_tree().set_input_as_handled()
	var level_id: String = ChattableManager.focused_chattable_level_id()
	if level_id:
		# launch a level and start a chat or cutscene
		CurrentLevel.set_launched_level(level_id)
		
		var chat_tree: ChatTree = ChatLibrary.chat_tree_for_preroll(CurrentLevel.level_id)
		if not CurrentLevel.should_play_cutscene(chat_tree):
			# if there is no cutscene/chat, or if the cutscene should be skipped, skip to the level
			CurrentLevel.push_level_trail()
		elif not chat_tree.location_id:
			# if no location change is necessary, start a chat
			start_chat(chat_tree, ChattableManager.focused_chattable)
		else:
			# if a location change is necessary, launch a cutscene
			CutsceneManager.enqueue_chat_tree(chat_tree)
			CutsceneManager.enqueue_level(level_id)
			
			if cutscene:
				# if we're already in a cutscene, we replace the current scene
				CutsceneManager.replace_cutscene_trail()
			else:
				# if we're not in a cutscene, we push the cutscene on top of the overworld scene
				CutsceneManager.push_cutscene_trail()
	else:
		var chat_tree := _focused_chattable_chat_tree()
		if not chat_tree.location_id:
			# if no location change is necessary, start a chat
			start_chat(chat_tree, ChattableManager.focused_chattable)
		elif chat_tree.location_id and chat_tree.meta.get("inplace", false):
			# 'inplace' chats do not require a scene change as long as all participants are nearby
			
			# verify the characters involved in the chat tree
			var creature_ids := chat_tree.spawn_locations.keys()
			var max_distance := 0
			
			# verify the distance of the characters in the chat tree
			for creature_id in creature_ids:
				var creature: Creature = ChattableManager.get_creature_by_id(creature_id)
				var distance: float
				if not creature:
					distance = 999999
				else:
					distance = Global.from_iso(ChattableManager.player.position) \
							.distance_to(Global.from_iso(creature.position))
				max_distance = max(distance, max_distance)
			
			if max_distance < MAX_INPLACE_CHAT_DISTANCE:
				# if all chat participants are nearby, start a chat
				start_chat(chat_tree, ChattableManager.focused_chattable)
			else:
				# if some chat participants are far away or absent, launch a cutscene
				_start_cutscene(chat_tree)
		else:
			# if a location change is necessary, launch a cutscene
			_start_cutscene(chat_tree)


func _on_CellPhoneMenu_show() -> void:
	if ChattableManager.player is Player:
		ChattableManager.player.ui_has_focus = true


func _on_CellPhoneMenu_hide() -> void:
	if ChattableManager.player is Player:
		ChattableManager.player.ui_has_focus = false


func _on_SettingsMenu_show() -> void:
	if ChattableManager.player is Player:
		ChattableManager.player.ui_has_focus = true


func _on_SettingsMenu_hide() -> void:
	if ChattableManager.player is Player:
		ChattableManager.player.ui_has_focus = false
