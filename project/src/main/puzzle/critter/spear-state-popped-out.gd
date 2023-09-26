extends State
## The spear has retreated from the playfield into the side walls.

func enter(spear: Spear, prev_state_name: String) -> void:
	spear.spear_holder.visible = true
	
	if prev_state_name == "PoppedIn":
		spear.tween_and_pop(Spear.UNPOPPED_SPEAR_SPRITE_X, spear.pop_anim_duration)
