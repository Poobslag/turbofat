extends Node
## Provides access to creature sprites based on their creature id.

## The player's sprite
## virtual property; value is only exposed through getters/setters
var player: Creature setget ,get_player

## The sensei's sprite
## virtual property; value is only exposed through getters/setters
var sensei: Creature setget ,get_sensei

## Mapping from creature ids to Creature objects. The player and sensei are omitted from this mapping, as the player
## can set their own name and it could conflict with overworld creatures.
##
## key: creature id as it appears in chat files
## value: Creature object corresponding to the creature id
var _creatures_by_id := {}

func _ready() -> void:
	Breadcrumb.connect("before_scene_changed", self, "_on_Breadcrumb_before_scene_changed")


## Populates the '_creatures_by_id' mapping.
func refresh_creatures() -> void:
	_creatures_by_id.clear()
	for creature in get_tree().get_nodes_in_group("creatures"):
		register_creature(creature)


func register_creature(creature: Creature) -> void:
	if creature.creature_id:
		_creatures_by_id[creature.creature_id] = creature


## Returns the Creature object corresponding to the specified creature id.
##
## An id of SENSEI_ID or PLAYER_ID will return the sensei or player object.
func get_creature_by_id(creature_id: String) -> Creature:
	return _creatures_by_id.get(creature_id)


func get_player() -> Creature:
	return _creatures_by_id.get(CreatureLibrary.PLAYER_ID)


func get_sensei() -> Creature:
	return _creatures_by_id.get(CreatureLibrary.SENSEI_ID)


## Purges all node instances from the manager.
##
## Because CreatureManager is a singleton, node instances must be purged before changing scenes. Otherwise it's
## possible it will provide access to an invisible object from a previous scene.
func _on_Breadcrumb_before_scene_changed() -> void:
	_creatures_by_id.clear()
