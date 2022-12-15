extends ViewportContainer
## Shows the player's chef character in the restaurant scene.

export (NodePath) var restaurant_viewport_path: NodePath

func _ready() -> void:
	$Viewport.world_2d = get_node(restaurant_viewport_path).world_2d if restaurant_viewport_path else null
	$Viewport.size = rect_size * 4
