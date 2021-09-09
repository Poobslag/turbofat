class_name Creatures
"""
Enums, constants and utilities related to creatures.
"""

enum Orientation {
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
	NORTHEAST,
}

enum MovementMode {
	IDLE, # not walking/running
	SPRINT, # quadrapedal run
	RUN, # bipedal run
	WALK, # bipedal walk
	WIGGLE, # flailing their arms and legs helplessly
}

const SOUTHEAST = Orientation.SOUTHEAST
const SOUTHWEST = Orientation.SOUTHWEST
const NORTHWEST = Orientation.NORTHWEST
const NORTHEAST = Orientation.NORTHEAST

const IDLE := MovementMode.IDLE
const SPRINT := MovementMode.SPRINT
const RUN := MovementMode.RUN
const WALK := MovementMode.WALK
const WIGGLE := MovementMode.WIGGLE

# How large creatures can grow; 5.0 = 5x normal size
const MAX_FATNESS := 10.0

# the creature definition path for the sensei who leads tutorials
const SENSEI_PATH := "res://assets/main/creatures/sensei/creature.json"

"""
Returns true if the specified creature orientation points south (towards the camera)

Parameters:
	'orientation': an enum from Creatures.Orientation
"""
static func oriented_south(orientation: int) -> bool:
	return orientation in [SOUTHWEST, SOUTHEAST]


"""
Returns true if the specified creature orientation points north (away from the camera)

Parameters:
	'orientation': an enum from Creatures.Orientation
"""
static func oriented_north(orientation: int) -> bool:
	return orientation in [NORTHWEST, NORTHEAST]
