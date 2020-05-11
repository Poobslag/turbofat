extends Label
"""
Shows diagnostics for the player's movement physics. Enabled with the cheat code 'coyote'.
"""

var turbo: Turbo

func _process(delta: float) -> void:
	if turbo and visible:
		text = ""
		text += "-" if turbo.get_node("CoyoteTimer").is_stopped() else "c"
		text += "-" if turbo.get_node("JumpBuffer").is_stopped() else "b"
		text += "j" if turbo._jumping else "-"
		text += "s" if turbo._slipping else "-"
		text += "f" if turbo._friction else "-"
		text += "F" if turbo.is_on_floor() else "-"
		text += "o" if turbo.over_something() else "-"


func _on_OverworldUi_turbo_changed(new_turbo: Turbo) -> void:
	turbo = new_turbo


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "coyote":
		visible = !visible
		detector.play_cheat_sound(visible)
