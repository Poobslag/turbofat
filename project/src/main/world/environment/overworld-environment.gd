
class_name OverworldEnvironment
extends Node
## Maintains creatures and obstacles for an overworld scene

const SCENE_EMPTY_ENVIRONMENT := "res://src/main/world/environment/EmptyEnvironment.tscn"

export (NodePath) var environment_shadows_path: NodePath
export (NodePath) var obstacles_path: NodePath
export (PackedScene) var CreatureScene: PackedScene

onready var _obstacles: Node2D = get_node(obstacles_path)
onready var _environment_shadows: OutdoorShadows = get_node(environment_shadows_path)

## Adds a new obstacle. The obstacle is placed below the given node in the list of children.
func add_obstacle_below_node(node: Node2D, child_node: Node2D) -> void:
	_obstacles.add_child_below_node(node, child_node)
	process_new_obstacle(child_node)


func add_obstacle(node: Node2D) -> void:
	_obstacles.add_child(node)
	process_new_obstacle(node)


## Relocate a creature to a spawn point.
func move_creature_to_spawn(creature: Creature, spawn_id: String) -> void:
	var target_spawn: Spawn
	for spawn_obj in get_tree().get_nodes_in_group("spawns"):
		var spawn: Spawn = spawn_obj
		if spawn.id == spawn_id:
			target_spawn = spawn
		elif spawn.id == spawn_id.trim_prefix("!"):
			# Spawn locations prefixed with a '!' indicate that the creature should spawn invisible.
			creature.visible = false
			target_spawn = spawn

	if target_spawn:
		target_spawn.move_creature(creature)
	else:
		push_warning("Could not locate spawn with id '%s'" % [spawn_id])


## Creates a new creature with the specified creature_id and adds it to the scene.
##
## Parameters:
## 	'creature_id': (Optional) The id of a creature to load from the CreatureLibrary. If omitted, the returned
## 		creature will assume a default appearance.
##
## 	'_chattable': Unused.
func add_creature(creature_id: String = "") -> Creature:
	var creature: Creature = CreatureScene.instance()
	creature.creature_id = creature_id
	_obstacles.add_child(creature)
	process_new_obstacle(creature)
	return creature


## Creates shadows and chat icons when an obstacle is added to the world.
func process_new_obstacle(obstacle: Node2D) -> void:
	if not is_inside_tree():
		return
	
	# create shadow
	if obstacle is Creature:
		_environment_shadows.create_creature_shadow(obstacle)
	else:
		_environment_shadows.create_shadow_caster_shadow(obstacle)
