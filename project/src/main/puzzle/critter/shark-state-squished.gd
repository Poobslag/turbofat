extends State
## The shark has been squished by a piece.

func enter(shark: Shark, prev_state_name: String) -> void:
	if prev_state_name in ["None", "Waiting"]:
		shark.poof.play_poof_animation()
		if shark.visible:
			shark.sfx.play_poof_sound()
	shark.play_shark_anim("squished")
	shark.sfx.play_squish_sound()
	if is_inside_tree():
		get_tree().create_timer(0.20).connect("timeout", self, "_play_voice", [shark])


func _play_voice(shark: Shark) -> void:
	shark.sfx.play_voice_short_sound()
