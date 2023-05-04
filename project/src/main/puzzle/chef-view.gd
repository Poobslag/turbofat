extends SubViewportContainer
## Shows the player's chef character in the restaurant scene.

@export var restaurant_viewport_path: NodePath

func _ready() -> void:
	$SubViewport.world_2d = get_node(restaurant_viewport_path).world_2d if restaurant_viewport_path else null
	$SubViewport.size = size * 4
