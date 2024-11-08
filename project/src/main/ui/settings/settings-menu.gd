class_name SettingsMenu
extends CanvasLayer
## Menu which lets the player adjust settings.
##
## This is meant to be overlaid over over scenes, which is why it is a CanvasLayer.

signal show
signal hide
signal give_up_confirmed
signal quit_pressed
signal other_quit_pressed

enum QuitType {
	QUIT, SAVE_AND_QUIT, GIVE_UP, SAVE_AND_QUIT_OR_GIVE_UP, RESTART_OR_GIVE_UP, QUIT_TO_DESKTOP
}

const QUIT := QuitType.QUIT
const SAVE_AND_QUIT := QuitType.SAVE_AND_QUIT
const GIVE_UP := QuitType.GIVE_UP
const SAVE_AND_QUIT_OR_GIVE_UP := QuitType.SAVE_AND_QUIT_OR_GIVE_UP
const RESTART_OR_GIVE_UP := QuitType.RESTART_OR_GIVE_UP
const QUIT_TO_DESKTOP := QuitType.QUIT_TO_DESKTOP

## Text on the menu's quit button
export (QuitType) var quit_type: int setget set_quit_type

## method name and parameters for a method to call after system data is saved
var _post_save_method: String
var _post_save_args_array: Array

onready var controller_unplugged_message := $ControllerUnpluggedMessage

onready var _controls_control := $Window/UiArea/TabContainer/Controls
onready var _save_slot_control := $Window/UiArea/TabContainer/Misc/VBoxContainer/SaveSlot
onready var _touch_control := $Window/UiArea/TabContainer/Touch

onready var _bg := $Bg
onready var _bottom := $Window/UiArea/Bottom
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
	
	_refresh_quit_type()


func set_quit_type(new_quit_type: int) -> void:
	quit_type = new_quit_type
	_refresh_quit_type()


## Shows the menu and pauses the scene tree.
func show() -> void:
	_bg.show()
	_touch_buttons.visible = true
	_dialogs.visible = true
	_window.show()
	Pauser.toggle_pause("settings-menu", true)
	emit_signal("show")


## Returns 'true' if the settings menu is currently being shown to the player.
func is_shown() -> bool:
	return _window.visible


## Hides the menu and unpauses the scene tree.
func hide() -> void:
	_bg.hide()
	_touch_buttons.visible = false
	_dialogs.visible = false
	_window.hide()
	Pauser.toggle_pause("settings-menu", false)
	emit_signal("hide")


## Prompts the player 'Are you sure you want to give up in Adventure Mode?'
func show_give_up_confirmation() -> void:
	if not is_shown():
		show()
	_dialogs.show_give_up_confirmation()


## Prompts the player for confirmation, if necessary, and saves their system settings.
##
## Confirmation is only required when changing the current save slot. If the player confirms changing their save slot,
## we drop them back on the title screen.
##
## In all other cases, either if the player is not confirmed or if they decide to not change their save slot, the
## specified 'post_save_method' is invoked to dismiss the settings menu.
##
## Parameters:
## 	'new_post_save_method': The method to use to dismiss the settings menu after data is saved.
##
## 	'new_post_save_args_array': The method parameters to use to dismiss the settings menu after data is saved.
func _confirm_and_save(new_post_save_method: String, new_post_save_args_array: Array) -> void:
	_post_save_method = new_post_save_method
	_post_save_args_array = new_post_save_args_array
	
	if _save_slot_control.get_selected_save_slot() != SystemData.misc_settings.save_slot:
		_dialogs.confirm_new_save_slot()
	else:
		if SystemData.has_unsaved_changes:
			SystemSave.save_system_data()
		hide()
		if _post_save_method:
			callv(_post_save_method, _post_save_args_array)


func _refresh_quit_type() -> void:
	if is_inside_tree():
		_bottom.quit_type = quit_type


## Loads the current save slot's data and returns the player to the splash screen.
func _load_player_data() -> void:
	PlayerSave.load_player_data()
	Breadcrumb.trail = []
	Pauser.reset()
	SceneTransition.push_trail(Global.SCENE_SPLASH)


func _on_Bottom_ok_pressed() -> void:
	# when the player confirms, we save the player's new settings
	_confirm_and_save("", [])


func _on_Bottom_quit_pressed() -> void:
	if quit_type in [GIVE_UP, RESTART_OR_GIVE_UP] \
			and PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0 \
			and SystemData.misc_settings.show_give_up_confirmation:
		show_give_up_confirmation()
	elif quit_type in [SAVE_AND_QUIT, SAVE_AND_QUIT_OR_GIVE_UP]:
		_confirm_and_save("emit_signal", ["quit_pressed"])
	else:
		hide()
		emit_signal("quit_pressed")


func _on_Bottom_other_quit_pressed() -> void:
	if quit_type == RESTART_OR_GIVE_UP \
			and PlayerData.career.is_career_mode() and CurrentLevel.attempt_count == 0 \
			and SystemData.misc_settings.show_give_up_confirmation:
		show_give_up_confirmation()
	elif quit_type == SAVE_AND_QUIT_OR_GIVE_UP:
		_confirm_and_save("emit_signal", ["other_quit_pressed"])
	else:
		hide()
		emit_signal("other_quit_pressed")


func _on_Settings_pressed() -> void:
	show()


func _on_Dialogs_change_save_cancelled() -> void:
	_save_slot_control.revert_save_slot()
	if SystemData.has_unsaved_changes:
		SystemSave.save_system_data()
	hide()
	if _post_save_method:
		callv(_post_save_method, _post_save_args_array)


func _on_Dialogs_change_save_confirmed() -> void:
	# update and save the player's save slot choice in SystemData
	SystemData.misc_settings.save_slot = _save_slot_control.get_selected_save_slot()
	SystemData.has_unsaved_changes = true
	SystemSave.save_system_data()
	
	# load the save slot contents and return the player to the splash screen
	_load_player_data()


func _on_Dialogs_delete_confirmed() -> void:
	var deleted_save_slot: int = _save_slot_control.get_selected_save_slot()
	SystemSave.delete_save_slot(deleted_save_slot)
	
	if SystemData.misc_settings.save_slot == deleted_save_slot:
		# if the player deletes the current save slot contents we return them to the splash screen
		_load_player_data()


func _on_Dialogs_give_up_confirmed() -> void:
	if SystemData.misc_settings.show_give_up_confirmation:
		SystemData.misc_settings.show_give_up_confirmation = false
		SystemData.has_unsaved_changes = true
	if SystemData.has_unsaved_changes:
		SystemSave.save_system_data()
	hide()
	emit_signal("give_up_confirmed")
