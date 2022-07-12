class_name OtherRegion
## Stores information about a group of levels not used in career mode. This includes tutorials and training levels.

## Unique region IDs for regions with special properties
const ID_RANK := "rank"
const ID_SANDBOX := "practice/sandbox"
const ID_MARATHON := "practice/marathon"

## A flag for regions where Fat Sensei is not following the player
const FLAG_TUTORIAL := "tutorial"

## A flag for practice mode's training regions
const FLAG_TRAINING := "training"

## The region id used for identifying unique regions in source code
var id: String

## A human-readable name to show when this group is in a menu, such as 'Training: Marathon'
var name: String

## A human readable name to show when this group is in a part of a level's name, such as 'Marathon'
var branch_name: String

## A human-readable tagline describing this career region.
var description: String

## Returns 'true' if this region has the specified flag.
##
## Regions can have flags for unusual qualities, such as tutorial regions
var flags: Dictionary = {}

var level_ids := []

## A human-readable environment name, such as 'lemon' or 'marsh' for the puzzle environment
var puzzle_environment_name: String

## A human-readable name, such as 'lemon' or 'marsh' for the button on the region select screen
var region_button_name: String

func from_json_dict(json: Dictionary) -> void:
	id = json.get("id", "")
	name = json.get("name", "")
	branch_name = json.get("branch_name", name)
	description = json.get("description", "")
	for flags_string in json.get("flags", []):
		flags[flags_string] = true
	level_ids = json.get("level_ids", "")
	puzzle_environment_name = json.get("puzzle_environment", "")
	region_button_name = json.get("region_button", "")


## Returns 'true' if this region has the specified flag.
##
## Regions can have flags for unusual qualities, such as regions where Fat Sensei is not following the player, or
## where the player does not operate a restaurant.
func has_flag(key: String) -> bool:
	return flags.has(key)
