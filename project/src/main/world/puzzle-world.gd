tool
class_name PuzzleWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles during puzzles.

## The path to the scene resource defining creatures and obstacles for career regions which do not specify an
## environment, or regions which specify an invalid environment
const DEFAULT_PUZZLE_ENVIRONMENT_PATH := "res://src/main/world/environment/marsh/MarshIndoorsEnvironment.tscn"

## key: (String) an environment name which appears in the json definitions
## value: (String) The path to the scene resource defining creatures and obstacles which appear in
## 	that environment
const ENVIRONMENT_PATH_BY_NAME := {
	"lemon": "res://src/main/world/environment/lemon/LemonRestaurantEnvironment.tscn",
	"marsh": "res://src/main/world/environment/marsh/MarshIndoorsEnvironment.tscn",
}

var customers := []
var chef: Creature

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_remove_all_creatures()
	_spawn_chef()
	_spawn_customers()


# Loads the cutscene's environment, replacing the current one in the scene tree.
func prepare_environment_resource() -> void:
	var environment_path: String = ENVIRONMENT_PATH_BY_NAME.get(
			CurrentLevel.puzzle_environment_name, DEFAULT_PUZZLE_ENVIRONMENT_PATH)
	EnvironmentScene = load(environment_path)


## Removes all creatures from the overworld.
func _remove_all_creatures() -> void:
	for node in get_tree().get_nodes_in_group("creatures"):
		node.get_parent().remove_child(node)
		node.queue_free()
	
	for node in get_tree().get_nodes_in_group("creature_spawners"):
		node.get_parent().remove_child(node)
		node.queue_free()


## Add the chef creature to the environment.
##
## The chef creature is spawned at the spawn with an id of 'chef'.
func _spawn_chef() -> void:
	var chef_id := StringUtils.default_if_empty(CurrentLevel.chef_id, CreatureLibrary.PLAYER_ID)
	chef = overworld_environment.add_creature(chef_id)
	overworld_environment.move_creature_to_spawn(chef, "chef")


## Add the customer creatures to the environment.
##
## The chef creature is spawned at the spawn with ids like 'customer_1', 'customer_2'. The numbers are not used.
func _spawn_customers() -> void:
	for spawn_obj in get_tree().get_nodes_in_group("spawns"):
		var spawn: Spawn = spawn_obj
		if not spawn.id.begins_with("customer_"):
			continue
		var customer := overworld_environment.add_creature()
		overworld_environment.move_creature_to_spawn(customer, spawn.id)
		customers.push_back(customer)
