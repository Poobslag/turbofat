class_name RankCriteria
## Calculates grades based on time or score thresholds.
##
## Each level defines the rank criteria for the best rank, and can optionally define rank criteria for other ranks.
## The remaining ranks are calculated by interpolation.

## Each level defines the rank criteria for the best rank, but if no rank criteria is specified these values are used
## instead. These values are arbitrary and will not produce meaningful output, so we log a warning if they are used.
const DEFAULT_BEST_SCORE := 2000
const DEFAULT_BEST_TIME := 60

## Grades with their corresponding score percent requirement. Lower values represent lower scores.
const SCORE_PERCENT_BY_GRADE := {
	"M":   0.950,
	"SSS": 0.811,
	"SS+": 0.730,
	"SS":  0.657,
	"S+":  0.388,
	"S":   0.283,
	"S-":  0.206,
	"AA+": 0.1353,
	"AA":  0.1217,
	"A+":  0.1096,
	"A":   0.0986,
	"A-":  0.0888,
	"B+":  0.0582,
	"B":   0.0524,
	"B-":  0.0472,
	Ranks.WORST_GRADE: 0.0,
}

## Grades with their corresponding time percent requirement. Higher values represent slower times.
##
## Note: Most entries are reciprocals of the entries in SCORE_PERCENT_BY_GRADE, except for WORST_GRADE.
const TIME_PERCENT_BY_GRADE := {
	"M":    1.053,
	"SSS":  1.298,
	"SS+":  1.442,
	"SS":   1.602,
	"S+":   2.713,
	"S":    3.722,
	"S-":   5.105,
	"AA+":  7.782,
	"AA":   8.65,
	"A+":   9.61,
	"A":   10.67,
	"A-":  11.86,
	"B+":  18.08,
	"B":   20.09,
	"B-":  22.32,
	Ranks.WORST_GRADE: 50,
}

## key: (String) grade
## value: (int) time or score threshold for the grade
var thresholds_by_grade := {}

## Determines whether rank criteria are based on time (true) or score (false).
var duration_criteria: bool

## Adds a new time or score threshold.
##
## Parameters:
## 	'grade': grade
##
## 	'threshold': Time/score threshold for the grade
func add_threshold(grade: String, threshold: int) -> void:
	thresholds_by_grade[grade] = threshold


## Calculates the corresponding rank for the specified time or score.
##
## Note: Ranks are only calculated based on the currently stored grade threshold boundaries. fill_missing_thresholds()
## should be called first to ensure there is a full set of boundaries with sensible values. Otherwise, if the player
## finishes a level in 30 minutes instead of a goal time of 3 minutes, the algorithm will calculate "Well, 30 minutes
## is half-way between 3 minutes and an hour, so that's an S+ rank"
##
## Parameters:
## 	'value': The time or score value.
##
## Returns:
## 	A rank value in the range (0.0, 999.0). Lower numbers represent a better rank.
func calculate_rank(value: float) -> float:
	# determine the two grade threshold boundaries which surround the specified value
	var lower_grade := ""
	var higher_grade := ""
	for grade_index in range(Ranks.GRADES.size() - 1):
		higher_grade = Ranks.GRADES[grade_index]
		lower_grade = Ranks.GRADES[grade_index + 1]
		if duration_criteria:
			if value < thresholds_by_grade[lower_grade]:
				break
		else:
			if value > thresholds_by_grade[lower_grade]:
				break
	
	# calculate the player's rank based on how close they are to the two boundaries
	var rank_factor: float
	if thresholds_by_grade[lower_grade] == thresholds_by_grade[higher_grade]:
		rank_factor = 0.0
	else:
		rank_factor = inverse_lerp(thresholds_by_grade[lower_grade], thresholds_by_grade[higher_grade], value)
	var rank: float = lerp(Ranks.RANKS_BY_GRADE[lower_grade], Ranks.RANKS_BY_GRADE[higher_grade], rank_factor)
	rank = clamp(rank, Ranks.BEST_RANK, Ranks.WORST_RANK)
	
	return rank


