extends VBoxContainer
"""
A panel shown on the main menu which contains game modes to play.
"""

# the cutscene we load when the player launches story mode for the first time
const PROLOGUE_CHAT_KEY := "chat/marsh_prologue"

func _on_Story_pressed() -> void:
	PlayerData.creature_queue.clear()
	CurrentLevel.clear_launched_level()
	
	if not PlayerData.chat_history.is_chat_finished(PROLOGUE_CHAT_KEY):
		# load the prologue scene
		var chat_tree := ChatLibrary.chat_tree_for_key(PROLOGUE_CHAT_KEY)
		CutsceneManager.enqueue_chat_tree(chat_tree)
		SceneTransition.push_trail(chat_tree.chat_scene_path())
	else:
		SceneTransition.push_trail(Global.SCENE_OVERWORLD)


func _on_Practice_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/PracticeMenu.tscn", true)


func _on_Tutorials_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/TutorialMenu.tscn", true)
