extends State
## The shark is dancing, but will stop dancing very soon.

func enter(shark: Shark, prev_state_name: String) -> void:
	if prev_state_name in ["None", "Waiting"]:
		shark.poof.play_poof_animation()
		shark.sfx.play_poof_sound()
	shark.play_shark_anim("dance-end")
	
	shark.sync_dance()
