class_name Spawn
extends Node2D
## A point where a creature can appear on the overworld.

## the direction the creature will face
export (Creatures.Orientation) var orientation := Creatures.SOUTHEAST

## a unique id for this spawn point
export (String) var id: String

export (float) var elevation: float

## Relocates the specified creature to this spawn point.
func move_creature(creature: Creature) -> void:
	creature.position = position
	creature.orientation = orientation
	creature.elevation = elevation
	
	Stool.update_stool_occupied(self, true)
