class_name Creatures
## Enums, constants and utilities related to creatures.

## Directions a creature can face
enum Orientation {
	SOUTHEAST,
	SOUTHWEST,
	NORTHWEST,
	NORTHEAST,
}

## Ways a creature can move
enum MovementMode {
	IDLE, # not walking/running
	SPRINT, # quadrapedal run
	RUN, # bipedal run
	WALK, # bipedal walk
	WIGGLE, # flailing their arms and legs helplessly
}

## Moods a creature can express
enum Mood {
	NONE,
	DEFAULT, # neutral expression, neither positive nor negative
	AWKWARD0, # apprehensive
	AWKWARD1, # visibly uncomfortable
	CRY0, # a little sad
	CRY1, # crying their eyes out
	LAUGH0, # laughing a little
	LAUGH1, # laughing a lot
	LOVE0, # finding something cute
	LOVE1, # fawning over something
	LOVE1_FOREVER, # fawning over something forever
	NO0, # shaking their head once
	NO1, # shaking their head a few times
	RAGE0, # annoyed
	RAGE1, # a little upset
	RAGE2, # infuriated
	SIGH0, # unamused
	SIGH1, # exasperated
	SLY0, # slight smirk
	SLY1, # hatching a scheme
	SMILE0, # smiling a little
	SMILE1, # smiling a lot
	SWEAT0, # a little nervous
	SWEAT1, # incredibly anxious
	THINK0, # pensive
	THINK1, # confused
	WAVE0, # emotionless greeting (or pointing)
	WAVE1, # friendly greeting
	WAVE2, # enthusiastic greeting
	YES0, # nodding once
	YES1, # nodding a few times
}

## Different types of creature with their own names and appearances
enum Type {
	DEFAULT,
	SQUIRREL,
}

const CREATURE_DATA_VERSION := "5923"

const SOUTHEAST := Orientation.SOUTHEAST
const SOUTHWEST := Orientation.SOUTHWEST
const NORTHWEST := Orientation.NORTHWEST
const NORTHEAST := Orientation.NORTHEAST

const IDLE := MovementMode.IDLE
const SPRINT := MovementMode.SPRINT
const RUN := MovementMode.RUN
const WALK := MovementMode.WALK
const WIGGLE := MovementMode.WIGGLE

## How large creatures can grow; 5.0 = 5x normal size
const MAX_FATNESS := 10.0

## creature definition path for the sensei who leads tutorials
const SENSEI_PATH := "res://assets/main/creatures/sensei.json"

## Returns true if the specified creature orientation points south (towards the camera)
##
## Parameters:
## 	'orientation': enum from Creatures.Orientation
static func oriented_south(orientation: int) -> bool:
	return orientation in [SOUTHWEST, SOUTHEAST]


## Returns true if the specified creature orientation points north (away from the camera)
##
## Parameters:
## 	'orientation': enum from Creatures.Orientation
static func oriented_north(orientation: int) -> bool:
	return orientation in [NORTHWEST, NORTHEAST]
