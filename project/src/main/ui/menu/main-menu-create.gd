extends VBoxContainer
## A panel shown on the main menu which contains various editors.

func _on_Levels_pressed() -> void:
	MusicPlayer.stop()
	SceneTransition.push_trail("res://src/main/editor/puzzle/LevelEditor.tscn")


func _on_Creatures_pressed() -> void:
	MusicPlayer.stop()
	SceneTransition.push_trail("res://src/main/editor/creature/CreatureEditor.tscn")
