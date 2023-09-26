extends State
## The spear has not appeared yet, or has disappeared.

func enter(spear: Spear, prev_state_name: String) -> void:
	spear.spear_holder.visible = false
	spear.spear_sprite.position.x = Spear.UNPOPPED_SPEAR_SPRITE_X
	spear.kill_pop_tween()
	
	if prev_state_name == "PoppedIn":
		spear.poof.play_poof_animation()
		spear.sfx.play_poof_sound()
