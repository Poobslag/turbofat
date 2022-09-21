extends State
## The mole has not appeared yet, or has disappeared.

func enter(mole: Mole, prev_state_name: String) -> void:
	mole.mole.visible = false
	mole.wait_low.visible = false
	mole.wait_high.visible = false
	
	if not prev_state_name in ["", "None", "Waiting"]:
		mole.poof.play_poof_animation()
		mole.sfx.play_poof_sound()
	mole.animation_player.stop()
