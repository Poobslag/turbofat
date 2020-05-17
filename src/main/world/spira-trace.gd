extends Label
"""
Shows diagnostics for the player's movement physics. Enabled with the cheat code 'coyote'.
"""

var spira: Spira

func _process(delta: float) -> void:
	if spira and visible:
		text = ""
		text += "-" if spira.get_node("CoyoteTimer").is_stopped() else "c"
		text += "-" if spira.get_node("JumpBuffer").is_stopped() else "b"
		text += "j" if spira._jumping else "-"
		text += "s" if spira._slipping else "-"
		text += "f" if spira._friction else "-"
		text += "F" if spira.is_on_floor() else "-"
		text += "o" if spira.over_something() else "-"


func _on_OverworldUi_spira_changed(new_spira: Spira) -> void:
	spira = new_spira


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "coyote":
		visible = !visible
		detector.play_cheat_sound(visible)
