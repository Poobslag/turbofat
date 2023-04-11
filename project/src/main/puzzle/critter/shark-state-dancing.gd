extends State
## The shark is dancing, waiting to be fed.

func enter(shark: Shark, prev_state_name: String) -> void:
	if prev_state_name in ["None", "Waiting"]:
		shark.poof.play_poof_animation()
		shark.sfx.play_poof_sound()
	shark.play_shark_anim("dance")
	
	shark.sync_dance()
