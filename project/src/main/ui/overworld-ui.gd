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

# Characters we're currently chatting with. We try to keep them all in frame and facing Spira.
var chatters := []

var _show_version := true setget set_show_version, is_show_version
var _chat_library := ChatLibrary.new()

# These two fields store details for the upcoming scenario. We store the scenario details during the dialog sequence
# and launch the scenario when the dialog window closes.
var _launched_scenario: ScenarioSettings
var _scenario_creature_def: Dictionary

func _ready() -> void:
	_update_visible()


func _input(event: InputEvent) -> void:
	if not chatters and event.is_action_pressed("interact") and ChattableManager.get_focused():
		get_tree().set_input_as_handled()
		start_chat()
	if not chatters and event.is_action_pressed("ui_menu"):
		$SettingsMenu.show()
		get_tree().set_input_as_handled()


func start_chat() -> void:
	var chat_tree := _chat_library.load_chat_events()
	
	chatters = [ChattableManager.get_focused()]
	_update_visible()
	ChattableManager.set_focus_enabled(false)
	make_chatters_face_eachother()
	$ChatUi.play_chat_tree(chat_tree)
	emit_signal("chat_started")


func set_show_version(new_show_version: bool) -> void:
	_show_version = new_show_version
	_update_visible()


func is_show_version() -> bool:
	return _show_version


"""
Turn the the active chat participants towards each other, and make them face the camera.
"""
func make_chatters_face_eachother() -> void:
	# make spira face the other characters
	if chatters.size() >= 1:
		ChattableManager.spira.orient_toward(chatters[0])
	
	# make the other characters face spira
	for chatter in chatters:
		if chatter.has_method("orient_toward"):
			chatter.orient_toward(ChattableManager.spira)


"""
Updates the different UI components to be visible/invisible based on the UI's current state.
"""
func _update_visible() -> void:
	$ChatUi.visible = true if chatters else false
	$Labels/SoutheastLabels/VersionLabel.visible = _show_version and not chatters


func _on_ChatUi_pop_out_completed() -> void:
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
		Scenario.push_scenario_trail(_launched_scenario, _scenario_creature_def)


func _on_ChatUi_chat_event_played(chat_event: ChatEvent) -> void:
	make_chatters_face_eachother()
	
	# update the chatter's mood
	var chatter := ChattableManager.get_chatter(chat_event.who)
	if chatter and chatter.has_method("play_mood"):
		chatter.call("play_mood", chat_event.mood)
	if chat_event.meta:
		var meta: Array = chat_event.meta
		var scenario: String
		for meta_item_obj in meta:
			var meta_item: String = meta_item_obj
			if meta_item.begins_with("scenario-"):
				scenario = StringUtils.substring_after(meta_item, "scenario-")
		if scenario:
			var settings := ScenarioSettings.new()
			settings.load_from_resource(scenario)
			_launched_scenario = settings
			if chatters[0].has_meta("creature_def"):
				_scenario_creature_def = chatters[0].get_meta("creature_def")


func _on_ChatUi_showed_choices() -> void:
	emit_signal("showed_chat_choices")


func _on_SettingsMenu_quit_pressed() -> void:
	ChattableManager.clear()
	Breadcrumb.pop_trail()
