extends State
## The tomato has not appeared yet, or has disappeared.

func enter(tomato: Tomato, prev_state_name: String) -> void:
	tomato.tomato.visible = false
	
	if not prev_state_name in ["", "None"]:
		tomato.poof.play_poof_animation()
		tomato.hide_backdrop()
		tomato.sfx.play_poof_sound()
	tomato.animation_player.stop()
