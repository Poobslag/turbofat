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
