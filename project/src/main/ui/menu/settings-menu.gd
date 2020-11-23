class_name SettingsMenu
extends CanvasLayer
"""
Menu which lets the player adjust settings.

This is meant to be overlaid over over scenes, which is why it is a CanvasLayer.
"""

signal show
signal hide
signal quit_pressed

const QUIT := "Quit"
const SAVE_AND_QUIT := "Save + Quit"
const GIVE_UP := "Give Up"

# The text on the menu's quit button
export (String, "Quit", "Save + Quit", "Give Up") var quit_text: String setget set_quit_text

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


func set_quit_text(new_quit_text: String) -> void:
	quit_text = new_quit_text
	if is_inside_tree():
		$Window/UiArea/Bottom/Quit.text = quit_text


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


func _on_Ok_pressed() -> void:
	# save the player's settings
	PlayerSave.save_player_data()
	hide()


func _on_Quit_pressed() -> void:
	hide()
	emit_signal("quit_pressed")


func _on_Settings_pressed() -> void:
	show()


func _on_CustomKeybindButton_awaiting_changed(awaiting: bool) -> void:
	# when the user is rebinding their keys, we disable the shortcut helper. otherwise trying to rebind something like
	# 'escape' will close the settings menu
	$Window/UiArea/Bottom/Ok/ShortcutHelper.set_process_input(!awaiting)
