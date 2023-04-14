extends State
## The shark has been fed, and looks happy.

func enter(shark: Shark, prev_state_name: String) -> void:
	if prev_state_name in ["None", "Waiting"]:
		shark.poof.play_poof_animation()
		if shark.visible:
			shark.sfx.play_poof_sound()
	shark.play_shark_anim("fed")
	shark.sfx.play_voice_friendly_sound()
