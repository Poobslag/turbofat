extends MeshInstance
"""
A mesh which casts an appropriate shadow based on the creature's position and status.
"""

const DEFAULT_SHADOW_SCALE := Vector3(0.65, 0.85, 0.5)

# a scalar which makes the creature's shadow bigger/smaller
export (float) var _shadow_scale := 1.0 setget set_shadow_scale

"""
Sets a scalar which makes the creature's shadow bigger/smaller.
"""
func set_shadow_scale(var shadow_scale: float) -> void:
	_shadow_scale = shadow_scale
	scale = DEFAULT_SHADOW_SCALE * _shadow_scale
