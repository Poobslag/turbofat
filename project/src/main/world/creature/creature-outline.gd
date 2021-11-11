class_name CreatureOutline
extends Node2D
## Augments creature visuals with an elevation and an outline.

signal elevation_changed(elevation)

## How high the creature should be elevated off the ground, in pixels.
var elevation: float

var creature_visuals: CreatureVisuals

func set_elevation(new_elevation: float) -> void:
	elevation = new_elevation
	emit_signal("elevation_changed", new_elevation)
