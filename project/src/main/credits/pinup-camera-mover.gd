extends AnimationPlayer
## Moves the pinup's camera to accomodate creatures of different size.
##
## While this is an AnimationPlayer, the animation is only used to calculate the camera position. It shouldn't ever be
## played as an animation.

export (NodePath) var creature_path: NodePath

onready var _creature := get_node(creature_path)

func _ready() -> void:
	_refresh_zoom_and_headroom()


## Updates the 'zoom' and 'headroom' properties used to position the camera.
##
## These properties are updated by advancing this AnimationPlayer.
func _refresh_zoom_and_headroom() -> void:
	if not is_inside_tree() or not _creature:
		return
	
	play("fat-se")
	advance(_creature.visual_fatness)
	stop()


func _on_Creature_visual_fatness_changed() -> void:
	_refresh_zoom_and_headroom()
