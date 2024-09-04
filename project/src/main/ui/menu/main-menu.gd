class_name MainMenu
extends Control
## Menu the player sees after starting the game.
##
## Includes buttons for starting a new game, launching the level editor, and exiting the game.

func _ready() -> void:
	ResourceCache.substitute_singletons()
	MusicPlayer.play_menu_track()
	
	$DropPanel/Adventure/Play.grab_focus()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _on_System_quit_pressed() -> void:
	if OS.has_feature("web"):
		# don't quit from the web; just go back to splash screen
		return
	
	get_tree().quit()
