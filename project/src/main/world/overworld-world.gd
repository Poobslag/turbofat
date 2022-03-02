tool
class_name OverworldWorld
extends Node
## Populates/unpopulates creatures and obstacles for various overworld scenes.

## Scene resource defining the obstacles and creatures to show
export (Resource) var EnvironmentScene: Resource setget set_environment_scene

onready var overworld_environment: OverworldEnvironment = $Environment

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	prepare_environment_resource()
	refresh_environment_scene()


func set_environment_scene(new_environment_scene: Resource) -> void:
	EnvironmentScene = new_environment_scene
	refresh_environment_scene()


## Overridden by child implementations to substitute their own EnvironmentScene resource at runtime.
func prepare_environment_resource() -> void:
	pass


## Loads a new environment, replacing the current one in the scene tree.
##
## The environment loaded is the one defined by EnvironmentScene. To substitute a different scene at runtime, child
## implementations can override prepare_environment_resource.
func refresh_environment_scene() -> void:
	if not is_inside_tree():
		return
	
	# delete old environment nodes
	for old_overworld_environment in get_tree().get_nodes_in_group("overworld_environments"):
		if old_overworld_environment.get_parent() != self:
			# only remove our direct children
			continue
		old_overworld_environment.queue_free()
		remove_child(old_overworld_environment)
	overworld_environment = null
	
	# insert new environment node
	if EnvironmentScene:
		overworld_environment = EnvironmentScene.instance()
	else:
		var empty_environment_scene := load(OverworldEnvironment.SCENE_EMPTY_ENVIRONMENT)
		overworld_environment = empty_environment_scene.instance()
	add_child(overworld_environment)
	move_child(overworld_environment, 0)
	overworld_environment.owner = get_tree().get_edited_scene_root()
	
	# create chat icons for all chattables
	if not Engine.editor_hint:
		var chat_icons := Global.get_chat_icon_container()
		if chat_icons:
			chat_icons.recreate_all_icons()
