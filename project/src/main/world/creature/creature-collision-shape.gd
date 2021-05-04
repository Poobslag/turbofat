extends CollisionShape2D
"""
Collision shape for creatures on the overworld.
"""

# emitted when the collision shape's extents change
signal extents_changed(value)

var creature_visuals: CreatureVisuals setget set_creature_visuals

func _ready() -> void:
	_connect_creature_visuals_listeners()
	_refresh_extents()


func set_creature_visuals(new_creature_visuals: CreatureVisuals) -> void:
	if creature_visuals:
		creature_visuals.disconnect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")
	creature_visuals = new_creature_visuals
	_connect_creature_visuals_listeners()


func _connect_creature_visuals_listeners() -> void:
	if not creature_visuals:
		return
	
	creature_visuals.connect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")


"""
Increases the collision shape size for fatter creatures.
"""
func _refresh_extents() -> void:
	if not creature_visuals:
		return
	
	var rectangle_shape: RectangleShape2D = shape
	
	# increase collision shape size for fatter creatures
	rectangle_shape.extents = Vector2(16, 8) * creature_visuals.visual_fatness * creature_visuals.scale.y
	
	# small creatures still occupy a minimal amount of space
	rectangle_shape.extents.x = max(rectangle_shape.extents.x, 28)
	rectangle_shape.extents.y = max(rectangle_shape.extents.y, 14)
	emit_signal("extents_changed", rectangle_shape.extents)


func _on_CreatureVisuals_visual_fatness_changed() -> void:
	_refresh_extents()
