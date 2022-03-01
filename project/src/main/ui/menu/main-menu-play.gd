extends VBoxContainer
## A panel shown on the main menu which contains game modes to play.

const WORLD0_ID := "world0"

func _on_Career_pressed() -> void:
	PlayerData.creature_queue.clear()
	CurrentLevel.clear_launched_level()
	
	# Launch the first scene in career mode. This is probably the career map, but in some edge cases it could be a
	# cutscene or victory screen.
	Breadcrumb.trail.push_front(Global.SCENE_CAREER_MAP)
	PlayerData.career.push_career_trail()


func _on_Story_pressed() -> void:
	PlayerData.creature_queue.clear()
	PlayerData.story.reset()
	CurrentLevel.clear_launched_level()
	
	var world_lock := LevelLibrary.world_lock(WORLD0_ID)
	if world_lock.prologue_chat_key and not PlayerData.chat_history.is_chat_finished(world_lock.prologue_chat_key):
		# load the prologue scene
		var chat_tree := ChatLibrary.chat_tree_for_key(world_lock.prologue_chat_key)
		CutsceneQueue.enqueue_cutscene(chat_tree)
		CutsceneQueue.push_trail()
	else:
		SceneTransition.push_trail(Global.SCENE_FREE_ROAM)


func _on_Practice_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/PracticeMenu.tscn", true)


func _on_Tutorials_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/TutorialMenu.tscn", true)
