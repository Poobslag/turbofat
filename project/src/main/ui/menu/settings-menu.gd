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

# method name and parameters for a method to call after system data is saved
var _post_save_method: String
var _post_save_args_array: Array

onready var _controls_control := $Window/UiArea/TabContainer/Controls
onready var _ok_shortcut_helper := $Window/UiArea/Bottom/Ok/ShortcutHelper
onready var _save_slot_control := $Window/UiArea/TabContainer/Misc/SaveSlot
onready var _touch_control := $Window/UiArea/TabContainer/Touch
onready var _quit_button := $Window/UiArea/Bottom/Quit

onready var _bg := $Bg
onready var _dialogs := $Dialogs
onready var _touch_buttons := $TouchButtons
onready var _window := $Window

func _ready() -> void:
	# starts invisible
	hide()
	
	if OS.has_touchscreen_ui_hint():
		# hide keybinds settings for mobile devices
		_controls_control.queue_free()
	else:
		# hide touch settings if touch is not enabled
		_touch_control.queue_free()
	
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
	_bg.show()
	_touch_buttons.visible = true
	_window.show()
	get_tree().paused = true
	_old_focus_owner = $Window/UiArea/Bottom/Ok.get_focus_owner()
	$Window/UiArea/Bottom/Ok.grab_focus()
	emit_signal("show")


"""
Hides the menu and unpauses the scene tree.
"""
func hide() -> void:
	_bg.hide()
	_touch_buttons.visible = false
	_window.hide()
	get_tree().paused = false
	if _old_focus_owner:
		_old_focus_owner.grab_focus()
		_old_focus_owner = null
	emit_signal("hide")


"""
Prompts the user for confirmation, if necessary, and saves their system settings.

Confirmation is only required when changing the current save slot. If the player confirms changing their save slot, we
drop them back on the title screen.

In all other cases, either if the player is not confirmed or if they decide to not change their save slot, the
specified 'post_save_method' is invoked to dismiss the settings menu.

Parameters:
	'new_post_save_method': The method to use to dismiss the settings menu after data is saved.
	
	'new_post_save_args_array': The method parameters to use to dismiss the settings menu after data is saved.
"""
func _confirm_and_save(new_post_save_method: String, new_post_save_args_array: Array) -> void:
	_post_save_method = new_post_save_method
	_post_save_args_array = new_post_save_args_array
	
	if _save_slot_control.get_selected_save_slot() != SystemData.misc_settings.save_slot:
		_dialogs.confirm_new_save_slot()
	else:
		SystemSave.save_system_data()
		callv(_post_save_method, _post_save_args_array)


func _refresh_quit_type() -> void:
	if not is_inside_tree():
		return
	
	var quit_text := ""
	match quit_type:
		QUIT: quit_text = tr("Quit")
		SAVE_AND_QUIT: quit_text = tr("Save + Quit")
		GIVE_UP: quit_text = tr("Give Up")
	
	_quit_button.text = quit_text


func _on_Ok_pressed() -> void:
	# when the player confirms, we save the player's new settings
	_confirm_and_save("hide", [])


func _on_Quit_pressed() -> void:
	hide()
	if quit_type == SAVE_AND_QUIT:
		_confirm_and_save("emit_signal", ["quit_pressed"])
	else:
		emit_signal("quit_pressed")


func _on_Settings_pressed() -> void:
	show()


func _on_CustomKeybindButton_awaiting_changed(awaiting: bool) -> void:
	# When the user is rebinding their keys, we disable the shortcut helper. Otherwise trying to rebind something like
	# 'escape' will close the settings menu
	_ok_shortcut_helper.set_process_input(not awaiting)


func _on_Dialogs_change_save_cancelled() -> void:
	_save_slot_control.revert_save_slot()
	SystemSave.save_system_data()
	callv(_post_save_method, _post_save_args_array)


func _on_Dialogs_change_save_confirmed() -> void:
	SystemData.misc_settings.save_slot = _save_slot_control.get_selected_save_slot()
	SystemSave.save_system_data()
	
	# load the save slot's data and return to the splash screen
	PlayerSave.load_player_data()
	Breadcrumb.trail = []
	SceneTransition.push_trail(Global.SCENE_SPLASH)


func _on_Dialogs_delete_confirmed() -> void:
	SystemSave.delete_save_slot(_save_slot_control.get_selected_save_slot())
