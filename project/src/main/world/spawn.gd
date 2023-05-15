class_name Spawn
extends Node2D
## Point where a creature can appear on the overworld.

## direction the creature will face
export (Creatures.Orientation) var orientation := Creatures.SOUTHEAST

## unique id for this spawn point
export (String) var id: String

export (float) var elevation: float

## Relocates the specified creature to this spawn point.
func move_creature(creature: Creature) -> void:
	creature.position = position
	creature.orientation = orientation
	creature.elevation = elevation
	
	Stool.update_stool_occupied(self, true)
