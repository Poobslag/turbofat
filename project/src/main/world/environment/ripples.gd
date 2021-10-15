class_name Ripples
"""
Enums, constants and utilities for overworld goop ripples.
"""

# directions waves can travel
enum RippleDirection {
	NORTHEAST,
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
}

# states controlling a ripple's appearance
enum RippleState {
	OFF,
	CONNECTED_NONE,
	CONNECTED_LEFT,
	CONNECTED_RIGHT,
	CONNECTED_BOTH,
}

# key: enum from RippleDirection
# value: unit vector for use in tilemaps; northeast points up
const TILEMAP_VECTOR_BY_RIPPLE_DIRECTION := {
	RippleDirection.NORTHEAST: Vector2.UP,
	RippleDirection.SOUTHEAST: Vector2.RIGHT,
	RippleDirection.SOUTHWEST: Vector2.DOWN,
	RippleDirection.NORTHWEST: Vector2.LEFT,
}

# key: enum from RippleDirection
# value: unit vector where abs(x) = abs(2y); northeast points right and slightly up
const ISO_VECTOR_BY_RIPPLE_DIRECTION := {
	RippleDirection.NORTHEAST: Vector2(0.89443, -0.44721),
	RippleDirection.SOUTHEAST: Vector2(0.89443, 0.44721),
	RippleDirection.SOUTHWEST: Vector2(-0.89443, 0.44721),
	RippleDirection.NORTHWEST: Vector2(-0.89443, -0.44721),
}
