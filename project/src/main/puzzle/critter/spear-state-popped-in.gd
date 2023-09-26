extends State
## The spear has popped into the playfield from the side walls.

func enter(spear: Spear, prev_state_name: String) -> void:
	spear.spear_holder.visible = true
	
	if prev_state_name != "PoppedIn":
		spear.tween_and_pop(-450 + spear.pop_length, 0.2)
