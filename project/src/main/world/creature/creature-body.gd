#tool #uncomment to view creature in editor
extends CreatureCurve
"""
Draws the creature's torso.
"""

"""
Turn the creature's torso invisible when sprinting.

When running, the torso/arms/legs are animated as a single unit.
"""
func refresh_visible() -> void:
	.refresh_visible()
	if creature_visuals.movement_mode == CreatureVisuals.SPRINT:
		visible = false


func _on_CreatureVisuals_movement_mode_changed(_old_mode: int, _new_mode: int) -> void:
	refresh_visible()
