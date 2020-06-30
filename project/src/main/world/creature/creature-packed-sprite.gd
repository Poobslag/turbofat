#tool #uncomment to view creature in editor
class_name CreaturePackedSprite
extends PackedSprite
"""
Sprites which toggles between a single 'toward the camera' and 'away from the camera' frame
"""

export (bool) var invisible_while_moving := false

func update_orientation(orientation: int) -> void:
	if orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST]:
		# facing south; initialize textures to forward-facing frame
		set_frame(1)
	else:
		# facing north; initialize textures to backward-facing frame
		set_frame(2)


func _on_CreatureVisuals_orientation_changed(old_orientation: int, new_orientation: int) -> void:
	if (new_orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST]) \
			!= (old_orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST]):
		# we went from facing south to north, or from facing north to south
		update_orientation(new_orientation)


func _on_CreatureVisuals_movement_mode_changed(movement_mode: bool) -> void:
	if invisible_while_moving:
		visible = not movement_mode
