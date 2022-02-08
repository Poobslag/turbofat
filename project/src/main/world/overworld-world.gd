tool
class_name OverworldWorld
extends Node
## Populates/unpopulates the creatures and obstacles on the overworld.

## Scene resource defining the obstacles and creatures to show
export (Resource) var EnvironmentScene: Resource setget set_environment_scene

var _overworld_ui: OverworldUi

onready var _overworld_environment: OverworldEnvironment = $Environment

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_overworld_ui = Global.get_overworld_ui()
	
	if PlayerData.story.environment_path:
		EnvironmentScene = load(PlayerData.story.environment_path)
	_refresh_environment_scene()
	
	if not Breadcrumb.trail:
		# For developers accessing the Overworld scene directly, we initialize a default Breadcrumb trail.
		# For regular players the Breadcrumb trail will already be initialized by the menus.
		Breadcrumb.initialize_trail()
	
	MusicPlayer.play_chill_bgm()
	
	ChattableManager.refresh_creatures()
	if PlayerData.story.player_spawn_id:
		_overworld_environment.move_creature_to_spawn(ChattableManager.player, PlayerData.story.player_spawn_id)
	
	if PlayerData.story.sensei_spawn_id:
		_overworld_environment.move_creature_to_spawn(ChattableManager.sensei, PlayerData.story.sensei_spawn_id)
	
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
