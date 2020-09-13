extends Control
"""
A splash screen which precedes the main menu.
"""

func _ready() -> void:
	if not MusicPlayer.is_playing_chill_bgm():
		MusicPlayer.play_chill_bgm()
	$PlayHolder/Play.grab_focus()
	if PlayerSave.corrupt_filenames:
		$BadSaveDataControl.popup()


func _on_Play_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/ui/menu/MainMenu.tscn")


func _on_System_quit_pressed() -> void:
	get_tree().quit()
