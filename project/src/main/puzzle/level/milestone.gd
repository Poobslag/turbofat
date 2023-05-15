class_name Milestone
## Defines a goal or milestone for a puzzle, such as reaching a certain score, clearing a certain
## number of lines or surviving a certain number of seconds.
##
## Additional details are stored in the 'meta' property.

enum MilestoneType {
	NONE,
	CUSTOMERS,
	LINES,
	PIECES,
	SCORE,
	TIME_OVER,
	TIME_UNDER,
}

const NONE := MilestoneType.NONE
const CUSTOMERS := MilestoneType.CUSTOMERS
const LINES := MilestoneType.LINES
const PIECES := MilestoneType.PIECES
const SCORE := MilestoneType.SCORE
const TIME_OVER := MilestoneType.TIME_OVER
const TIME_UNDER := MilestoneType.TIME_UNDER

## enum from Milestone.MilestoneType describing the milestone criteria (lines, score, time)
var type: int = MilestoneType.NONE

## value describing the milestone criteria (number of lines, points, seconds)
var value := 0

## Initializes the milestone with a MilestoneType and value to reach, such as scoring 50 points or clearing 10 lines.
##
## Parameters:
## 	'new_type': milestone criteria (lines, score, time)
##
## 	'new_value': value describing the milestone criteria (number of lines, points, seconds)
func set_milestone(new_type: int, new_value: int) -> void:
	type = new_type
	value = new_value


func from_json_dict(json: Dictionary) -> void:
	type = Utils.enum_from_snake_case(MilestoneType, json.get("type"))
	value = int(json.get("value", 0))
	for key in json.keys():
		if not key in ["type", "value"]:
			set_meta(key, json.get(key))


func to_json_dict() -> Dictionary:
	var result := {
		"type": Utils.enum_to_snake_case(MilestoneType, type),
		"value": value,
	}
	for meta_key in get_meta_list():
		result[meta_key] = get_meta(meta_key)
	return result


## Returns 'true' if all of the milestone's properties are currently set to their default values.
##
## Milestones whose properties are set to their default values are omitted from our json output.
func is_default() -> bool:
	var result := true
	result = result && (type == MilestoneType.NONE)
	result = result && (value == 0)
	result = result && (get_meta_list().is_empty())
	return result


## Returns the milestone value adjusted by the current gameplay settings.
##
## When the player plays at slow speeds, we make milestones easier to reach.
func adjusted_value() -> int:
	if not CurrentLevel.is_piece_speed_cheat_enabled():
		# Don't adjust milestones for tutorials. Some tutorials require the player to place 3 pieces, shortening it to
		# 2 pieces would ruin the tutorial
		return value
	
	var adjusted_value := value
	match type:
		LINES:
			adjusted_value = GameplayDifficultyAdjustments.adjust_line_milestone(adjusted_value)
		PIECES:
			adjusted_value = GameplayDifficultyAdjustments.adjust_piece_milestone(adjusted_value)
		SCORE:
			adjusted_value = GameplayDifficultyAdjustments.adjust_score_milestone(adjusted_value)
		TIME_OVER:
			adjusted_value = GameplayDifficultyAdjustments.adjust_time_over_milestone(adjusted_value)
	return adjusted_value
