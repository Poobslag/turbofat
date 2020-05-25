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
	TIME
}

const NONE := MilestoneType.NONE
const CUSTOMERS := MilestoneType.CUSTOMERS
const LINES := MilestoneType.LINES
const SCORE := MilestoneType.SCORE
const TIME := MilestoneType.TIME

# converts json strings into milestone types
const JSON_MILESTONE_TYPES := {
	"none": MilestoneType.NONE,
	"customers": MilestoneType.CUSTOMERS,
	"lines": MilestoneType.LINES,
	"score": MilestoneType.SCORE,
	"time": MilestoneType.TIME
}

# These two parameters describe a MilestoneType and value to reach, such as scoring 50 points, clearing 10 lines
# or surviving for 30 seconds.
var type: int
var value: int

func from_json_dict(json: Dictionary) -> void:
	type = JSON_MILESTONE_TYPES.get(json.get("type"), MilestoneType.NONE)
	value = int(json.get("value", "0"))
	for key in json.keys():
		if not key in ["type", "value"]:
			set_meta(key, json.get(key))
