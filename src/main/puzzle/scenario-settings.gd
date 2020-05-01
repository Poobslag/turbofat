class_name ScenarioSettings
"""
Contains settings for a 'scenario', such as trying to survive until level 100, or getting the highest score you can
get in 90 seconds.
"""

class LevelUp:
	"""
	Defines the criteria for leveling up, such as a time, score, or line limit.
	"""
	
	# These two parameters describe a MilestoneType and value to reach, such as scoring 50 points, clearing 10 lines
	# or surviving for 30 seconds.
	var type: int
	var value: int
	
	# The new level upon reaching the target milestone.
	var level: String
	
	func from_dict(json: Dictionary) -> void:
		type = JSON_MILESTONE_TYPES[json["type"]]
		value = int(json["value"])
		level = json["level"]


class WinCondition:
	"""
	Defines the criteria for finishing the scenario, such as a time, score, or line goal.
	"""
	
	# These two parameters describe a MilestoneType and value to reach, such as scoring 200 points, clearing 100 lines
	# or surviving for 120 seconds.
	var type: int
	var value: int
	
	"""
	When calculating the player's rank, we first compare them to an 'M' rank player, and then to an 'S++' rank player
	who only needs to reach this lenient_value target. This prevents the case where everyone gets a D- on a marathon
	scenario because they didn't survive 1,000 lines, when the marathon scenario is intended as a 'for fun' mode where
	getting 1,000 lines is not really the true goal.
	"""
	var lenient_value: int
	
	"""
	Populates this object from a dictionary. Used for loading json data.
	"""
	func from_dict(json: Dictionary) -> void:
		type = JSON_MILESTONE_TYPES[json["type"]]
		value = int(json["value"])
		lenient_value = int(json.get("lenient-value", -1))

# Defines a type of goal or milestone type within a scenario, such as reaching a certain score, clearing a certain
# number of lines or surviving a certain number of seconds
enum MilestoneType {
	NONE,
	LINES,
	SCORE,
	TIME
}

const NONE := MilestoneType.NONE
const LINES := MilestoneType.LINES
const SCORE := MilestoneType.SCORE
const TIME := MilestoneType.TIME

# converts json strings into milestone types
const JSON_MILESTONE_TYPES := {
	"none": MilestoneType.NONE,
	"lines": MilestoneType.LINES,
	"score": MilestoneType.SCORE,
	"time": MilestoneType.TIME
}

# The requirements to level up and make the game harder. This mostly applies to 'Marathon Mode' where clearing lines
# makes you level up.
var level_ups := []

# The requirements to finish the scenario. This can be a line, score, or time requirement.
var win_condition: WinCondition

# The scenario name, used internally for saving/loading data.
var name := ""

func set_start_level(level: String) -> void:
	level_ups.clear()
	add_level_up(MilestoneType.LINES, 0, level)


"""
Adds criteria for leveling up, such as a time, score, or line limit.
"""
func add_level_up(type: int, value: int, level: String) -> void:
	var win_condition := WinCondition.new()
	var level_up := LevelUp.new()
	level_up.type = type
	level_up.value = value
	level_up.level = level
	print("116: %s %s" % [level_up.level, typeof(level_up.level)])
	level_ups.append(level_up)


"""
Sets the criteria for finishing the scenario, such as a time, score, or line goal.
"""
func set_win_condition(type: int, value: int, lenient_value: int = -1) -> void:
	win_condition = WinCondition.new()
	win_condition.type = type
	win_condition.value = value
	win_condition.lenient_value = lenient_value


"""
Populates this object from a dictionary. Used for loading json data.

Parameters:
	'new_name': The scenario name used for saving statistics.
"""
func from_dict(new_name: String, json: Dictionary) -> void:
	name = new_name
	
	# set starting level
	set_start_level(json["start-level"])
	
	# add level ups
	if json.has("level-ups"):
		for json_level_up in json["level-ups"]:
			var level_up := LevelUp.new()
			level_up.from_dict(json_level_up)
			level_ups.append(level_up)

	win_condition = WinCondition.new()
	win_condition.from_dict(json["win-condition"])
