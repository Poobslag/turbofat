tool
class_name CutsceneWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles during cutscenes.

onready var _camera: CutsceneCamera = $Camera

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if CurrentCutscene.chat_tree.meta.has("fixed_zoom"):
		_camera.fixed_zoom = CurrentCutscene.chat_tree.meta["fixed_zoom"]
	
	MusicPlayer.play_chill_bgm()
	ChattableManager.refresh_creatures()
	_launch_cutscene()


# Loads the cutscene's environment, replacing the current one in the scene tree.
func prepare_environment_resource() -> void:
	var environment_path := CurrentCutscene.chat_tree.chat_environment_path()
	EnvironmentScene = load(environment_path)


## Starts the cutscene.
##
## Replaces the environment's creatures with those necessary for the cutscene and plays the cutscene's chat tree.
func _launch_cutscene() -> void:
	_remove_all_creatures()
	_add_level_creature()
	_add_cutscene_creatures()
	_arrange_creatures()
	
	yield(get_tree(), "idle_frame")
	
	_start_chat()


## Removes all creatures from the overworld except for the player and sensei.
func _remove_all_creatures() -> void:
	for node in get_tree().get_nodes_in_group("creatures"):
		if node != ChattableManager.player and node != ChattableManager.sensei:
			# remove it immediately so we don't find it in the tree later
			node.get_parent().remove_child(node)
			node.queue_free()
	
	for node in get_tree().get_nodes_in_group("creature_spawners"):
		node.get_parent().remove_child(node)
		node.queue_free()


# Adds the 'level creature', the creature the player interacted with to launch the level.
func _add_level_creature() -> void:
	var creature: Creature
	if CurrentLevel.creature_id:
		creature = overworld_environment.add_creature(CurrentLevel.creature_id)
		creature.set_collision_disabled(true)


## Locates the 'level creature', the creature the player spoke with to launch the level.
func _find_level_creature() -> Creature:
	return overworld_environment.find_creature(CurrentLevel.creature_id) if CurrentLevel.creature_id else null


## Adds all creatures referenced by the cutscene's chat tree.
func _add_cutscene_creatures() -> void:
	for creature_id in CurrentCutscene.chat_tree.spawn_locations:
		var creature: Creature = overworld_environment.find_creature(creature_id)
		if not creature:
			creature = overworld_environment.add_creature(creature_id)
		creature.set_collision_disabled(true)


## Moves all cutscene creatures to their proper locations.
func _arrange_creatures() -> void:
	if CurrentCutscene.chat_tree.spawn_locations:
		for creature_id in CurrentCutscene.chat_tree.spawn_locations:
			var creature: Creature = overworld_environment.find_creature(creature_id)
			var spawn_id: String = CurrentCutscene.chat_tree.spawn_locations[creature_id]
			
			# move the creature to its spawn location
			overworld_environment.move_creature_to_spawn(creature, spawn_id)
	else:
		var level_creature := _find_level_creature()
		if level_creature:
			# apply a default position to the cutscene creature
			level_creature.position = ChattableManager.player.position
			level_creature.position += Vector2(level_creature.chat_extents.x, 0)
			level_creature.position += Vector2(ChattableManager.player.chat_extents.x, 0)
			level_creature.position += Vector2(60, 0)


## Plays the cutscene's chat tree.
func _start_chat() -> void:
	var level_creature := _find_level_creature()
	var overworld_ui := Global.get_overworld_ui()
	overworld_ui.start_chat(CurrentCutscene.chat_tree, level_creature)
	_camera.snap_into_position()
	
	if not CurrentCutscene.chat_tree.spawn_locations and level_creature:
		overworld_ui.make_chatters_face_eachother()
