class_name MainMenu
extends Control
"""
The menu the user sees after starting the game.

Includes buttons for starting a new game, launching the level editor, and exiting the game.
"""

func _ready() -> void:
	if not PlayerData.level_history.finished_levels.has(LevelLibrary.BEGINNER_TUTORIAL):
		# if the player fails/quits the first tutorial, they're redirected to the splash screen
		Breadcrumb.trail = [Global.SCENE_SPLASH]
		_launch_tutorial()
	
	ResourceCache.substitute_singletons()
	
	# Fade in music when redirected from a scene with no music, such as the level editor
	if not MusicPlayer.is_playing_chill_bgm():
		MusicPlayer.play_chill_bgm()
		MusicPlayer.fade_in()
	
	$DropPanel/Play/Practice.grab_focus()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _launch_tutorial() -> void:
	PlayerData.creature_queue.clear()
	CurrentLevel.set_launched_level(LevelLibrary.BEGINNER_TUTORIAL)
	CurrentLevel.push_level_trail()


func _on_System_quit_pressed() -> void:
	if OS.has_feature("web"):
		# don't quit from the web; just go back to splash screen
		return
	
	get_tree().quit()
