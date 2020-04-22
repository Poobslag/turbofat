extends Spatial
"""
Script which controls the 3D overworld.
"""

func _ready() -> void:
	$OverworldUi.turbo = $Turbo


func _unset_chat_zoom() -> void:
	$OverworldCamera.target = NodePath("../Turbo/CameraTarget")
	$OverworldCamera.zoom_out()


func _on_CheatCodeDetector_cheat_detected(cheat: String) -> void:
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


func _on_OverworldUi_chat_started() -> void:
	$OverworldCamera.target = NodePath("../ChatCameraTarget")
	$OverworldCamera.zoom_in()
	$ChatCameraTarget.zoomed_in = true


func _on_OverworldUi_chat_ended() -> void:
	_unset_chat_zoom()


func _on_ChatCameraTarget_left_zoom_radius() -> void:
	_unset_chat_zoom()
