class_name ObstacleSpawner
extends Node2D
## Conditionally spawns an obstacle on the overworld.
##
## The decision to spawn the obstacle is controlled by the 'spawn_if' property.
##
## The obstacle's properties and groups (the 'chattables' group in particular) can be managed by the target_properties
## and target_groups fields.

export (NodePath) var obstacle_manager_path: NodePath = NodePath("../../../ObstacleManager")

## the PackedScene of the spawned obstacle
export (PackedScene) var TargetScene: PackedScene

## the properties of the spawned obstacle
export (Dictionary) var target_properties: Dictionary

## the groups of the spawned obstacle
export (Array) var target_groups: Array

## a boolean expression which, if evaluated to 'true', will result in the obstacle being spawned
export (String) var spawn_if: String

## the spawned object, or 'null' if the object has not yet spawned
var _spawned_object: Node2D

onready var _obstacle_manager: ObstacleManager = get_node(obstacle_manager_path)

func _ready() -> void:
	if not spawn_if or BoolExpressionEvaluator.evaluate(spawn_if):
		# Spawn the obstacle, and remove the spawner from the scene tree.
		# This call is deferred to avoid a 'Parent node is busy setting up children' error.
		call_deferred("_spawn_target")
	else:
		# Don't spawn the obstacle. Remove the spawner from the scene tree.
		queue_free()


## Assigns a new property, updating the spawned object if it has already been spawned.
##
## This method is useful for assigning properties during scene setup, when it's not always clear which order
## ObstacleSpawners resolve in or whether they've spawned an object yet.
func set_target_property(property: String, value) -> void:
	# if the object has not spawned we need to update our target_properties dictionary
	target_properties[property] = value
	if _spawned_object:
		# if the object has spawned we need to update the target_object directly
		_spawned_object.set(property, value)


## Spawns the obstacle and remove the spawner from the scene tree.
func _spawn_target() -> void:
	# change the spawner's name to avoid conflicting with the spawned object
	var old_name := name
	name = "ObstacleSpawner"
	
	# create the object and assign its properties
	_spawned_object = TargetScene.instance()
	_spawned_object.name = old_name
	_spawned_object.position = position
	for key in target_properties:
		_spawned_object.set(key, target_properties[key])
	for group in target_groups:
		_spawned_object.add_to_group(group)
	
	# add it to the scene tree
	_obstacle_manager.add_obstacle_below_node(self, _spawned_object)
	
	# remove the spawner from the scene tree
	queue_free()
