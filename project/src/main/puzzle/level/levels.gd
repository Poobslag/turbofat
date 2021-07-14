class_name Levels
"""
This script consists exclusively of constants and enums related to levels.

This prevents cyclic dependency errors which arise if these constants and enums are pushed down to individual scripts.
"""

enum CutsceneForce {
	NONE, # do not force the cutscene to play or skip
	PLAY, # force the cutscene to play, even if it is a repeat
	SKIP, # force the cutscene to skip, even if it has never been seen
}

# Tracks whether the player has lost, finished, or met a success condition. These enums should be ordered from worst to
# best so that we can calculate the player's best result by comparing enums numerically.
enum Result {
	NONE, # The player didn't place any pieces.
	LOST, # The player gave up or failed.
	FINISHED, # The player survived until the end.
	WON, # The player was successful.
}
