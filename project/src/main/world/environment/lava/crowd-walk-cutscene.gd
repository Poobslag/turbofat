extends Node
## A unique cutscene where the player and Fat Sensei walk through a cheering crowd.

onready var _crowd_walk_director: CrowdWalkDirector = $Environment/CrowdWalkDirector

func prepare_launch_timer(time_until_launch: float) -> void:
	_crowd_walk_director.prepare_launch_timer(time_until_launch)
