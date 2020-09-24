class_name Milestone
"""
Defines a goal or milestone for a puzzle, such as reaching a certain score, clearing a certain
number of lines or surviving a certain number of seconds.

Additional details are stored in the 'meta' property.
"""

enum MilestoneType {
	NONE,
	CUSTOMERS,
	LINES,
	SCORE,
	TIME_OVER,
	TIME_UNDER,
}

const NONE := MilestoneType.NONE
const CUSTOMERS := MilestoneType.CUSTOMERS
const LINES := MilestoneType.LINES
const SCORE := MilestoneType.SCORE
const TIME_OVER := MilestoneType.TIME_OVER
const TIME_UNDER := MilestoneType.TIME_UNDER

# converts json strings into milestone types
const JSON_MILESTONE_TYPES := {
	"none": MilestoneType.NONE,
	"customers": MilestoneType.CUSTOMERS,
	"lines": MilestoneType.LINES,
	"score": MilestoneType.SCORE,
	"time_over": MilestoneType.TIME_OVER,
	"time_under": MilestoneType.TIME_UNDER,
}

# These two parameters describe a MilestoneType and value to reach, such as scoring 50 points, clearing 10 lines
# or surviving for 30 seconds.
var type: int
var value: int

func set_milestone(new_type: int, new_value: int) -> void:
	type = new_type
	value = new_value


func from_json_dict(json: Dictionary) -> void:
	type = JSON_MILESTONE_TYPES.get(json.get("type"), MilestoneType.NONE)
	value = int(json.get("value", "0"))
	for key in json.keys():
		if not key in ["type", "value"]:
			set_meta(key, json.get(key))
