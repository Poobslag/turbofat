class_name Levels
## This script consists exclusively of constants and enums related to levels.
##
## This prevents cyclic dependency errors which arise if these constants and enums are pushed down to individual
## scripts.

## Monitors whether the player has lost, finished, or met a success condition. These enums should be ordered from worst
## to best so that we can calculate the player's best result by comparing enums numerically.
enum Result {
	NONE, # The player didn't place any pieces.
	LOST, # The player gave up or failed.
	FINISHED, # The player survived until the end.
	WON, # The player was successful.
}

## Current version for saved level data. Should be updated if and only if the level format changes.
## This version number follows a 'ymdh' hex date format which is documented in issue #234.
const LEVEL_DATA_VERSION := "5c84"
