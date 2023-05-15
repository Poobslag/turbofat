extends State
## The shark is eating a piece.

## if the eating duration is shorter than this, we use a short 'bite' sound effect
const BITE_SFX_THRESHOLD := 0.30

func enter(shark: Shark, prev_state_name: String) -> void:
	if prev_state_name in ["None", "Waiting"]:
		shark.poof.play_poof_animation()
		if shark.visible:
			shark.sfx.play_poof_sound()
	shark.play_shark_anim("eat")
	if shark.eat_duration < BITE_SFX_THRESHOLD:
		shark.sfx.play_bite_sound()
	else:
		shark.sfx.play_eat_sound()


func exit(shark: Shark, _new_state_name: String) -> void:
	shark.sfx.stop_eat_sound()
