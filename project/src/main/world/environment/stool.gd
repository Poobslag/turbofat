extends "res://src/main/world/environment/overworld-obstacle.gd"
"""
A stool which appears on the overworld.

The stool can toggle to an 'occupied' state when it's sat upon. This affects its collisions and appearance.
"""

# 'true' if the stool has a creature sitting on it
export (bool) var occupied := false setget set_occupied

func _ready() -> void:
	_refresh_occupied()


func _refresh_occupied() -> void:
	if not is_inside_tree():
		return
	
	if occupied:
		# enable the shadow and disable collision. this allows a creature to overlap the stool
		collision_layer = 0
		collision_mask = 0
		$Sprite.texture = preload("res://assets/main/world/restaurant/stool-occupied.png")
	else:
		# disable the shadow and enable collision
		collision_layer = 1
		collision_mask = 1
		$Sprite.texture = preload("res://assets/main/world/restaurant/stool.png")


func set_occupied(new_occupied: bool) -> void:
	occupied = new_occupied
	_refresh_occupied()
