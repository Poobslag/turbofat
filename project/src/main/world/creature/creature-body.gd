#tool #uncomment to view creature in editor
extends CreatureCurve
"""
Draws the creature's torso.
"""

"""
Disconnects creature visuals listeners specific to the torso.

Overrides the superclass's implementation to disconnect additional listeners.
"""
func disconnect_creature_visuals_listeners() -> void:
	.disconnect_creature_visuals_listeners()
	creature_visuals.disconnect("movement_mode_changed", self, "_on_CreatureVisuals_movement_mode_changed")
	creature_visuals.disconnect("orientation_changed", $NeckBlend, "_on_CreatureVisuals_orientation_changed")
	creature_visuals.disconnect("movement_mode_changed", $NeckBlend, "_on_CreatureVisuals_movement_mode_changed")


"""
Connects creature visuals listeners specific to the torso.

Overrides the superclass's implementation to connect additional listeners.
"""
func connect_creature_visuals_listeners() -> void:
	.connect_creature_visuals_listeners()
	creature_visuals.connect("movement_mode_changed", self, "_on_CreatureVisuals_movement_mode_changed")
	creature_visuals.connect("orientation_changed", $NeckBlend, "_on_CreatureVisuals_orientation_changed")
	creature_visuals.connect("movement_mode_changed", $NeckBlend, "_on_CreatureVisuals_movement_mode_changed")


"""
Turn the creature's torso invisible when sprinting.

When running, the torso/arms/legs are animated as a single unit.
"""
func refresh_visible() -> void:
	.refresh_visible()
	if not creature_visuals:
		return
	
	if creature_visuals.movement_mode == CreatureVisuals.SPRINT:
		visible = false


func _on_CreatureVisuals_movement_mode_changed(_old_mode: int, _new_mode: int) -> void:
	refresh_visible()
