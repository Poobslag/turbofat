#tool #uncomment to view creature in editor
extends PackedSprite
"""
Draws the creature's arms, legs and torso when sprinting.
"""

"""
Turn sprite visible when the creature is sprinting.
"""
func _on_CreatureVisuals_movement_mode_changed(_old_mode: int, new_mode: int) -> void:
	visible = new_mode == CreatureVisuals.SPRINT
