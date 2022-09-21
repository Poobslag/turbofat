extends State
## The mole will appear soon.
##
## If the player crushes the mole with their piece when it is in this state, it relocates elsewhere in the playfield.
## This is so that players are not punished unfairly for crushing a mole which they did not see quickly enough.

func enter(mole: Mole, prev_state_name: String) -> void:
	if not prev_state_name in ["", "None", "Waiting"]:
		mole.poof.play_poof_animation()
		mole.sfx.play_poof_sound()
	mole.animation_player.play("wait")
