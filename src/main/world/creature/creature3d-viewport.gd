extends Viewport
"""
Viewport which renders a 2D creature in the 3D overworld.
"""

func _on_Creature_movement_animation_started(anim_name: String) -> void:
	if anim_name in ["run-nw", "jump-nw"]:
		# reposition sprite to avoid clipping the floor
		$Creature.position.y = 842
	elif anim_name in ["run-se", "jump-se"]:
		# reposition sprite to prevent it from looking too 'slidey'
		$Creature.position.y = 882
	else:
		# default sprite position
		$Creature.position.y = 932
