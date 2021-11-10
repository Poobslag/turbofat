extends Node2D
## Conditionally spawns a creature on the overworld.
##
## The decision to spawn the creature is controlled by the 'spawn_if' property.
##
## The creature's creature_id, properties and groups (the 'chattables' group in particular) can be managed by the
## target_properties and target_groups fields.

export (NodePath) var overworld_world_path: NodePath = NodePath("../..")

## (optional) path to a stool the spawned creature sits on
export (NodePath) var stool_path: NodePath

## the properties of the spawned creature
export (Dictionary) var target_properties: Dictionary

## the groups of the spawned creature
export (Array) var target_groups: Array

## a boolean expression which, if evaluated to 'true', will result in the creature being spawned
export (String) var spawn_if: String

## Maximum fatness for a spawned creature.
## If a fatter creature spawns here, they will spontaneously and permanently slim down.
export (float) var max_fatness := 10.0

export (PackedScene) var CreatureScene: PackedScene

## a Stool or ObstacleSpawner instance for the stool the spawned creature sits on, if any
var _stool: Node2D

## the spawned creature, or 'null' if the creature has not yet spawned
var _target_creature: Creature

onready var _overworld_world: OverworldWorld = get_node(overworld_world_path)

func _ready() -> void:
	if stool_path:
		_stool = get_node(stool_path)
		_update_stool_occupied()
	
	if spawn_if and BoolExpressionEvaluator.evaluate(spawn_if):
		# Spawn the creature and remove the spawner from the scene tree.
		# This call is deferred to avoid a 'Parent node is busy setting up children' error.
		call_deferred("_spawn_target")
	else:
		# Don't spawn the creature. Remove the spawner from the scene tree.
		queue_free()


## Updates the spawned creature's stool to be occupied or unoccupied.
func _update_stool_occupied() -> void:
	var occupied := _target_creature != null
	if _stool is ObstacleSpawner:
		_stool.set_target_property("occupied", occupied)
	else:
		_stool.occupied = occupied


## Spawns the creature and removes the spawner from the scene tree.
func _spawn_target() -> void:
	if not is_inside_tree():
		# If the spawner was already removed from the scene tree, don't spawn the creature.
		# Spawners are removed from the scene tree during cutscenes.
		return
	
	# change the spawner's name to avoid conflicting with the spawned creature
	var old_name := name
	name = "CreatureSpawner"
	
	# create the creature, add it to the scene tree and assign its properties
	var creature_id: String = target_properties["creature_id"]
	_target_creature = _overworld_world.add_creature(creature_id, target_groups.has("chattables"))
	_target_creature.name = old_name
	_target_creature.position = position
	for key in target_properties:
		_target_creature.set(key, target_properties[key])
	if _target_creature.get_fatness() > max_fatness:
		_target_creature.set_fatness(max_fatness)
		_target_creature.set_visual_fatness(max_fatness)
		_target_creature.save_fatness(max_fatness)
	for group in target_groups:
		if group == "chattables":
			continue
		else:
			_target_creature.add_to_group(group)
	
	if _stool:
		# mark the creature's stool as occupied
		_update_stool_occupied()
	
	# remove the spawner from the scene tree
	queue_free()
