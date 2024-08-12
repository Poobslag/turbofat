extends VBoxContainer
## Main menu panel with various editors.


func _on_Creatures_pressed() -> void:
	MusicPlayer.stop()
	SceneTransition.push_trail("res://src/main/editor/creature/CreatureEditor.tscn")
