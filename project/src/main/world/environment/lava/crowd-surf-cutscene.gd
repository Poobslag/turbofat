extends Node
## A unique cutscene where the player and Fat Sensei crowd surf on a cheering crowd.

onready var _crowd_surf_director: CrowdSurfDirector = $Environment/CrowdSurfDirector

func play() -> void:
	_crowd_surf_director.play()
