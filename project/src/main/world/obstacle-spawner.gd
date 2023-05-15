class_name ObstacleSpawner
extends Sprite2D
## Conditionally spawns an obstacle on the overworld.
##
## The decision to spawn the obstacle is controlled by the 'spawn_if' property.
##
## The obstacle's properties and groups can be managed by the target_properties and target_groups fields.

@export (NodePath) var overworld_environment_path: NodePath = NodePath("../..")

## PackedScene of the spawned obstacle
@export (PackedScene) var TargetScene: PackedScene

## properties of the spawned obstacle
@export (Dictionary) var target_properties: Dictionary

## boolean expression which, if evaluated to 'true', will result in the obstacle being spawned
@export (String) var spawn_if: String

## spawned object, or 'null' if the object has not yet spawned
var spawned_object: Node2D

@onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)

func _ready() -> void:
	if Engine.is_editor_hint():
		# Don't spawn/free nodes in the editor. (Some of our children are tool scripts.)
		pass
	elif spawn_if.is_empty() or BoolExpressionEvaluator.evaluate(spawn_if):
		# Spawn the obstacle, and remove the spawner from the scene tree.
		# This call is deferred to avoid a 'Parent node is busy setting up children' error.
		call_deferred("spawn_target")
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
	if spawned_object:
		# if the object has spawned we need to update the target_object directly
		spawned_object.set(property, value)


## Spawns the obstacle and removes the spawner from the scene tree.
func spawn_target() -> void:
	# change the spawner's name to avoid conflicting with the spawned object
	var old_name := name
	name = "ObstacleSpawner"
	
	# create the object and assign its properties
	spawned_object = TargetScene.instantiate()
	spawned_object.name = old_name
	spawned_object.position = position
	for key in target_properties:
		spawned_object.set(key, target_properties[key])
	
	# add it to the scene tree
	_overworld_environment.add_obstacle_below_node(self, spawned_object)
	
	# remove the spawner from the scene tree
	queue_free()
