# uncomment to view creature in editor
#tool
extends PackedSprite
"""
Sprites which toggles between a single 'toward the camera' and 'away from the camera' frame
"""

export (bool) var invisible_while_moving := false

func _on_CreatureVisuals_orientation_changed(old_orientation: int, new_orientation: int) -> void:
	if new_orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
		if old_orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
			# we were already facing southwest/southeast; don't interrupt our animation
			pass
		else:
			# facing south; initialize textures to forward-facing frame
			set_frame(1)
	else:
		# facing north; initialize textures to backward-facing frame
		set_frame(2)


func _on_CreatureVisuals_movement_mode_changed(movement_mode: bool) -> void:
	if invisible_while_moving:
		visible = not movement_mode
