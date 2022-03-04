#tool #uncomment to view creature in editor
class_name CreaturePackedSprite
extends PackedSprite
## Sprite which toggles between a single 'toward the camera' and 'away from the camera' frame

export (bool) var invisible_while_sprinting := false

func update_orientation(orientation: int) -> void:
	if Creatures.oriented_south(orientation):
		# facing south; initialize textures to forward-facing frame
		set_frame(1)
	else:
		# facing north; initialize textures to backward-facing frame
		set_frame(2)


func _on_CreatureVisuals_orientation_changed(old_orientation: int, new_orientation: int) -> void:
	if Creatures.oriented_south(new_orientation) and Creatures.oriented_south(old_orientation):
			# still facing south, just like before
			pass
	elif Creatures.oriented_north(new_orientation) and Creatures.oriented_north(old_orientation):
			# still facing north, just like before
			pass
	else:
		update_orientation(new_orientation)


func _on_CreatureVisuals_movement_mode_changed(_old_mode: int, new_mode: int) -> void:
	if invisible_while_sprinting:
		visible = false if new_mode == Creatures.SPRINT else true
