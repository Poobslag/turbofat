extends VBoxContainer
## A panel shown on the main menu which contains game modes to play.

const WORLD0_ID := "world0"

func _on_Career_pressed() -> void:
	PlayerData.creature_queue.clear()
	CurrentLevel.clear_launched_level()
	SceneTransition.push_trail(Global.SCENE_CAREER_MAP)


func _on_Story_pressed() -> void:
	PlayerData.creature_queue.clear()
	CurrentLevel.clear_launched_level()
	
	var world_lock := LevelLibrary.world_lock(WORLD0_ID)
	if world_lock.prologue_chat_key and not PlayerData.chat_history.is_chat_finished(world_lock.prologue_chat_key):
		# load the prologue scene
		var chat_tree := ChatLibrary.chat_tree_for_key(world_lock.prologue_chat_key)
		CutsceneManager.enqueue_cutscene(chat_tree)
		SceneTransition.push_trail(chat_tree.chat_scene_path())
	else:
		SceneTransition.push_trail(Global.SCENE_OVERWORLD)


func _on_Practice_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/PracticeMenu.tscn", true)


func _on_Tutorials_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/TutorialMenu.tscn", true)
