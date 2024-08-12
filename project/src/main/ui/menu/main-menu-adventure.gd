extends VBoxContainer
## Main menu panel with the main game modes.

const WORLD0_ID := "world0"

func _on_Career_pressed() -> void:
	PlayerData.customer_queue.reset()
	CurrentLevel.reset()
	
	# Launch the first scene in career mode. This is probably the career map, but in some edge cases it could be a
	# cutscene or victory screen.
	if PlayerData.career.hours_passed > 0:
		# Player is in the middle of a career session; skip to the career map.
		Breadcrumb.trail.push_front(Global.SCENE_CAREER_MAP)
		PlayerData.career.push_career_trail()
	else:
		Breadcrumb.push_trail(Global.SCENE_CAREER_REGION_SELECT_MENU)


func _on_Avatar_pressed():
	MusicPlayer.stop()
	SceneTransition.push_trail("res://src/main/editor/creature/CreatureEditor.tscn")
