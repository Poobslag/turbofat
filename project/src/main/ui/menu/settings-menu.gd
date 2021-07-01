class_name SettingsMenu
extends CanvasLayer
"""
Menu which lets the player adjust settings.

This is meant to be overlaid over over scenes, which is why it is a CanvasLayer.
"""

signal show
signal hide
signal quit_pressed

enum QuitType {
	QUIT, SAVE_AND_QUIT, GIVE_UP
}

const QUIT := QuitType.QUIT
const SAVE_AND_QUIT := QuitType.SAVE_AND_QUIT
const GIVE_UP := QuitType.GIVE_UP

# The text on the menu's quit button
export (QuitType) var quit_type: int setget set_quit_type

# the UI control which was focused before this settings menu popped up
var _old_focus_owner: Control

func _ready() -> void:
	# starts invisible
	hide()
	
	if OS.has_touchscreen_ui_hint():
		# hide keybinds settings for mobile devices
		$Window/UiArea/TabContainer/Controls.queue_free()
	else:
		# hide touch settings if touch is not enabled
		$Window/UiArea/TabContainer/Touch.queue_free()
	
	var custom_keybind_buttons := get_tree().get_nodes_in_group("custom_keybind_buttons")
	for keybind_button in custom_keybind_buttons:
		keybind_button.connect("awaiting_changed", self, "_on_CustomKeybindButton_awaiting_changed")
	_refresh_quit_type()


func set_quit_type(new_quit_type: int) -> void:
	quit_type = new_quit_type
	_refresh_quit_type()


"""
Shows the menu and pauses the scene tree.
"""
func show() -> void:
	$Bg.show()
	$TouchButtons.visible = true
	$Window.show()
	get_tree().paused = true
	_old_focus_owner = $Window/UiArea/Bottom/Ok.get_focus_owner()
	$Window/UiArea/Bottom/Ok.grab_focus()
	emit_signal("show")


"""
Hides the menu and unpauses the scene tree.
"""
func hide() -> void:
	$Bg.hide()
	$TouchButtons.visible = false
	$Window.hide()
	get_tree().paused = false
	if _old_focus_owner:
		_old_focus_owner.grab_focus()
		_old_focus_owner = null
	emit_signal("hide")


func _refresh_quit_type() -> void:
	if not is_inside_tree():
		return
	
	var quit_text := ""
	match quit_type:
		QUIT: quit_text = tr("Quit")
		SAVE_AND_QUIT: quit_text = tr("Save + Quit")
		GIVE_UP: quit_text = tr("Give Up")
	
	$Window/UiArea/Bottom/Quit.text = quit_text


func _on_Ok_pressed() -> void:
	# when the player confirms, we save the player's new settings
	PlayerSave.save_player_data()
	hide()


func _on_Quit_pressed() -> void:
	hide()
	if quit_type == SAVE_AND_QUIT:
		PlayerSave.save_player_data()
	emit_signal("quit_pressed")


func _on_Settings_pressed() -> void:
	show()


func _on_CustomKeybindButton_awaiting_changed(awaiting: bool) -> void:
	# when the user is rebinding their keys, we disable the shortcut helper. otherwise trying to rebind something like
	# 'escape' will close the settings menu
	$Window/UiArea/Bottom/Ok/ShortcutHelper.set_process_input(!awaiting)
