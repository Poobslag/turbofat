extends State
## The tomato is bouncing up and down holding up their hand.
##
## The number of fingers held up is controlled by the 'anim_name' property.

## Animation name corresponding to the number of fingers the tomato is holding up.
export (String) var anim_name: String

func enter(tomato: Tomato, prev_state_name: String) -> void:
	# store information about the previous tomato animation
	var prev_tomato_animation: String = tomato.animation_player.current_animation
	var prev_tomato_animation_position := \
			tomato.animation_player.current_animation_position if prev_tomato_animation else 0.0
	
	# play the appropriate sound effects and animations
	if prev_state_name == "None":
		tomato.poof.play_poof_animation()
		tomato.show_backdrop()
		tomato.sfx.play_poof_sound()
	if not tomato.suppress_voice:
		tomato.sfx.play_voice()
	tomato.animation_player.play(anim_name)
	
	# preserve the tomato animation position
	if prev_tomato_animation:
		tomato.animation_player.seek(prev_tomato_animation_position, true)
