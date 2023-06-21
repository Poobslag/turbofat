#@tool
class_name CutsceneWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles during cutscenes.

@onready var _camera: CutsceneCamera = $Camera2D

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	
	if CurrentCutscene.chat_tree.meta.has("fixed_zoom"):
		_camera.fixed_zoom = CurrentCutscene.chat_tree.meta["fixed_zoom"]
	
	MusicPlayer.play_chill_bgm()
	_launch_cutscene()


func get_initial_environment_path() -> String:
	return CurrentCutscene.chat_tree.chat_environment_path()


## Starts the cutscene.
##
## Replaces the environment's creatures with those necessary for the cutscene and plays the cutscene's chat tree.
func _launch_cutscene() -> void:
	_remove_all_creatures()
	_add_cutscene_creatures()
	_arrange_creatures()
	
	await get_tree().process_frame

	Global.get_overworld_ui().start_chat(CurrentCutscene.chat_tree)
	_camera.snap_into_position()


## Removes all creatures from the overworld except for the player and sensei.
func _remove_all_creatures() -> void:
	for node in get_tree().get_nodes_in_group("creatures"):
		if node is WalkingBuddy:
			# don't remove 'walking buddies'
			continue
		
		# remove the creature immediately so we don't find it in the tree later
		node.get_parent().remove_child(node)
		node.queue_free()
	
	for node in get_tree().get_nodes_in_group("creature_spawners"):
		node.get_parent().remove_child(node)
		node.queue_free()


## Adds all creatures referenced by the cutscene's chat tree.
func _add_cutscene_creatures() -> void:
	for creature_id in CurrentCutscene.chat_tree.spawn_locations:
		var creature: Creature = CreatureManager.get_creature_by_id(creature_id)
		if not creature:
			creature = overworld_environment.add_creature(creature_id)
		creature.set_collision_disabled(true)


## Moves all cutscene creatures to their proper locations.
func _arrange_creatures() -> void:
	for creature_id in CurrentCutscene.chat_tree.spawn_locations:
		var creature: Creature = CreatureManager.get_creature_by_id(creature_id)
		var spawn_id: String = CurrentCutscene.chat_tree.spawn_locations[creature_id]
		
		# move the creature to its spawn location
		overworld_environment.move_creature_to_spawn(creature, spawn_id)
