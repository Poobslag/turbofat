#tool #uncomment to view creature in editor
extends CreatureCurve

func _on_CreatureVisuals_movement_mode_changed(movement_mode: bool) -> void:
	visible = not movement_mode
