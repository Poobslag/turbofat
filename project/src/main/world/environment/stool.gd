tool
class_name Stool
extends OverworldObstacle
## Stool which appears on the overworld.
##
## The stool can toggle to an 'occupied' state when it's sat upon. This affects its collisions and appearance.

## maximum distance where a creature occupies a stool
const MAX_STOOL_DISTANCE := 4

## texture to use when the stool has a creature sitting on it
export (Texture) var occupied_texture: Texture

## texture to use when the stool does not have a creature sitting on it
export (Texture) var unoccupied_texture: Texture

## 'true' if the stool has a creature sitting on it
export (bool) var occupied := false setget set_occupied

onready var _sprite := $Sprite

func _ready() -> void:
	_refresh_occupied()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_sprite = $Sprite


func set_occupied(new_occupied: bool) -> void:
	occupied = new_occupied
	_refresh_occupied()


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


## Finds a stool at the specified Node2D's location.
##
## The specified Node2D should correspond to a creature in some way -- either the Creature themselves, or an object
## with the same location. This method returns a stool which is directly beneath the creature, if any.
##
## Parameters:
## 	'nearby_node2d': A Node2D whose corresponding stool should be returned.
##
## Returns:
## 	The stool which is directly beneath the creature, or 'null' if no stool is found.
static func find_stool(nearby_node2d: Node2D) -> Node2D:
	if not nearby_node2d.is_inside_tree():
		return null
	var result: Node2D
	
	for next_stool in nearby_node2d.get_tree().get_nodes_in_group("stools"):
		if not "position" in next_stool:
			push_warning("stool %s does not define a property 'position'" % [next_stool])
			continue
		
		if nearby_node2d.position.distance_to(next_stool.position) < MAX_STOOL_DISTANCE:
			result = next_stool
			break
	
	return result


## Updates any stool at the specified Node2D's location to be occupied or unoccupied.
##
## The specified Node2D should correspond to a creature in some way -- either the Creature themselves, or an object
## with the same location. This method returns a stool which is directly beneath the creature, if any.
##
## Parameters:
## 	'nearby_node2d': A Node2D whose corresponding stool should be updated.
##
## 	'new_occupied': 'true' if the stool has a creature sitting on it
static func update_stool_occupied(nearby_node2d: Node2D, new_occupied: bool) -> void:
	var stool := find_stool(nearby_node2d)
	if not stool:
		# stool not found
		pass
	elif "occupied" in stool:
		# stool is a stool
		stool.occupied = new_occupied
	elif "target_properties" in stool:
		# stool is an obstacle spawner which spawns a stool
		stool.set_target_property("occupied", new_occupied)
	else:
		push_warning("stool %s does not define a property 'occupied' or 'target_properties'")
