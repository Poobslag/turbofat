extends Node
## Provides access to creature sprites based on their creature id.

## Player's sprite
## virtual property; value is only exposed through getters/setters
var player: Creature: get = get_player

## Sensei's sprite
## virtual property; value is only exposed through getters/setters
var sensei: Creature: get = get_sensei


## Returns the Creature object corresponding to the specified creature id.
##
## An id of SENSEI_ID or PLAYER_ID will return the sensei or player object.
func get_creature_by_id(creature_id: String) -> Creature:
	var creature: Creature
	
	for creature_node in get_tree().get_nodes_in_group("creatures"):
		if creature_node.creature_id == creature_id:
			creature = creature_node
			break
	
	return creature


func get_player() -> Creature:
	return get_creature_by_id(CreatureLibrary.PLAYER_ID)


func get_sensei() -> Creature:
	return get_creature_by_id(CreatureLibrary.SENSEI_ID)
