extends Spatial
"""
Script which controls the 3D overworld.
"""

func _ready():
	$OverworldUi.turbo = $Turbo


func _unset_chat_zoom():
	$OverworldCamera.target = NodePath("../Turbo/CameraTarget")
	$OverworldCamera.zoom_out()


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


func _on_OverworldUi_chat_started():
	$OverworldCamera.target = NodePath("../ChatCameraTarget")
	$OverworldCamera.zoom_in()
	$ChatCameraTarget.zoomed_in = true


func _on_OverworldUi_chat_ended():
	_unset_chat_zoom()


func _on_ChatCameraTarget_left_zoom_radius():
	_unset_chat_zoom()
