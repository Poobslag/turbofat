extends Control
"""
Overlays 2D UI elements over the 3D world.

This includes chats, buttons and debug messages.
"""

var _show_fps := false setget set_show_fps, is_show_fps
var _show_version := true setget set_show_version, is_show_version
var _chatting := false

func _ready() -> void:
	_update_visible()


func _process(delta) -> void:
	if _chatting:
		if Input.is_action_just_pressed("interact"):
			end_chat()
	else:
		if Input.is_action_just_pressed("interact"):
			if InteractableManager.get_focused():
				start_chat()


func start_chat() -> void:
	_chatting = true
	InteractableManager.set_focus_enabled(false)
	_update_visible()
	$ChatUi.play_text(
		"Bort",
		"I think you're doing a great job.\n./././I'm looking forward to our first real conversation!",
		{"accent_scale":1.3,"accent_texture":0,"color":"6f83db"})


func end_chat() -> void:
	_chatting = false
	# The 'pop out' takes a moment. OverworldUi updates its state in _on_ChatUi_pop_out_completed()
	$ChatUi.pop_out()


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
	InteractableManager.set_focus_enabled(true)
	_update_visible()
