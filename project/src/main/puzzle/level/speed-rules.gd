class_name SpeedRules
"""
Rules for how fast pieces should move.
"""

# Array of Milestone objects representing the requirements to speed up. This mostly applies to 'Marathon Mode' where
# clearing lines makes you speed up.
var speed_ups := []

func _init() -> void:
	# speed_ups always needs one item in it corresponding to the start speed
	add_speed_up(Milestone.LINES, 0, "0")


"""
Adds criteria for speeding up, such as a time, score, or line limit.

Parameters:
	'type': an enum from Milestone.MilestoneType describing the milestone criteria (lines, score, time)
	
	'value': an value describing the milestone criteria (number of lines, points, seconds)
	
	'speed_id': a string from PieceSpeeds defining the new speed
"""
func add_speed_up(type: int, value: int, speed_id: String) -> void:
	var speed_up := Milestone.new()
	speed_up.set_milestone(type, value)
	speed_up.set_meta("speed", speed_id)
	speed_ups.append(speed_up)


func set_start_speed(new_start_speed: String) -> void:
	speed_ups[0].set_meta("speed", new_start_speed)


func start_speed_from_json_string(json: String) -> void:
	set_start_speed(json)


func speed_ups_from_json_array(json: Array) -> void:
	for json_speed_up in json:
		var speed_up := Milestone.new()
		speed_up.from_json_dict(json_speed_up)
		speed_ups.append(speed_up)


func start_speed_is_default() -> bool:
	return speed_ups[0].get_meta("speed") == "0"


func start_speed_to_json_string() -> String:
	return speed_ups[0].get_meta("speed")


func speed_ups_is_default() -> bool:
	return speed_ups.size() <= 1


func speed_ups_to_json_array() -> Array:
	var result := []
	for i in range(1, speed_ups.size()):
		var speed_up: Milestone = speed_ups[i]
		result.append(speed_up.to_json_dict())
	return result
