extends Area2D
## Moves crowd members after the player runs past them.
##
## This lets us reuse the same ~150 crowd members instead of creating ~1,500 crowd members. This probably has a
## performance benefit, but honestly it's just cumbersome to maintain that many nodes in a scene.

export (NodePath) var target_path: NodePath

## The direction and distance which crowd members should move after the player runs past them.
var _move_direction: Vector2

## 'True' if the crowd walk director just moved all of the crowd members. When this happens, we take measures to avoid
## moving them a second time, which would result in them overshooting the camera area.
var _just_creatures_arranged := false

onready var _target: Node2D = get_node(target_path)

## When the crowd walk director moves all crowd members, we temporarily ignore collisions. This timer reenables
## collisions afterward.
onready var _reenable_collision_timer := $ReenableCollisionTimer

func _ready() -> void:
	_move_direction = $MoveDirection.points[1] - $MoveDirection.points[0]


func _process(_delta: float) -> void:
	position = _target.position


## Move a crowd member and change their appearance.
func _move_crowd(crowd: Node2D) -> void:
	crowd.position += _move_direction
	crowd.set_shuffle(true)


## When the player runs past a crowd member, we move the crowd member and change their appearance.
func _on_body_entered(body: Node2D) -> void:
	if _just_creatures_arranged:
		return
	
	_move_crowd(body)


## When the crowd walk director moves all crowd members, we temporarily ignore collisions.
func _on_CrowdWalkDirector_creatures_arranged() -> void:
	_just_creatures_arranged = true
	_reenable_collision_timer.start()


## When the crowd walk director moves all crowd members, we temporarily ignore collisions. This method reenables
## collisions afterward.
func _on_ReenableCollisionTimer_timeout() -> void:
	_just_creatures_arranged = false
	
	# move all overlapping crowd members
	for crowd in get_tree().get_nodes_in_group("recyclable_crowds"):
		if overlaps_body(crowd):
			_move_crowd(crowd)
