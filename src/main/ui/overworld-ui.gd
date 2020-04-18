extends Control
"""
Overlays 2D UI elements over the 3D world.

This includes conversations, buttons and debug messages.
"""

var _show_fps := false setget set_show_fps, is_show_fps
var _show_version := true setget set_show_version, is_show_version
var conversation_active := false

func _ready() -> void:
	_update_visible()


func _process(delta) -> void:
	if conversation_active:
		if Input.is_action_just_pressed("interact"):
			end_conversation()
	else:
		if Input.is_action_just_pressed("interact"):
			if InteractableManager.get_focused():
				start_conversation()


func start_conversation() -> void:
	conversation_active = true
	InteractableManager.set_focus_enabled(false)
	_update_visible()
	$ConversationControl.play_text(
		"What!?\n./././I don't know what you're talking about.\nGo bother someone else!",
		{"accent_swapped":false,"accent_scale":1.3,"accent_texture":0,"color":"6f83db"})


func end_conversation() -> void:
	conversation_active = false
	InteractableManager.set_focus_enabled(true)
	_update_visible()


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
	$ConversationControl.visible = conversation_active
	$FpsLabel.visible = _show_fps and not conversation_active
	$VersionLabel.visible = _show_version and not conversation_active


func _on_PuzzleButton_pressed() -> void:
	InteractableManager.clear()
	get_tree().change_scene("res://src/main/ui/ScenarioMenu.tscn")
