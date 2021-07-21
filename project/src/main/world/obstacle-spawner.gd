extends Node2D
"""
Conditionally spawns an obstacle on the overworld.

The decision to spawn the obstacle is controlled by the 'spawn_if' property.

The obstacle's properties and groups (the 'chattables' group in particular) can be managed by the target_properties and
target_groups fields.
"""

export (NodePath) var overworld_world_path: NodePath

# the PackedScene of the spawned obstacle
export (PackedScene) var TargetPackedScene: PackedScene

# the properties of the spawned obstacle
export (Dictionary) var target_properties: Dictionary

# the groups of the spawned obstacle
export (Array) var target_groups: Array

# a boolean expression which, if evaluated to 'true', will result in the obstacle being spawned
export (String) var spawn_if: String

onready var _overworld_world: OverworldWorld = get_node(overworld_world_path)

func _ready() -> void:
	if spawn_if and BoolExpressionEvaluator.evaluate(spawn_if):
		# Spawn the obstacle, and remove the spawner from the scene tree.
		# This call is deferred to avoid a 'Parent node is busy setting up children' error.
		call_deferred("_spawn_target")
	else:
		# Don't spawn the obstacle. Remove the spawner from the scene tree.
		queue_free()


"""
Spawns the obstacle and remove the spawner from the scene tree.
"""
func _spawn_target() -> void:
	# change the spawner's name to avoid conflicting with the spawned object
	var old_name := name
	name = "ObstacleSpawner"
	
	# create the object and assign its properties
	var target_object: Node2D = TargetPackedScene.instance()
	target_object.name = old_name
	target_object.position = position
	for key in target_properties:
		target_object.set(key, target_properties[key])
	for group in target_groups:
		target_object.add_to_group(group)
	
	# add it to the scene tree
	get_parent().add_child_below_node(self, target_object)
	_overworld_world.process_new_obstacle(target_object)
	
	# remove the spawner from the scene tree
	queue_free()
