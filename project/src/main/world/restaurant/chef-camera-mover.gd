extends AnimationPlayer
## Moves the restaurant scene's camera to keep fat chefs in frame.
##
## While this is an AnimationPlayer, the animation is only used to calculate the camera position. It shouldn't ever be
## played as an animation.

export (NodePath) var restaurant_scene_path: NodePath

onready var _restaurant_scene: RestaurantPuzzleScene = get_node(restaurant_scene_path)

func _ready() -> void:
	play("fat-se")
	advance(_restaurant_scene.get_chef().get_visual_fatness())
	stop()
