extends VBoxContainer
## Main menu panel with game modes to play.

const WORLD0_ID := "world0"

func _on_Career_pressed() -> void:
	PlayerData.creature_queue.clear()
	CurrentLevel.reset()
	
	# Launch the first scene in career mode. This is probably the career map, but in some edge cases it could be a
	# cutscene or victory screen.
	if PlayerData.career.hours_passed > 0:
		# Player is in the middle of a career session; skip to the career map.
		Breadcrumb.trail.push_front(Global.SCENE_CAREER_MAP)
		PlayerData.career.push_career_trail()
	else:
		Breadcrumb.push_trail(Global.SCENE_CAREER_REGION_SELECT_MENU)


func _on_Practice_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/PracticeMenu.tscn", true)


func _on_Tutorials_pressed() -> void:
	SceneTransition.push_trail("res://src/main/ui/menu/TutorialMenu.tscn", true)
 
