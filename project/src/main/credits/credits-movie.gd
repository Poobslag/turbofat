extends Node2D
## Plays different movies during the credits scroll.

export (PackedScene) var CrowdWalkCutsceneScene: PackedScene

onready var _viewport := $ViewportContainer/Viewport

## Plays a cutscene where the player and Fat Sensei walk through a cheering crowd.
func play_crowd_walk_cutscene(time_until_launch: float) -> void:
	var crowd_walk_cutscene := CrowdWalkCutsceneScene.instance()
	_replace_cutscene(crowd_walk_cutscene)
	crowd_walk_cutscene.prepare_launch_timer(time_until_launch)


func _replace_cutscene(new_cutscene: Node) -> void:
	# remove the old cutscene
	for child in _viewport.get_children():
		child.queue_free()
		_viewport.remove_child(child)
	
	# add the new cutscene
	_viewport.add_child(new_cutscene)
