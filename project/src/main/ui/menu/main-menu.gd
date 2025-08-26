class_name MainMenu
extends Control
## Menu the player sees after starting the game.
##
## Includes buttons for starting a new game, launching the level editor, and exiting the game.

func _ready() -> void:
	MusicPlayer.play_menu_track()
	
	if OS.has_feature("web") or OS.has_feature("mobile"):
		# don't quit from the web. it just blacks out the window, which isn't useful or user friendly
		$DropPanel/System/Quit.visible = false
	
	$DropPanel/Adventure/Play.grab_focus()


func _on_System_quit_pressed() -> void:
	if not is_inside_tree():
		return
	if OS.has_feature("web") or OS.has_feature("mobile"):
		# don't quit from the web; just go back to splash screen
		return
	
	get_tree().quit()
