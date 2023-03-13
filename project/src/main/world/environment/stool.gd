tool
class_name Stool
extends OverworldObstacle
## A stool which appears on the overworld.
##
## The stool can toggle to an 'occupied' state when it's sat upon. This affects its collisions and appearance.

## the texture to use when the stool has a creature sitting on it
export (Texture) var occupied_texture: Texture

## the texture to use when the stool does not have a creature sitting on it
export (Texture) var unoccupied_texture: Texture

## 'true' if the stool has a creature sitting on it
export (bool) var occupied := false setget set_occupied

onready var _sprite := $Sprite

func _ready() -> void:
	_refresh_occupied()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_sprite = $Sprite


func _refresh_occupied() -> void:
	if not is_inside_tree():
		return
	
	if occupied:
		# enable the shadow and disable collision. this allows a creature to overlap the stool
		collision_layer = 0
		collision_mask = 0
		_sprite.texture = occupied_texture
	else:
		# disable the shadow and enable collision
		collision_layer = 1
		collision_mask = 1
		_sprite.texture = unoccupied_texture


func set_occupied(new_occupied: bool) -> void:
	occupied = new_occupied
	_refresh_occupied()
