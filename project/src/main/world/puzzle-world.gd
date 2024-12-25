tool
class_name PuzzleWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles during puzzles.

## The path to the scene resources defining creatures and obstacles for career regions which do not specify an
## environment, or regions which specify an invalid environment
const DECORATED_PUZZLE_ENVIRONMENT_PATH := "res://src/main/world/environment/restaurant/TurboFatEnvironment.tscn"
const UNDECORATED_PUZZLE_ENVIRONMENT_PATH \
		:= "res://src/main/world/environment/restaurant/UndecoratedTurboFatEnvironment.tscn"

## key: (String) an Environment id which appears in the json definitions
## value: (String) Path to the scene resource defining creatures and obstacles which appear in
## 	that environment
const ENVIRONMENT_PATH_BY_ID := {
	"lemon": "res://src/main/world/environment/lemon/LemonRestaurantEnvironment.tscn",
	"marsh": "res://src/main/world/environment/restaurant/TurboFatEnvironment.tscn",
	"lava/zagma": "res://src/main/world/environment/lava/ZagmaEnvironment.tscn"
}

var customers := []
var chef: Creature

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	_remove_all_creatures()
	_spawn_chef()
	_spawn_customers()


func initial_environment_path() -> String:
	var result: String = ENVIRONMENT_PATH_BY_ID.get(CurrentLevel.puzzle_environment_id, \
			DECORATED_PUZZLE_ENVIRONMENT_PATH)
	
	# if the player hasn't gotten far enough in the story, they don't have a nice decorated restaurant
	if result == DECORATED_PUZZLE_ENVIRONMENT_PATH \
			and not PlayerData.career.is_restaurant_decorated():
		result = UNDECORATED_PUZZLE_ENVIRONMENT_PATH
	
	return result


## Removes all creatures from the overworld.
func _remove_all_creatures() -> void:
	for node in overworld_environment.get_creatures():
		node.get_parent().remove_child(node)
		node.queue_free()
	
	for node in overworld_environment.get_creature_spawners():
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
	if not is_inside_tree():
		return
	
	for spawn_obj in get_tree().get_nodes_in_group("spawns"):
		if not overworld_environment.is_a_parent_of(spawn_obj):
			continue
		var spawn: Spawn = spawn_obj
		if not spawn.id.begins_with("customer_"):
			continue
		var customer := overworld_environment.add_creature()
		overworld_environment.move_creature_to_spawn(customer, spawn.id)
		customers.append(customer)
