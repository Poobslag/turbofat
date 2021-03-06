extends VBoxContainer
"""
A panel shown on the main menu which contains game modes to play.
"""

func _on_Story_pressed() -> void:
	PlayerData.creature_queue.clear()
	CurrentLevel.clear_launched_level()
	SceneTransition.push_trail(Global.SCENE_OVERWORLD)


func _on_Practice_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/PracticeMenu.tscn", true)


func _on_Tutorials_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/TutorialMenu.tscn", true)
