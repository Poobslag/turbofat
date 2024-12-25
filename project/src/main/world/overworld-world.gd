tool
class_name OverworldWorld
extends Node
## Populates/unpopulates creatures and obstacles for various overworld scenes.

## Emitted when we load a new environment, replacing the current one in the scene tree.
signal overworld_environment_changed(value)

## Creatures and obstacles to show
export (Resource) var EnvironmentScene: Resource setget set_environment_scene

onready var overworld_environment: OverworldEnvironment = $Environment

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	var initial_environment_path := initial_environment_path()
	if initial_environment_path:
		set_environment_scene(load(initial_environment_path()))


func set_environment_scene(new_environment_scene: Resource) -> void:
	EnvironmentScene = new_environment_scene
	_refresh_environment_scene()


## Overridden by child implementations to substitute their own EnvironmentScene resource at runtime.
func initial_environment_path() -> String:
	return ""


## Loads a new environment, replacing the current one in the scene tree.
##
## The environment loaded is the one defined by EnvironmentScene. To substitute a different scene at runtime, child
## implementations can override initial_environment_path.
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
	overworld_environment = null
	
	# insert new environment node
	if EnvironmentScene:
		overworld_environment = EnvironmentScene.instance()
	else:
		var empty_environment_scene := load(OverworldEnvironment.SCENE_EMPTY_ENVIRONMENT)
		overworld_environment = empty_environment_scene.instance()
	add_child(overworld_environment)
	move_child(overworld_environment, 0)
	overworld_environment.owner = get_tree().get_edited_scene_root() if is_inside_tree() else null
	
	emit_signal("overworld_environment_changed", overworld_environment)
