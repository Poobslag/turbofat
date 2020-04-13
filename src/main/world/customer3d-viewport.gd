extends Viewport
"""
Viewport which renders a 2D customer in the 3D overworld.
"""

func _on_MovementAnims_animation_started(anim_name):
	if anim_name in ["run-nw", "jump-nw"]:
		# reposition sprite to avoid clipping the floor
		$Customer.position.y = 842
	elif anim_name in ["run-se", "jump-se"]:
		# reposition sprite to prevent it from looking too 'slidey'
		$Customer.position.y = 882
	else:
		# default sprite position
		$Customer.position.y = 932
