class_name MainMenu
extends Control
"""
The menu the user sees after starting the game.

Includes buttons for starting a new game, launching the level editor, and exiting the game.
"""

func _ready() -> void:
	ResourceCache.substitute_singletons()
	
	# Fade in music when redirected from a scene with no music, such as the level editor
	if not MusicPlayer.is_playing_chill_bgm() and not MusicTransition.is_fading_in_bgm():
		MusicPlayer.play_chill_bgm()
		MusicPlayer.fade_in()
	
	$DropPanel/Play/Practice.grab_focus()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _on_System_quit_pressed() -> void:
	if OS.has_feature("web"):
		# don't quit from the web; just go back to splash screen
		return
	
	get_tree().quit()