## Fills in any missing thresholds for grades by interpolating values.
##
## Missing thresholds are calculated based on a percentage of neighboring values, and rounded to aesthetically
## pleasing values (e.g. ¥1,350 instead of ¥1,392).
##
## Pre-existing grade threshold boundaries are preserved, so it's possible to have custom boundaries for the "M", "S-"
## and "A-" boundaries, while the remaining boundaries are populated with this algorithm.
func fill_missing_thresholds() -> void:
	# assign boundaries for WORST_GRADE, BEST_GRADE
	var new_thresholds := thresholds_by_grade.duplicate()
	if duration_criteria:
		if not thresholds_by_grade.has(Ranks.BEST_GRADE):
			push_warning("Level %s does not define '%s' rank criteria; defaulting to %s" \
					% [CurrentLevel.level_id if CurrentLevel.level_id else "(unknown)", \
						Ranks.BEST_GRADE, DEFAULT_BEST_SCORE])
			new_thresholds[Ranks.BEST_GRADE] = DEFAULT_BEST_TIME
		if not new_thresholds.has(Ranks.WORST_GRADE):
			new_thresholds[Ranks.WORST_GRADE] = new_thresholds[Ranks.BEST_GRADE] \
					* TIME_PERCENT_BY_GRADE[Ranks.WORST_GRADE]
	else:
		if not thresholds_by_grade.has(Ranks.BEST_GRADE):
			push_warning("Level %s does not define '%s' rank criteria; defaulting to %s" \
					% [CurrentLevel.level_id if CurrentLevel.level_id else "(unknown)", \
						Ranks.BEST_GRADE, DEFAULT_BEST_TIME])
			new_thresholds[Ranks.BEST_GRADE] = DEFAULT_BEST_SCORE
		if not new_thresholds.has(Ranks.WORST_GRADE):
			new_thresholds[Ranks.WORST_GRADE] = new_thresholds[Ranks.BEST_GRADE] \
					* SCORE_PERCENT_BY_GRADE[Ranks.WORST_GRADE]
	
	# fill thresholds for the remaining grades
	var higher_grade_by_grades := _higher_grade_by_grades(new_thresholds)
	var lower_grade_by_grades := _lower_grade_by_grades(new_thresholds)
	for grade in Ranks.GRADES:
		if grade == Ranks.WORST_GRADE:
			continue
		
		if grade in new_thresholds:
			continue
		
		var higher_grade: String = higher_grade_by_grades.get(grade)
		var lower_grade: String = lower_grade_by_grades.get(grade)
		
		# Calculate how much of 'lower_grade' and 'higher_grade' should go into the new threshold.
		var grade_factor: float
		if duration_criteria:
			grade_factor = inverse_lerp(
					TIME_PERCENT_BY_GRADE[lower_grade],
					TIME_PERCENT_BY_GRADE[higher_grade],
					TIME_PERCENT_BY_GRADE[grade])
		else:
			grade_factor = inverse_lerp(
					SCORE_PERCENT_BY_GRADE[lower_grade],
					SCORE_PERCENT_BY_GRADE[higher_grade],
					SCORE_PERCENT_BY_GRADE[grade])
		
		# Calculate the new threshold by combining 'lower_grade' and 'higher_grade'
		new_thresholds[grade] = lerp(
				new_thresholds[lower_grade],
				new_thresholds[higher_grade],
				grade_factor)
	
	# sanitize thresholds by rounding and clamping to reasonable values
	for grade in new_thresholds:
		new_thresholds[grade] = _sanitize_threshold(new_thresholds[grade])
	
	thresholds_by_grade = new_thresholds


func copy_from(rank_criteria: RankCriteria) -> void:
	thresholds_by_grade = rank_criteria.thresholds_by_grade.duplicate()
	duration_criteria = rank_criteria.duration_criteria


## Adjusts a time or score threshold of a specific grade by applying a factor.
##
## Parameters:
## 	'grade': The grade to adjust
##
## 	'factor': A number in the range (0.0, 1.0) for the factor to apply. A value of '0.1' will make a large
## 		adjustment, a value of '0.9' will make a small adjustment.
func soften(grade: String, factor: float) -> void:
	if not thresholds_by_grade.has(Ranks.BEST_GRADE):
		push_error("Level %s does not define '%s' rank criteria" % [CurrentLevel.level_id, Ranks.BEST_GRADE])
		return
	
	var new_threshold: int = thresholds_by_grade[Ranks.BEST_GRADE]
	if duration_criteria:
		new_threshold = new_threshold * TIME_PERCENT_BY_GRADE[grade] / factor
	else:
		new_threshold = new_threshold * SCORE_PERCENT_BY_GRADE[grade] * factor
	new_threshold = _sanitize_threshold(new_threshold)
	
	thresholds_by_grade[grade] = new_threshold


## Sanitize a time or score threshold by rounding and clamping to reasonable values.
func _sanitize_threshold(value: int) -> int:
	var result := value
	
	# round thresholds to aesthetically pleasing numbers
	if duration_criteria:
		result = Ranks.round_time_up(int(ceil(result)))
	else:
		result = Ranks.round_score_down(int(floor(result)))
	
	# limit thresholds to reasonable boundaries
	if duration_criteria:
		result = int(clamp(result, 1, 3599))
	else:
		result = int(clamp(result, 1, 999999))
	
	return result


## Calculates the higher grade threshold for every possible grade.
##
## When filling in missing thresholds, we need to know the existing thresholds to interpolate between. This method
## calculates one of those two thresholds.
##
## Parameters:
## 	'new_thresholds': A mapping from grades to time or score thresholds.
##
## Returns:
## 	A mapping from grades to a higher grade threshold in the specified threshold mapping.
static func _higher_grade_by_grades(new_thresholds: Dictionary) -> Dictionary:
	var result := {}
	
	var higher_grade := Ranks.BEST_GRADE
	var grades := SCORE_PERCENT_BY_GRADE.keys()
	for grade in grades:
		if new_thresholds.has(grade):
			higher_grade = grade
		if higher_grade:
			result[grade] = higher_grade
	
	return result


## Calculates the lower grade threshold for every possible grade.
##
## When filling in missing thresholds, we need to know the existing thresholds to interpolate between. This method
## calculates one of those two thresholds.
##
## Parameters:
## 	'new_thresholds': A mapping from grades to time or score thresholds.
##
## Returns:
## 	A mapping from grades to a lower grade threshold in the specified threshold mapping.
static func _lower_grade_by_grades(new_thresholds: Dictionary) -> Dictionary:
	var result := {}
	
	var lower_grade := Ranks.WORST_GRADE
	var grades := SCORE_PERCENT_BY_GRADE.keys()
	grades.invert()
	for grade in grades:
		if new_thresholds.has(grade):
			lower_grade = grade
		if lower_grade:
			result[grade] = lower_grade
	
	return result
