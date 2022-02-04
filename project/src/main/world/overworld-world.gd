tool
class_name OverworldWorld
extends Node
## Populates/unpopulates the creatures and obstacles on the overworld.

## Scene resource defining the obstacles and creatures to show
export (Resource) var EnvironmentScene: Resource setget set_environment_scene

onready var _overworld_ui: OverworldUi = Global.get_overworld_ui()
onready var _overworld_environment: OverworldEnvironment = $Environment

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_refresh_environment_scene()
	
	_overworld_ui = Global.get_overworld_ui()
	
	if not Breadcrumb.trail:
		# For developers accessing the Overworld scene directly, we initialize a default Breadcrumb trail.
		# For regular players the Breadcrumb trail will already be initialized by the menus.
		Breadcrumb.initialize_trail()
	
	MusicPlayer.play_chill_bgm()
	
	ChattableManager.refresh_creatures()
	if CurrentCutscene.chat_tree:
		_launch_cutscene()
	else:
		if Global.player_spawn_id:
			_overworld_environment.move_creature_to_spawn(ChattableManager.player, Global.player_spawn_id)
		
		if Global.sensei_spawn_id:
			_overworld_environment.move_creature_to_spawn(ChattableManager.sensei, Global.sensei_spawn_id)
	
	$Camera.position = ChattableManager.player.position


func set_environment_scene(new_environment_scene: Resource) -> void:
	EnvironmentScene = new_environment_scene
	_refresh_environment_scene()


## Loads a new overworld environment, replacing the current one in the scene tree.
func _refresh_environment_scene() -> void:
	if not is_inside_tree():
		return
	
	# delete old environment nodes
	for old_overworld_environment in get_tree().get_nodes_in_group("overworld_environments"):
		if old_overworld_environment.get_parent() != self:
			# only remove our direct children
			continue
		old_overworld_environment.queue_free()
		remove_child(old_overworld_environment)
	_overworld_environment = null
	
	# insert new environment node
	if EnvironmentScene:
		_overworld_environment = EnvironmentScene.instance()
	else:
		var empty_environment_scene := load(OverworldEnvironment.SCENE_EMPTY_ENVIRONMENT)
		_overworld_environment = empty_environment_scene.instance()
	add_child(_overworld_environment)
	move_child(_overworld_environment, 0)
	_overworld_environment.owner = get_tree().get_edited_scene_root()
	
	# create chat icons for all chattables
	if not Engine.editor_hint:
		var chat_icons := Global.get_chat_icon_container()
		if chat_icons:
			chat_icons.recreate_all_icons()


func _launch_cutscene() -> void:
	_overworld_ui.cutscene = true
	ChattableManager.player.input_disabled = true
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
		cutscene_creature = _overworld_environment.add_creature(CurrentLevel.creature_id)
	
	var chat_tree := CurrentCutscene.chat_tree
	
	if not chat_tree.spawn_locations and cutscene_creature:
		# apply a default position to the cutscene creature
		cutscene_creature.position = ChattableManager.player.position
		cutscene_creature.position += Vector2(cutscene_creature.chat_extents.x, 0)
		cutscene_creature.position += Vector2(ChattableManager.player.chat_extents.x, 0)
		cutscene_creature.position += Vector2(60, 0)
	else:
		for creature_id in chat_tree.spawn_locations:
			var creature: Creature = _overworld_environment.find_creature(creature_id)
			if not creature:
				creature = _overworld_environment.add_creature(creature_id)
			creature.set_collision_disabled(true)
			
			# move the creature to its spawn location
			_overworld_environment.move_creature_to_spawn(creature, chat_tree.spawn_locations[creature_id])
	
	yield(get_tree(), "idle_frame")
	_overworld_ui.start_chat(chat_tree, cutscene_creature)
	
	if not chat_tree.spawn_locations and cutscene_creature:
		_overworld_ui.make_chatters_face_eachother()
