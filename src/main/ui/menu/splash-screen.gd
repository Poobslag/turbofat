extends Control
"""
A splash screen which precedes the main menu.
"""

func _ready() -> void:
	MusicPlayer.play_chill_bgm()


func _on_Play_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/ui/menu/MainMenu.tscn")


func _on_System_quit_pressed() -> void:
	get_tree().quit()
