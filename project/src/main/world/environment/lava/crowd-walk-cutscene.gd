extends Node
## A unique cutscene where the player and Fat Sensei walk through a cheering crowd.

onready var _crowd_walk_director: CrowdWalkDirector = $Environment/CrowdWalkDirector

func play(time_until_launch: float) -> void:
	_crowd_walk_director.play(time_until_launch)
