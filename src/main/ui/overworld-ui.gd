extends Control
"""
Overlays 2D UI elements over the 3D world.

This includes chats, buttons and debug messages.
"""

var _show_fps := false setget set_show_fps, is_show_fps
var _show_version := true setget set_show_version, is_show_version
var _chatting := false
var _chat_library := ChatLibrary.new()

var _interact_pressed := false

func _ready() -> void:
	_update_visible()


func _input(event: InputEvent) -> void:
	if not _chatting and event.is_action_pressed("interact") and InteractableManager.get_focused():
		get_tree().set_input_as_handled()
		start_chat()


func start_chat() -> void:
	var chat_events := _chat_library.load_chat_events()
	if not chat_events:
		push_warning("Failed to load chat events for %s." % InteractableManager.get_focused())
		return
	
	_chatting = true
	_update_visible()
	InteractableManager.set_focus_enabled(false)
	$ChatUi.play_dialog_sequence(chat_events)


func set_show_fps(show_fps: bool) -> void:
	_show_fps = show_fps
	_update_visible()


func is_show_fps() -> bool:
	return _show_fps


func set_show_version(show_version: bool) -> void:
	_show_version = show_version
	_update_visible()


func is_show_version() -> bool:
	return _show_version


"""
Updates the different UI components to be visible/invisible based on the UI's current state.
"""
func _update_visible() -> void:
	$ChatUi.visible = _chatting
	$FpsLabel.visible = _show_fps and not _chatting
	$VersionLabel.visible = _show_version and not _chatting


func _on_PuzzleButton_pressed() -> void:
	InteractableManager.clear()
	get_tree().change_scene("res://src/main/ui/ScenarioMenu.tscn")


func _on_ChatUi_pop_out_completed():
	_chatting = false
	InteractableManager.set_focus_enabled(true)
	_update_visible()

