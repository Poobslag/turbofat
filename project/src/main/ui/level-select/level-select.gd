extends Control
## The level select screen which shows buttons and level info.

export (NodePath) var level_buttons_path: NodePath

## Allows for hiding/showing certain levels
export (LevelButtons.LevelsToInclude) var levels_to_include: int setget set_levels_to_include

onready var _level_buttons: LevelButtons = get_node(level_buttons_path)

func _ready() -> void:
	_level_buttons.levels_to_include = levels_to_include

## Parameters:
## 	'new_levels_to_include': An enum in LevelButtons.LevelsToInclude which specifies which allows for hiding or
## 			showing certain levels.
func set_levels_to_include(new_levels_to_include: int) -> void:
	levels_to_include = new_levels_to_include
	_refresh_levels_to_include()


func get_levels_to_include() -> int:
	return levels_to_include


func _refresh_levels_to_include() -> void:
	if not is_inside_tree():
		return
	
	_level_buttons.levels_to_include = levels_to_include


func _on_SettingsMenu_quit_pressed() -> void:
	SceneTransition.pop_trail()
