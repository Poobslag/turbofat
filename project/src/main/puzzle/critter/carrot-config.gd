class_name CarrotConfig
## Rules for carrots on a specific level.
##
## This includes how many carrots to add, where to add them, and how fast they move.

enum Smoke {
	NONE,
	SMALL,
	MEDIUM,
	LARGE,
}

enum CarrotSize {
	SMALL, # 2x1
	MEDIUM, # 1x4
	LARGE, # 2x3
	XL, # 3x5
}

const DIMENSIONS_BY_CARROT_SIZE := {
	CarrotSize.SMALL: Vector2(2, 1),
	CarrotSize.MEDIUM: Vector2(1, 4),
	CarrotSize.LARGE: Vector2(2, 3),
	CarrotSize.XL: Vector2(3, 5),
}

## Which columns the carrots appear on. For large carrots, this corresponds to the leftmost column of the carrot.
var columns: Array = []

## How many carrots appear during a single 'add carrots' effect
var count := 1

## Duration in seconds that the carrot remains onscreen
var duration: float = 8.0

## Enum from CarrotSize for the carrot's size
var size: int = CarrotSize.MEDIUM

## How much smoke the carrot should emit
var smoke: int = Smoke.SMALL
