extends Control
"""
A splash screen which precedes the main menu.
"""

func _ready() -> void:
	ResourceCache.substitute_singletons()
	
	if not MusicPlayer.is_playing_chill_bgm():
		MusicPlayer.play_chill_bgm()
	$DropPanel/PlayHolder/Play.grab_focus()
	if PlayerSave.corrupt_filenames:
		$BadSaveDataControl.popup()
	
	if OS.has_feature("web"):
		# don't quit from the web. it just blacks out the window, which isn't useful or user friendly
		$DropPanel/System/Quit.hide()


func _exit_tree() -> void:
	ResourceCache.remove_singletons()


func _on_Play_pressed() -> void:
	SceneTransition.push_trail(Global.SCENE_MAIN_MENU, true)


func _on_System_quit_pressed() -> void:
	get_tree().quit()
