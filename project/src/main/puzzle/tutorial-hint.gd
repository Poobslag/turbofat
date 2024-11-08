class_name TutorialHint
extends Control
## Shows hint diagrams during tutorials.
##
## These translucent hint diagrams go behind the playfield, showing the player where to drop their pieces.

func _ready() -> void:
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")


## Adds a new hint diagram to the playfield.
##
## These hints are currently always TileMaps, but the framework potentially allows for TextureRects or other hint
## diagrams as well.
##
## Parameters:
## 	'hint_scene': The hint diagram scene to instantiate and add behind the playfield.
func add_hint(hint_scene: PackedScene) -> void:
	add_child(hint_scene.instance())


func _prepare_level_blocks() -> void:
	for child in get_children():
		child.queue_free()


func _on_Level_settings_changed() -> void:
	_prepare_level_blocks()


func _on_PuzzleState_game_prepared() -> void:
	_prepare_level_blocks()
