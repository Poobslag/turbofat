extends Node2D
"""
The 'seat' scene includes a creature and some furniture, all of which cast shadows. But the 'seat' scene does not
contain the shadows itself, since they need to appear behind other objects outside of this scene.

This script contains logic for scaling an injected 'creature shadow' object as the creature grows in size.
"""

var _creature: Creature setget set_creature
var _door_sound_position: Vector2

func set_creature(creature: Creature) -> void:
	_creature = creature
	refresh()


"""
Updates the properties of the seat and the creature sitting in it.
"""
func refresh() -> void:
	if _creature and _creature.is_visible_in_tree():
		# draw a shadow on the creature's stool
		$Stool0L.texture = preload("res://assets/main/world/restaurant/stool-occupied.png")
		_creature.set_door_sound_position(_door_sound_position)
	else:
		# remove the shadow from the creature's stool
		$Stool0L.texture = preload("res://assets/main/world/restaurant/stool.png")


"""
Sets the relative position of sound effects related to the restaurant door. Each seat has a different position
relative to the restaurant's entrance; some are close to the door, some are far away.

Parameter: 'position' is the position of the door relative to this seat, in world coordinates.
"""
func set_door_sound_position(door_sound_position: Vector2) -> void:
	_door_sound_position = door_sound_position
	refresh()
