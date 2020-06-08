extends Spatial
"""
Script which controls the 3D overworld.
"""

func _ready() -> void:
	$OverworldUi.spira = $Spira


func _unset_chat_zoom() -> void:
	$OverworldCamera.target = NodePath("../Spira/CameraTarget")
	$OverworldCamera.zoom_out()


func _on_OverworldUi_chat_started() -> void:
	$OverworldCamera.target = NodePath("../ChatCameraTarget")
	$OverworldCamera.zoom_in()
	$ChatCameraTarget.zoomed_in = true


func _on_OverworldUi_chat_ended() -> void:
	_unset_chat_zoom()


func _on_ChatCameraTarget_left_zoom_radius() -> void:
	_unset_chat_zoom()


"""
When giving the player a dialog prompt, we halt Spira's movement and make her face the camera.

This is partially for cosmetic reasons, but also to prevent her from continuing to run in a straight line while
answering a dialog prompt. Player input is ignored during dialog prompts because the input is applied to the dialog
buttons instead.
"""
func _on_OverworldUi_showed_chat_choices() -> void:
	if $Spira.stop_movement():
		$OverworldUi.make_chatters_face_eachother()
