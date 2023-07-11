class_name RegionCompletion
## Data about which parts of a region are complete/incomplete.

## how many interlude cutscenes the player's viewed in a region
var cutscene_completion: int = 0

## how many interlude cutscenes the player can potentially view in a region
var potential_cutscene_completion: int = 0

## how many levels the player has finished in a region
var level_completion: int = 0

## how many levels the player can potentially finish in a region
var potential_level_completion: int = 0

## Returns a number in the range [0.0, 1.0] for how close the player is to completing the region.
##
## This includes how many levels they've cleared and how many interlude cutscenes they've viewed.
func completion_percent() -> float:
	# We combine the raw cutscene count and level count. This means for regions with many cutscenes and few
	# levels, a player might clear every level and only have 20% completion.
	var completion := cutscene_completion + level_completion
	var potential_completion := potential_cutscene_completion + potential_level_completion
	
	if potential_completion == 0.0:
		# avoid divide-by-zero for regions with no levels and no cutscenes
		return 1.0
	else:
		return completion / float(potential_completion)


## Returns a number in the range [0.0, 1.0] for how close the player is to viewing all of a region's interlude
## cutscenes.
func cutscene_completion_percent() -> float:
	if potential_cutscene_completion == 0.0:
		# avoid divide-by-zero for regions with no cutscenes
		return 1.0
	else:
		return cutscene_completion / float(potential_cutscene_completion)


## Returns a number in the range [0.0, 1.0] for how close the player is to playing all of a region's levels.
func level_completion_percent() -> float:
	if potential_level_completion == 0.0:
		# avoid divide-by-zero for regions with no levels
		return 1.0
	else:
		return level_completion / float(potential_level_completion)
