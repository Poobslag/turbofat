extends Control
"""
The level select screen which shows buttons and level info.
"""

func _ready() -> void:
	Breadcrumb.connect("trail_popped", self, "_on_Breadcrumb_trail_popped")


func _on_Breadcrumb_trail_popped(_prev_path: String) -> void:
	if not Breadcrumb.trail:
		get_tree().change_scene("res://src/main/ui/menu/LoadingScreen.tscn")


func _on_SettingsMenu_quit_pressed() -> void:
	Breadcrumb.pop_trail()
