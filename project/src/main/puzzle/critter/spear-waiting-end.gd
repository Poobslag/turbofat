extends State
## The spear will appear immediately.

func enter(spear: Spear, _prev_state_name: String) -> void:
	spear.spear_holder.visible = false
	spear.spear_sprite.position.x = Spear.UNPOPPED_SPEAR_SPRITE_X
	spear.wait.show_wait_end()
	spear.kill_pop_tween()


func exit(spear: Spear, _new_state_name: String) -> void:
	spear.wait.hide()
