extends State
## The mole has found a star pickup.

func enter(mole: Mole, prev_state_name: String) -> void:
	if prev_state_name in ["None", "Waiting"]:
		mole.poof.play_poof_animation()
		mole.sfx.play_poof_sound()
	mole.animation_player.play("found-star")
	mole.sfx.play_found_sound()
