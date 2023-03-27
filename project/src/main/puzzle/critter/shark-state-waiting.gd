extends State
## The shark will appear soon.

func enter(shark: Shark, prev_state_name: String) -> void:
	if not prev_state_name in ["", "None", "Waiting"]:
		shark.poof.play_poof_animation()
		shark.sfx.play_poof_sound()
	shark.animation_player.play("wait")
