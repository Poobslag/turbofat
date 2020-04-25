class_name RankResult
"""
Contains rank information for a playthrough. This includes raw statistics such as how many lines-per-minute the player
cleared, as well as derived statistics such as the computed lines-per-minute rank.
"""

# player's speed in lines per minute.
var speed := 0.0
var speed_rank := 0.0

# raw number of cleared lines, not including bonus points
var lines := 0
var lines_rank := 0.0

# bonus points awarded for clearing boxes
var box_score := 0.0
var box_score_per_line := 0.0
var box_score_per_line_rank := 0.0

# bonus points awarded for combos
var combo_score := 0.0
var combo_score_per_line := 0.0
var combo_score_per_line_rank := 0.0

# number of seconds until the player won or lost
var seconds := 0.0
var seconds_rank := 0.0

# overall score
var score := 0
var score_rank := 0.0

# did the player die?
var died := false

"""
Returns this object's data as a dictionary. This is useful when saving/loading data.
"""
func to_dict() -> Dictionary:
	return {
		"speed": speed,
		"speed_rank": speed_rank,
		"lines": lines,
		"lines_rank": lines_rank,
		"box_score": box_score,
		"box_score_per_line": box_score_per_line,
		"box_score_per_line_rank": box_score_per_line_rank,
		"combo_score": combo_score,
		"combo_score_per_line": combo_score_per_line,
		"combo_score_per_line_rank": combo_score_per_line_rank,
		"seconds": seconds,
		"seconds_rank": seconds_rank,
		"score": score,
		"score_rank": score_rank,
		"died": died }


"""
Populates this object from a dictionary. This is useful when saving/loading json data.
"""
func from_dict(json: Dictionary) -> void:
	speed = json["speed"]
	speed_rank = json["speed_rank"]
	lines = int(json["lines"])
	lines_rank = json["lines_rank"]
	box_score = json["box_score"]
	box_score_per_line = json["box_score_per_line"]
	box_score_per_line_rank = json["box_score_per_line_rank"]
	combo_score = json["combo_score"]
	combo_score_per_line = json["combo_score_per_line"]
	combo_score_per_line_rank = json["combo_score_per_line_rank"]
	seconds = json["seconds"]
	seconds_rank = json["seconds_rank"]
	score = int(json["score"])
	score_rank = json["score_rank"]
	died = json["died"]
