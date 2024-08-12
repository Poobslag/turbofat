extends VBoxContainer
## Main menu panel with various practice modes.

func _on_Training_pressed():
	SceneTransition.push_trail("res://src/main/ui/menu/TrainingMenu.tscn",
			{SceneTransition.FLAG_TYPE: SceneTransition.TYPE_NONE})


func _on_Tutorials_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/TutorialMenu.tscn",
			{SceneTransition.FLAG_TYPE: SceneTransition.TYPE_NONE})
