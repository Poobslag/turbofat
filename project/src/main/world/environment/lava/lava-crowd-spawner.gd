extends Node2D
## Conditionally spawns a chocolava canyon crowd member which appears in the credits.
##
## This spawner can be activated with the 'lava_crowd spawn' chatscript flag.

export (NodePath) var overworld_environment_path: NodePath = NodePath("../..")

## PackedScene of the spawned crowd
export (PackedScene) var LavaCrowdScene: PackedScene

## spawned crowd, or 'null' if the crowd has not yet spawned
var spawned_lava_crowd: LavaCrowd

onready var _overworld_environment: OverworldEnvironment = get_node(overworld_environment_path)

func _ready() -> void:
	if Global.get_overworld_ui():
		Global.get_overworld_ui().connect("chat_event_meta_played", self, "_on_OverworldUi_chat_event_meta_played")


## Spawns the crowd and removes the spawner from the scene tree.
func _spawn_target() -> void:
	# change the spawner's name to avoid conflicting with the spawned crowd
	var old_name := name
	name = "LavaCrowdSpawner"
	
	# create the crowd and assign its properties
	spawned_lava_crowd = LavaCrowdScene.instance()
	spawned_lava_crowd.name = old_name
	spawned_lava_crowd.position = position
	
	# add it to the scene tree
	_overworld_environment.add_obstacle_below_node(self, spawned_lava_crowd)
	
	spawned_lava_crowd.gaze_target_path = spawned_lava_crowd.get_path_to(CreatureManager.get_player())
	spawned_lava_crowd.set_shuffle(true)
	
	# remove the spawner from the scene tree
	queue_free()


## Listen for 'lava_crowd' chat events and spawn crowd instances.
func _on_OverworldUi_chat_event_meta_played(meta_item: String) -> void:
	match meta_item:
		"lava_crowd spawn":
			_spawn_target()
