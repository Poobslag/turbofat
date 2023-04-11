extends State
## The shark has not appeared yet, or has disappeared.

func enter(shark: Shark, prev_state_name: String) -> void:
	shark.shark.visible = false
	shark.wait_low.visible = false
	shark.wait_high.visible = false
	
	if not prev_state_name in ["", "None", "Waiting"]:
		shark.poof.play_poof_animation()
		shark.sfx.play_poof_sound()
	shark.animation_player.stop()
	shark.tooth_cloud.eating = false
