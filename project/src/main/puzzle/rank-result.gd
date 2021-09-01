class_name RankResult
"""
Contains rank information for a playthrough. This includes raw statistics such as how many lines-per-minute the player
cleared, as well as derived statistics such as the computed lines-per-minute rank.
"""

const BEST_RANK := 0.0
const WORST_RANK := 999.0

var timestamp := OS.get_datetime()

# how this rank result should be compared:
# '-seconds': lowest seconds is best
# '+score': highest score is best (default)
var compare := "+score"

# player's speed in lines per minute.
var speed := 0.0
var speed_rank := WORST_RANK

# raw number of cleared lines, not including bonus points
var lines := 0
var lines_rank := WORST_RANK

# number of pieces placed
var pieces := 0
var pieces_rank := WORST_RANK

# points awarded for lines left over at the end
var leftover_score := 0

# bonus points awarded for clearing boxes
var box_score := 0
var box_score_per_line := 0.0
var box_score_per_line_rank := WORST_RANK

# bonus points awarded for combos
var combo_score := 0
var combo_score_per_line := 0.0
var combo_score_per_line_rank := WORST_RANK

# number of seconds until the player won or lost
var seconds := 0.0
var seconds_rank := WORST_RANK

# overall score
var score := 0
var score_rank := WORST_RANK

# how many times did the player top out?
var top_out_count := 0

# did the player lose?
var lost := false

# did the player succeed?
var success := false

func to_json_dict() -> Dictionary:
	return {
		"box_score": box_score,
		"box_score_per_line": box_score_per_line,
		"box_score_per_line_rank": box_score_per_line_rank,
		"combo_score": combo_score,
		"combo_score_per_line": combo_score_per_line,
		"combo_score_per_line_rank": combo_score_per_line_rank,
		"compare": compare,
		"leftover_score": leftover_score,
		"lines": lines,
		"lines_rank": lines_rank,
		"pieces": pieces,
		"pieces_rank": pieces_rank,
		"lost": lost,
		"score": score,
		"score_rank": score_rank,
		"seconds": seconds,
		"seconds_rank": seconds_rank,
		"speed": speed,
		"speed_rank": speed_rank,
		"success": success,
		"timestamp": timestamp,
		"top_out_count": top_out_count,
	}


func from_json_dict(json: Dictionary) -> void:
	box_score = int(json.get("box_score", "0"))
	box_score_per_line = float(json.get("box_score_per_line", "0"))
	box_score_per_line_rank = float(json.get("box_score_per_line_rank", "999"))
	combo_score = int(json.get("combo_score", "0"))
	combo_score_per_line = float(json.get("combo_score_per_line", "0"))
	combo_score_per_line_rank = float(json.get("combo_score_per_line_rank", "999"))
	compare = json.get("compare", "+score")
	leftover_score = json.get("leftover_score", 0)
	lines = int(json.get("lines", "0"))
	lines_rank = float(json.get("lines_rank", "999"))
	pieces = int(json.get("pieces", "0"))
	pieces_rank = float(json.get("pieces_rank", "999"))
	lost = bool(json.get("lost", true))
	score = int(json.get("score", "0"))
	score_rank = float(json.get("score_rank", "999"))
	seconds = float(json.get("seconds", "999999"))
	seconds_rank = float(json.get("seconds_rank", "999"))
	speed = float(json.get("speed", "0"))
	speed_rank = float(json.get("speed_rank", "999"))
	success = bool(json.get("success", false))
	timestamp = json.get("timestamp",
			{"year": 2020, "month": 5, "day": 9, "weekday": 4, "dst": false, "hour": 17, "minute": 43, "second": 51})
	top_out_count = int(json.get("top_out_count", "999999"))


func topped_out() -> bool:
	return top_out_count > 0
