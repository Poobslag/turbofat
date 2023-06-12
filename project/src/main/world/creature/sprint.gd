@tool #uncomment to view creature in editor
extends PackedSprite
## Draws the creature's arms, legs and torso when sprinting.

## Turns the sprite visible when the creature is sprinting.
func _on_CreatureVisuals_movement_mode_changed(_old_mode: Creatures.MovementMode, new_mode: Creatures.MovementMode) -> void:
	visible = new_mode == Creatures.SPRINT
