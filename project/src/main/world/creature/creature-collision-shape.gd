extends CollisionShape2D
"""
Collision shape for creatures on the overworld.
"""

var creature_visuals: CreatureVisuals

"""
Increases the collision shape size for fatter creatures.
"""
func refresh_extents() -> void:
	if not creature_visuals:
		return
	
	var rectangle_shape: RectangleShape2D = shape
	
	# increase collision shape size for fatter creatures
	rectangle_shape.extents = Vector2(16, 8) * creature_visuals.visual_fatness * creature_visuals.scale.y
	
	# small creatures still occupy a minimal amount of space
	rectangle_shape.extents.x = max(rectangle_shape.extents.x, 28)
	rectangle_shape.extents.y = max(rectangle_shape.extents.y, 14)
