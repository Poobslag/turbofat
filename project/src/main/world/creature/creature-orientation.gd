class_name CreatureOrientation
"""
Enums and utilities related to the four directions creatures can face.
"""

enum Orientation {
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
	NORTHEAST,
}

const SOUTHEAST := Orientation.SOUTHEAST
const SOUTHWEST := Orientation.SOUTHWEST
const NORTHWEST := Orientation.NORTHWEST
const NORTHEAST := Orientation.NORTHEAST

static func oriented_south(orientation: int) -> bool:
	return orientation in [SOUTHWEST, SOUTHEAST]


static func oriented_north(orientation: int) -> bool:
	return orientation in [NORTHWEST, NORTHEAST]
