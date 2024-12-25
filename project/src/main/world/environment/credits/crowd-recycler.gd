extends Area2D
## Moves crowdies after the player runs past them.
##
## This lets us reuse the same ~150 crowdies instead of creating ~1,500 crowdies. This probably has a
## performance benefit, but honestly it's just cumbersome to maintain that many nodes in a scene.

export (NodePath) var target_path: NodePath

## The direction and distance which crowdies should move after the player runs past them.
var _move_direction: Vector2

## 'True' if the crowd walk director just moved all of the crowdies. When this happens, we take measures to avoid
## moving them a second time, which would result in them overshooting the camera area.
##
## Intuitively this property seems redundant with the 'monitoring' property but toggling the monitoring flag while
## shifting creatures around results in race conditions which can trigger collisions twice. We use this flag and leave
## it enabled for several frames to avoid race conditions.
var _just_arranged_creatures := false

onready var _target: Node2D = get_node(target_path)

## When the crowd walk director moves all crowdies, we temporarily ignore collisions. This timer reenables
## collisions afterward.
onready var _reenable_collision_timer := $ReenableCollisionTimer

func _ready() -> void:
	_move_direction = $MoveDirection.points[1] - $MoveDirection.points[0]


func _process(_delta: float) -> void:
	position = _target.position


## Move a crowdie and change their appearance.
func _move_crowd(crowd: Node2D) -> void:
	crowd.position += _move_direction
	crowd.set_shuffle(true)


## When the player runs past a crowdie, we move the crowdie and change their appearance.
func _on_body_entered(body: Node2D) -> void:
	if _just_arranged_creatures:
		return
	
	_move_crowd(body)


## When the crowd walk director moves all crowdies, we temporarily ignore collisions.
func _on_Director_played() -> void:
	# reenable monitoring; creatures will still not be recycled until the timer elapses
	monitoring = true
	
	_just_arranged_creatures = true
	_reenable_collision_timer.start()


func _on_Director_stopped() -> void:
	# disable monitoring to avoid conflicts between CrowdSurfEnvironment and CrowdWalkEnvironment. They both use this
	# recycler, and if both are active they can interact with crowdies in the other environment
	monitoring = false


## When the crowd walk director moves all crowdies, we temporarily ignore collisions. This method reenables
## collisions afterward.
func _on_ReenableCollisionTimer_timeout() -> void:
	if not is_inside_tree():
		return
	_just_arranged_creatures = false
	
	# move all overlapping crowdies
	for crowd in get_tree().get_nodes_in_group("recyclable_crowds"):
		if overlaps_body(crowd):
			_move_crowd(crowd)
