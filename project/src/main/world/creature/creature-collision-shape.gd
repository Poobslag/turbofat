extends CollisionShape2D
"""
Collision shape for creatures on the overworld.
"""

# emitted when the collision shape's extents change
signal extents_changed(value)

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

var _creature_visuals: CreatureVisuals

func _ready() -> void:
	_refresh_creature_visuals_path()
	_refresh()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	if _creature_visuals:
		_creature_visuals.disconnect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")
	_creature_visuals = get_node(creature_visuals_path)
	_creature_visuals.connect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")


"""
Increases the collision shape size for fatter creatures.
"""
func _refresh() -> void:
	if not _creature_visuals:
		return
	
	var rectangle_shape: RectangleShape2D = shape
	
	# increase collision shape size for fatter creatures
	rectangle_shape.extents = Vector2(16, 8) * _creature_visuals.visual_fatness * _creature_visuals.scale.y
	
	# small creatures still occupy a minimal amount of space
	rectangle_shape.extents.x = max(rectangle_shape.extents.x, 28)
	rectangle_shape.extents.y = max(rectangle_shape.extents.y, 14)
	emit_signal("extents_changed", rectangle_shape.extents)


func _on_CreatureVisuals_visual_fatness_changed() -> void:
	_refresh()
