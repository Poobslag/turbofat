class_name MainMenu
extends Control
"""
The menu the user sees after starting the game.

Includes buttons for starting a new game, launching the level editor, and exiting the game.
"""

func _ready() -> void:
	if not PlayerData.level_history.finished_levels.has(Level.BEGINNER_TUTORIAL):
		# if the player fails/quits the first tutorial, they're redirected to the splash screen
		Breadcrumb.trail = [Global.SCENE_SPLASH]
		_launch_tutorial()
	
	ResourceCache.substitute_singletons(self)
	
	# Fade in music when redirected from a scene with no music, such as the level editor
	if not MusicPlayer.is_playing_chill_bgm():
		MusicPlayer.play_chill_bgm()
		MusicPlayer.fade_in()
	
	$DropPanel/Play/Practice.grab_focus()


func _exit_tree() -> void:
	ResourceCache.remove_singletons(self)


func _launch_tutorial() -> void:
	Global.clear_creature_queue()
	Level.set_launched_level(Level.BEGINNER_TUTORIAL, CreatureLoader.INSTRUCTOR_ID)
	Level.push_level_trail()


func _on_PlayStory_pressed() -> void:
	Global.clear_creature_queue()
	Level.clear_launched_level()
	Breadcrumb.push_trail(Global.SCENE_OVERWORLD)


func _on_PlayPractice_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/ui/menu/PracticeMenu.tscn")


func _on_CreateLevels_pressed() -> void:
	MusicPlayer.stop()
	Breadcrumb.push_trail("res://src/main/editor/puzzle/LevelEditor.tscn")


func _on_CreateCreatures_pressed() -> void:
	MusicPlayer.stop()
	Breadcrumb.push_trail("res://src/main/editor/creature/CreatureEditor.tscn")


func _on_System_quit_pressed() -> void:
	get_tree().quit()


func _on_Tutorials_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/ui/menu/TutorialMenu.tscn")
