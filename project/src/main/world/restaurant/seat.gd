extends Node2D
"""
The 'seat' scene includes a creature and some furniture, all of which cast shadows. But the 'seat' scene does not
contain the shadows itself, since they need to appear behind other objects outside of this scene.

This script contains logic for scaling an injected 'creature shadow' object as the creature grows in size.
"""

var _creature: Creature setget set_creature

func set_creature(new_creature: Creature) -> void:
	_creature = new_creature
	refresh()


"""
Updates the properties of the seat and the creature sitting in it.
"""
func refresh() -> void:
	if _creature and _creature.is_visible_in_tree():
		# draw a shadow on the creature's stool
		$Stool0L.texture = preload("res://assets/main/world/restaurant/stool-occupied.png")
	else:
		# remove the shadow from the creature's stool
		$Stool0L.texture = preload("res://assets/main/world/restaurant/stool.png")
