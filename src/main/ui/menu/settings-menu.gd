extends CanvasLayer
"""
Menu which lets the player adjust settings.

This is meant to be overlaid over over scenes, which is why it is a CanvasLayer.
"""

signal quit_pressed

# The text on the menu's quit button
export (String, "Quit", "Save + Quit") var quit_text: String setget set_quit_text

func _ready() -> void:
	# starts invisible
	hide()


func set_quit_text(new_quit_text: String) -> void:
	quit_text = new_quit_text
	if is_inside_tree():
		$Panel/Control/Quit.text = quit_text


"""
Shows the menu and pauses the scene tree.
"""
func show() -> void:
	$Bg.show()
	$Window.show()
	get_tree().paused = true
	$Window/UiArea/SettingsArea/Ok.grab_focus()


"""
Hides the menu and unpauses the scene tree.
"""
func hide() -> void:
	$Bg.hide()
	$Window.hide()
	get_tree().paused = false


func _on_Ok_pressed() -> void:
	# save the player's settings
	PlayerSave.save_player_data()
	hide()


func _on_Quit_pressed() -> void:
	emit_signal("quit_pressed")


func _on_Settings_pressed() -> void:
	show()
