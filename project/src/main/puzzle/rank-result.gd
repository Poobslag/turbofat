class_name RankResult
## Contains rank information for a playthrough. This includes raw statistics such as how many lines-per-minute the
## player cleared, as well as derived statistics such as the computed lines-per-minute rank.

var timestamp := OS.get_datetime()

## how this rank result should be compared:
## '-seconds': lowest seconds is best
## '+score': highest score is best (default)
var compare := "+score"

## points awarded for lines left over at the end
var leftover_score := 0

## bonus points awarded for clearing boxes
var box_score := 0

## bonus points awarded for combos
var combo_score := 0

## bonus points awarded for pickups
var pickup_score := 0

## raw number of cleared lines, not including bonus points
var lines := 0

var rank := Ranks.WORST_RANK

## number of seconds until the player won or lost
var seconds := 0.0

## overall score
var score := 0

## true if the player lost the level by quitting or losing all their lives
var lost := false

## true if the player met the level's success criteria. Not all levels have success criteria, but some levels expect
## the player to reach a target score or finish within a time limit.
var success := false

func to_json_dict() -> Dictionary:
	return {
		"box_score": box_score,
		"combo_score": combo_score,
		"pickup_score": pickup_score,
		"compare": compare,
		"leftover_score": leftover_score,
		"lines": lines,
		"lost": lost,
		"score": score,
		"seconds": seconds,
		"success": success,
		"timestamp": timestamp,
	}


func from_json_dict(json: Dictionary) -> void:
	box_score = int(json.get("box_score", 0))
	combo_score = int(json.get("combo_score", 0))
	pickup_score = int(json.get("pickup_score", 0))
	compare = json.get("compare", "+score")
	leftover_score = int(json.get("leftover_score", 0))
	lines = int(json.get("lines", 0))
	lost = bool(json.get("lost", true))
	score = int(json.get("score", 0))
	seconds = float(json.get("seconds", 999999.0))
	success = bool(json.get("success", false))
	timestamp = json.get("timestamp",
			{"year": 2020, "month": 5, "day": 9, "weekday": 4, "dst": false, "hour": 17, "minute": 43, "second": 51})
