class_name Ranks
## Enums, constants and utilities for the rank/grade system

## Grades ordered from best to worst
const BEST_GRADE := "M"
const WORST_GRADE := "-"
const GRADES := ["M", "SSS", "SS+", "SS", "S+", "S", "S-", "AA+", "AA", "A+", "A", "A-", "B+", "B", "B-", "-"]

const BEST_RANK := 0.0
const BAD_RANK := 72.0
const WORST_RANK := 999.0

## Number of extra unnecessary frames a perfect player will spend moving their piece.
const MASTER_MVMT_FRAMES := 6

## Rank requirements for each grade
const RANKS_BY_GRADE := {
	"M": 0.0,
	"SSS": 4.0,
	"SS+": 7.0,
	"SS": 10.0,
	
	"S+": 16.0,
	"S": 20.0,
	"S-": 24.0,
	
	"AA+": 32.0,
	"AA": 36.0,
	"A+": 40.0,
	"A": 44.0,
	"A-": 48.0,
	
	"B+": 56.0,
	"B": 60.0,
	"B-": 64.0,
	
	WORST_GRADE: WORST_RANK,
}

## Rounds a score down to an aesthetically pleasing value, such as ¥1,350 instead of ¥1,392.
static func round_score_down(value: int) -> int:
	if value <= 0:
		return value
	
	var magnitude: int
	if value >= 20 and value <= 100:
		# numbers 21-99 are rounded down to the nearest 5
		magnitude = 5
	else:
		# numbers over 100 are rounded down to the nearest two significant digits, plus a 5
		# warning-ignore:integer_division
		magnitude = int(pow(10, int(log(value) / log(10) - 1))) / 2
		magnitude = int(max(1, magnitude))
	
	return int(floor(value / float(magnitude)) * magnitude)


## Rounds a time up to an aesthetically pleasing value, such as 1:30 instead of 1:26.
static func round_time_up(value: int) -> int:
	if value <= 0:
		return value
	
	var magnitude: int
	if value <= 60:
		magnitude = 1
	elif value <= 600:
		magnitude = 5
	elif value <= 6000:
		magnitude = 10
	else:
		magnitude = 60
	
	return int(ceil(value / float(magnitude)) * magnitude)


## Converts a numeric rank such as '12.6' into a grade string such as 'S+'.
static func grade(rank: float) -> String:
	var result := WORST_GRADE
	
	for grade in RANKS_BY_GRADE:
		if rank <= RANKS_BY_GRADE[grade]:
			result = grade
			break
	
	return result


## Calculates the next grade better than the specified grade.
##
## next_grade("A-")  = "A"
## next_grade("SSS") = "M"
## next_grade("M")   = "M"
## next_grade("-")   = "B-"
static func next_grade(grade: String) -> String:
	var grade_index := GRADES.find(grade)
	return WORST_GRADE if grade_index == -1 else GRADES[max(0, grade_index - 1)]


## Calculates the minimum theoretical frames per line for a given piece speed.
##
## This assumes a perfect player who is making many boxes, clearing lines one at a time, and moving pieces with TAS
## level efficiency.
static func min_frames_per_line(piece_speed: PieceSpeed) -> float:
	var movement_frames := 1 + MASTER_MVMT_FRAMES
	var frames_per_line := 0.0
	
	# eight pieces form three boxes and clear four lines

	# time spent spawning eight pieces
	frames_per_line += piece_speed.line_appearance_delay * 4 # four 'line clear' pieces spawned
	frames_per_line += piece_speed.appearance_delay * 4 # four 'regular pieces' spawned
	
	# time spent moving nine pieces
	frames_per_line += movement_frames * 8
	
	# time spent while pieces lock into the playfield
	frames_per_line += piece_speed.post_lock_delay * 8 # eight pieces locked
	frames_per_line += piece_speed.line_clear_delay * 4 # four lines cleared
	frames_per_line += piece_speed.box_delay * 3 # three boxes formed
	frames_per_line /= 4
	return frames_per_line
