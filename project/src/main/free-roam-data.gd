class_name FreeRoamData
## Stores transient data for free roam mode.
##
## This includes the environment which should be loaded.

## the path of the overworld environment scene which should be loaded
var environment_path: String

## the id of the spawn where the player appears on the overworld
var player_spawn_id: String

## the id of the spawn where the sensei appears on the overworld
var sensei_spawn_id: String

func reset() -> void:
	environment_path = ""
	player_spawn_id = ""
	sensei_spawn_id = ""
