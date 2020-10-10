extends Control
"""
The level select screen which shows buttons and level info.
"""

# Allows for hiding/showing certain levels.
# Virtual property; value is only exposed through getters/setters
export (LevelSelectModel.LevelsToInclude) var levels_to_include: int setget set_levels_to_include

func _ready() -> void:
	Breadcrumb.connect("trail_popped", self, "_on_Breadcrumb_trail_popped")


"""
Parameters:
	'new_levels_to_include': An enum in LevelSelectModel.LevelsToInclude which specifies which allows for hiding or
			showing certain levels.
"""
func set_levels_to_include(new_levels_to_include: int) -> void:
	$VBoxContainer/ScrollContainer/MarginContainer/LevelButtons.levels_to_include = new_levels_to_include


func get_levels_to_include() -> int:
	return $VBoxContainer/ScrollContainer/MarginContainer/LevelButtons.levels_to_include


func _on_Breadcrumb_trail_popped(_prev_path: String) -> void:
	if not Breadcrumb.trail:
		get_tree().change_scene("res://src/main/ui/menu/LoadingScreen.tscn")


func _on_SettingsMenu_quit_pressed() -> void:
	Breadcrumb.pop_trail()
