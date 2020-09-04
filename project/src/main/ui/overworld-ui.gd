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

# Characters we're currently chatting with. We try to keep them all in frame and facing the player.
var chatters := []

var _show_version := true setget set_show_version, is_show_version

# These two fields store details for the upcoming scenario. We store the scenario details during the dialog sequence
# and launch the scenario when the dialog window closes.
var _launched_scenario: ScenarioSettings
var _current_chat_tree: ChatTree
var _next_chat_tree: ChatTree
var _scenario_dna: Dictionary

func _ready() -> void:
	_update_visible()
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")


func _input(event: InputEvent) -> void:
	if not chatters and event.is_action_pressed("interact") and ChattableManager.get_focused():
		get_tree().set_input_as_handled()
		start_chat()
	if not chatters and event.is_action_pressed("ui_menu"):
		$SettingsMenu.show()
		get_tree().set_input_as_handled()


func start_chat() -> void:
	_current_chat_tree = ChattableManager.load_chat_events()
	chatters = [ChattableManager.get_focused()]
	_update_visible()
	ChattableManager.set_focus_enabled(false)
	make_chatters_face_eachother()
	# emit 'chat_started' event first to prepare chatters before emoting
	emit_signal("chat_started")
	
	# reset state variables
	_launched_scenario = null
	_scenario_dna = {}
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
	# make the player face the other characters
	if chatters.size() >= 1:
		if ChattableManager.player.get_movement_mode() == Creature.IDLE:
			# let the player move while chatting, unless she's asked a question
			ChattableManager.player.orient_toward(chatters[0])

	# make the other characters face the player
	for chatter in chatters:
		if chatter.has_method("orient_toward"):
			# other characters must orient towards the player to avoid visual glitches when emoting while moving
			chatter.orient_toward(ChattableManager.player)


"""
Updates the different UI components to be visible/invisible based on the UI's current state.
"""
func _update_visible() -> void:
	$ChatUi.visible = true if chatters else false
	$Labels/SoutheastLabels/VersionLabel.visible = _show_version and not chatters


"""
Process a 'scenario-*' event, loading the appropriate scenario data to launch.
"""
func _process_scenario_meta_item(meta_item: String) -> void:
	var scenario := StringUtils.substring_after(meta_item, "scenario_")
	var settings := ScenarioSettings.new()
	settings.load_from_resource(scenario)
	_launched_scenario = settings
	if chatters[0].has_meta("dna"):
		_scenario_dna = chatters[0].get_meta("dna")


"""
Process a 'select_level_*' event, loading the appropriate scenario data or conversation to launch.
"""
func _process_select_level_meta_item(meta_item: String) -> void:
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
		var level_int := int(StringUtils.substring_after(meta_item, "select_level_"))
		var creature: Creature = creature_chatters[0]
		_next_chat_tree = ChatLibrary.load_chat_events_for_creature(creature, level_int)
		if _next_chat_tree.meta.get("filler", false):
			PlayerData.chat_history.increment_filler_count(creature.creature_id)
		if _next_chat_tree.meta.get("notable", false):
			PlayerData.chat_history.reset_filler_count(creature.creature_id)
		
		var settings := ScenarioSettings.new()
		settings.load_from_creature(creature, level_int)
		_launched_scenario = settings
		_scenario_dna = creature.get_meta("dna")


func _on_ChatUi_pop_out_completed() -> void:
	PlayerData.chat_history.add_history_item(_current_chat_tree.history_key)
	
	if _next_chat_tree:
		_current_chat_tree = _next_chat_tree
		# don't reset launched_scenario; this is currently set by the first of a series of chat trees
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
		
		if _launched_scenario:
			ChattableManager.clear()
			Scenario.overworld_puzzle = true
			Scenario.push_scenario_trail(_launched_scenario, _scenario_dna)


func _on_ChatUi_chat_event_played(chat_event: ChatEvent) -> void:
	make_chatters_face_eachother()
	
	# update the chatter's mood
	var chatter := ChattableManager.get_chatter(chat_event.who)
	if chatter and chatter.has_method("play_mood"):
		chatter.call("play_mood", chat_event.mood)
	if chat_event.meta:
		var meta: Array = chat_event.meta
		for meta_item_obj in meta:
			var meta_item: String = meta_item_obj
			if meta_item.begins_with("scenario_"):
				_process_scenario_meta_item(meta_item)
			if meta_item.begins_with("select_level_"):
				_process_select_level_meta_item(meta_item)


func _on_ChatUi_showed_choices() -> void:
	emit_signal("showed_chat_choices")


func _on_SettingsMenu_quit_pressed() -> void:
	ChattableManager.clear()
	Breadcrumb.pop_trail()


func _on_Viewport_size_changed() -> void:
	rect_size = get_viewport_rect().size
