extends CollisionShape2D
"""
Collision shape for creatures on the overworld.
"""

# emitted when the collision shape's extents change
signal extents_changed(value)

export (NodePath) var creature_visuals_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_node(creature_visuals_path)

func _ready() -> void:
	_creature_visuals.connect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")
	_refresh()


"""
Increases the collision shape size for fatter creatures.
"""
func _refresh() -> void:
	var rectangle_shape: RectangleShape2D = shape
	
	# increase collision shape size for fatter creatures
	rectangle_shape.extents = Vector2(16, 8) * _creature_visuals.visual_fatness * _creature_visuals.scale.y
	
	# small creatures still occupy a minimal amount of space
	rectangle_shape.extents.x = max(rectangle_shape.extents.x, 28)
	rectangle_shape.extents.y = max(rectangle_shape.extents.y, 14)
	emit_signal("extents_changed", rectangle_shape.extents)


func _on_CreatureVisuals_visual_fatness_changed() -> void:
	_refresh()
