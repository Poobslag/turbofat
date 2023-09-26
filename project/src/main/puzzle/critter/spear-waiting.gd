extends State
## The spear will appear soon.

func enter(spear: Spear, prev_state_name: String) -> void:
	if prev_state_name == "None":
		spear.sfx.play_warning_voice()
	
	spear.spear_holder.visible = false
	spear.spear_sprite.position.x = Spear.UNPOPPED_SPEAR_SPRITE_X
	spear.wait.show_wait()
	spear.kill_pop_tween()


func exit(spear: Spear, _new_state_name: String) -> void:
	spear.wait.hide()
