extends Spatial
"""
Script which controls the 3D overworld.
"""

func _on_CheatCodeDetector_cheat_detected(cheat: String):
	if cheat == "coyote":
		if not $Turbo/Label.visible:
			$Turbo/Label.visible = true
			$CheatEnabledSound.play()
		else:
			$Turbo/Label.visible = false
			$CheatDisabledSound.play()
	if cheat == "bigfps":
		if not $OverworldUi.is_show_fps():
			$OverworldUi.set_show_fps(true)
			$CheatEnabledSound.play()
		else:
			$OverworldUi.set_show_fps(false)
			$CheatDisabledSound.play()
