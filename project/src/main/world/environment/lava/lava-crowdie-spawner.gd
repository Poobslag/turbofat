extends Node2D
## Conditionally spawns a chocolava canyon crowdie which appears in the credits.
##
## This spawner can be activated with the 'lava_crowd spawn' chatscript flag.

export (NodePath) var overworld_environment_path: NodePath = NodePath("../..") setget set_overworld_environment_path

## PackedScene of the spawned crowd
export (PackedScene) var LavaCrowdieScene: PackedScene

## spawned crowd, or 'null' if the crowd has not yet spawned
var spawned_lava_crowdie: LavaCrowdie

var _overworld_environment: OverworldEnvironment

func _ready() -> void:
	_refresh_overworld_environment_path()
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")


func set_overworld_environment_path(new_overworld_environment_path: NodePath) -> void:
	overworld_environment_path = new_overworld_environment_path
	_refresh_overworld_environment_path()


func _refresh_overworld_environment_path() -> void:
	if not is_inside_tree():
		return
	
	_overworld_environment = get_node(overworld_environment_path) if overworld_environment_path else null


## Spawns the crowd and removes the spawner from the scene tree.
func _spawn_target() -> void:
	# change the spawner's name to avoid conflicting with the spawned crowd
	var old_name := name
	name = "LavaCrowdieSpawner"
	
	# create the crowd and assign its properties
	spawned_lava_crowdie = LavaCrowdieScene.instance()
	spawned_lava_crowdie.name = old_name
	spawned_lava_crowdie.position = position
	
	# add it to the scene tree
	_overworld_environment.add_obstacle_below_node(self, spawned_lava_crowdie)
	
	spawned_lava_crowdie.gaze_target_path = spawned_lava_crowdie.get_path_to(_overworld_environment.player)
	spawned_lava_crowdie.set_shuffle(true)
	
	# remove the spawner from the scene tree
	queue_free()


## Listen for 'lava_crowd' chat events and spawn crowd instances.
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"lava_crowd spawn":
			_spawn_target()
