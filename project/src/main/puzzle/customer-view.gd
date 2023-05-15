extends SubViewportContainer
## Shows the active customer in the restaurant scene.

@export (NodePath) var restaurant_viewport_path: NodePath

func _ready() -> void:
	$SubViewport.world_2d = get_node(restaurant_viewport_path).world_2d if restaurant_viewport_path else null
