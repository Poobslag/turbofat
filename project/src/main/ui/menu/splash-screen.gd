extends Control
## Splash screen which precedes the main menu.

func _ready() -> void:
	MusicPlayer.play_menu_track(false)
	
	$DropPanel/PlayHolder/Play.grab_focus()
	if PlayerSave.corrupt_filenames:
		$BadSaveDataControl.popup()
	
	if OS.has_feature("web"):
		# don't quit from the web. it just blacks out the window, which isn't useful or user friendly
		$DropPanel/System/Quit.hide()


func _launch_tutorial() -> void:
	PlayerData.customer_queue.reset()
	CurrentLevel.set_launched_level(OtherLevelLibrary.BEGINNER_TUTORIAL)
	CurrentLevel.push_level_trail()


func _on_Play_pressed() -> void:
	if not PlayerData.level_history.is_level_finished(OtherLevelLibrary.BEGINNER_TUTORIAL):
		_launch_tutorial()
	else:
		SceneTransition.push_trail(Global.SCENE_MAIN_MENU, {SceneTransition.FLAG_TYPE: SceneTransition.TYPE_NONE})


func _on_System_quit_pressed() -> void:
	get_tree().quit()
