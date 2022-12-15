class_name Spawn
extends Node2D
## A point where a creature can appear on the overworld.

## the direction the creature will face
export (Creatures.Orientation) var orientation := Creatures.SOUTHEAST

## (optional) path to a stool the spawned creature sits on
export (NodePath) var stool_path: NodePath

## a unique id for this spawn point
export (String) var id: String

export (float) var elevation: float

## stool the creature sits on, if any
var _stool: Stool

func _ready() -> void:
	_stool = get_node(stool_path) if stool_path else null


## Relocates the specified creature to this spawn point.
func move_creature(creature: Creature) -> void:
	creature.position = position
	creature.orientation = orientation
	creature.elevation = elevation
	
	if _stool:
		_stool.occupied = true
