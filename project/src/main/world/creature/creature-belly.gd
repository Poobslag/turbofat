#tool #uncomment to view creature in editor
extends CreatureCurve
"""
Draws the creature's colored belly.

The belly is the front part of the creature's body, and is often a different color.
"""

func _on_CreatureVisuals_orientation_changed(_old_orientation: int, new_orientation: int) -> void:
	visible = new_orientation in [CreatureVisuals.SOUTHWEST, CreatureVisuals.SOUTHEAST]
