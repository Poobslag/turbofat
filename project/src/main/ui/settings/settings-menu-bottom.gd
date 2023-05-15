extends Control
## Bottom area of the settings menu with the OK and Quit buttons

signal ok_pressed
signal quit_pressed
signal other_quit_pressed

## Text on the menu's quit button
var quit_type: int setget set_quit_type

## UI control which was focused before this settings menu popped up
var _old_focus_owner: Control

onready var _ok_button := $HBoxContainer/VBoxContainer2/Holder/Ok
onready var _ok_shortcut_helper := $HBoxContainer/VBoxContainer2/Holder/Ok/ShortcutHelper
onready var _quit_button := $HBoxContainer/VBoxContainer1/Holder2/Quit2
onready var _other_quit_button := $HBoxContainer/VBoxContainer1/Holder1/Quit1

func _ready() -> void:
	var custom_keybind_buttons := get_tree().get_nodes_in_group("custom_keybind_buttons")
	for keybind_button in custom_keybind_buttons:
		keybind_button.connect("awaiting_changed", self, "_on_CustomKeybindButton_awaiting_changed")
	
	_refresh_quit_type()


func set_quit_type(new_quit_type: int) -> void:
	quit_type = new_quit_type
	_refresh_quit_type()


func _refresh_quit_type() -> void:
	var quit_text := ""
	var other_quit_text := ""
	match quit_type:
		SettingsMenu.QuitType.QUIT: quit_text = tr("Quit")
		SettingsMenu.QuitType.SAVE_AND_QUIT: quit_text = tr("Save + Quit")
		SettingsMenu.QuitType.GIVE_UP: quit_text = tr("Give Up")
		SettingsMenu.QuitType.SAVE_AND_QUIT_OR_GIVE_UP:
			quit_text = tr("Save + Quit")
			other_quit_text = tr("Give Up")
	
	_quit_button.text = quit_text
	_other_quit_button.text = other_quit_text
	
	if other_quit_text:
		rect_min_size.y = 100
		rect_size.y = 100
		$HBoxContainer/VBoxContainer1/Holder1.visible = true
		$HBoxContainer/VBoxContainer2/Spacer.visible = true
		$HBoxContainer/VBoxContainer3/Spacer.visible = true
	else:
		rect_min_size.y = 50
		rect_size.y = 50
		$HBoxContainer/VBoxContainer1/Holder1.visible = false
		$HBoxContainer/VBoxContainer2/Spacer.visible = false
		$HBoxContainer/VBoxContainer3/Spacer.visible = false


func _on_CustomKeybindButton_awaiting_changed(awaiting: bool) -> void:
	# When the user is rebinding their keys, we disable the shortcut helper. Otherwise trying to rebind something like
	# 'escape' will close the settings menu
	_ok_shortcut_helper.set_process_input(not awaiting)


func _on_SettingsMenu_show() -> void:
	_old_focus_owner = _ok_button.get_focus_owner()
	_ok_button.grab_focus()


func _on_SettingsMenu_hide() -> void:
	if _old_focus_owner:
		_old_focus_owner.grab_focus()
		_old_focus_owner = null


func _on_Quit_pressed() -> void:
	emit_signal("quit_pressed")


func _on_OtherQuit_pressed() -> void:
	emit_signal("other_quit_pressed")


func _on_Ok_pressed() -> void:
	emit_signal("ok_pressed")
