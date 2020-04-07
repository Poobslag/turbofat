extends Spatial
"""
Script which controls the 3D overworld.
"""

func _on_PuzzleButton_pressed() -> void:
	get_tree().change_scene("res://src/main/ui/ScenarioMenu.tscn")


func _on_CheatCodeDetector_cheat_detected(cheat: String):
	if cheat == "coyote":
		if not $Turbo/Label.visible:
			$Turbo/Label.visible = true
			$CheatEnabledSound.play()
		else:
			$Turbo/Label.visible = false
			$CheatDisabledSound.play()
