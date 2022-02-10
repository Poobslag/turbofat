class_name StoryData
## Stores transient data for story mode.
##
## This includes the location of the player and sensei.

## the id of the spawn where the player appears on the overworld
var player_spawn_id: String

## the id of the spawn where the sensei appears on the overworld
var sensei_spawn_id: String

func reset() -> void:
	player_spawn_id = ""
	sensei_spawn_id = ""
