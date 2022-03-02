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


func prepare_environment_resource() -> void:
	# Load the cutscene's environment, replacing the current one in the scene tree.
	var environment_path := CurrentCutscene.chat_tree.chat_environment_path()
	EnvironmentScene = load(environment_path)


func _launch_cutscene() -> void:
	var overworld_ui := Global.get_overworld_ui()
	overworld_ui.cutscene = true
	if ChattableManager.player is Player:
		ChattableManager.player.input_disabled = true
	if ChattableManager.sensei is Sensei:
		ChattableManager.sensei.movement_disabled = true
	
	# remove all of the creatures from the overworld except for the player and sensei
	for node in get_tree().get_nodes_in_group("creatures"):
		if node != ChattableManager.player and node != ChattableManager.sensei:
			# remove it immediately so we don't find it in the tree later
			node.get_parent().remove_child(node)
			node.queue_free()
	
	for node in get_tree().get_nodes_in_group("creature_spawners"):
		node.get_parent().remove_child(node)
		node.queue_free()
	
	var cutscene_creature: Creature
	if CurrentLevel.creature_id:
		# add the cutscene creature
		cutscene_creature = overworld_environment.add_creature(CurrentLevel.creature_id)
	
	var chat_tree := CurrentCutscene.chat_tree
	
	if not chat_tree.spawn_locations and cutscene_creature:
		# apply a default position to the cutscene creature
		cutscene_creature.position = ChattableManager.player.position
		cutscene_creature.position += Vector2(cutscene_creature.chat_extents.x, 0)
		cutscene_creature.position += Vector2(ChattableManager.player.chat_extents.x, 0)
		cutscene_creature.position += Vector2(60, 0)
	else:
		for creature_id in chat_tree.spawn_locations:
			var creature: Creature = overworld_environment.find_creature(creature_id)
			if not creature:
				creature = overworld_environment.add_creature(creature_id)
			creature.set_collision_disabled(true)
			
			# move the creature to its spawn location
			overworld_environment.move_creature_to_spawn(creature, chat_tree.spawn_locations[creature_id])
	
	yield(get_tree(), "idle_frame")
	overworld_ui.start_chat(chat_tree, cutscene_creature)
	_camera.snap_into_position()
	
	if not chat_tree.spawn_locations and cutscene_creature:
		overworld_ui.make_chatters_face_eachother()
