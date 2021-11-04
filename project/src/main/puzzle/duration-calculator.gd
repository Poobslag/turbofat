class_name DurationCalculator
"""
Estimates the duration of a puzzle.

This is shown to the user on the level select screen, and also affects the relative sizes of the level buttons.
"""

# While rank 48 only requires a player to clear 3-4 lines per minute, it's unreasonable to predict that a level that
# requiring 12 line clears will take 3-4 minutes. This constant stores the expected lines per minute for a novice
# player.
const MIN_LINES_PER_MINUTE := 8.0

# Estimated rank for each difficulty based on the various rank levels
const RANKS_BY_DIFFICULTY := {
	# beginner; 10-30 blocks per minute
	"T": 48.0,
	"0": 48.0, "1": 44.0, "2": 40.0, "3": 36.0, "4": 32.0,
	"5": 30.0, "6": 28.0, "7": 27.0, "8": 26.0, "9": 25.0,
	
	# normal; 30-60 blocks per minute
	"A0": 24.0, "A1": 22.0, "A2": 20.0, "A3": 19.0, "A4": 18.0,
	"A5": 17.0, "A6": 16.0, "A7": 15.0, "A8": 14.0, "A9": 13.0,
	
	# hard; 60-120 blocks per minute
	"AA": 12.0, "AB": 11.0, "AC": 10.0, "AD": 9.0, "AE": 8.0, "AF": 7.0,
	
	# crazy; 120-250 blocks per minute
	"F0": 6.0, "F1": 5.0, "FA": 4.5, "FB": 4.0, "FC": 3.5,
	"FD": 3.0, "FE": 2.5, "FF": 2.0, "FFF": 1.5,
}

"""
Returns the estimated duration for the specified level.

We calculate an approprate rank based on the level difficulty, and then estimate how long a player of that rank
would take to achieve the clear condition.
"""
func duration(settings: LevelSettings) -> float:
	var result := 600.0
	
	match settings.finish_condition.type:
		Milestone.SCORE:
			# assume the player collects all the one-time pickups
			var lines := (settings.finish_condition.value - settings.rank.master_pickup_score) \
					/ _score_per_line(settings)
			lines = clamp(lines, 1, 10000)
			result = _duration_for_lines(settings, lines)
		Milestone.LINES:
			result = _duration_for_lines(settings, settings.finish_condition.value)
		Milestone.PIECES:
			result = _duration_for_lines(settings, settings.finish_condition.value * 2)
		Milestone.TIME_OVER:
			result = settings.finish_condition.value
		Milestone.CUSTOMERS:
			var rank: float = RANKS_BY_DIFFICULTY[settings.get_difficulty()]
			var lines_per_customer := RankCalculator.master_customer_combo(settings)
			lines_per_customer *= pow(RankCalculator.RDF_ENDURANCE, rank)
			var lines := lines_per_customer * settings.finish_condition.value
			result = _duration_for_lines(settings, lines)
	
	return result


"""
Returns the estimated time to clear the specified number of lines.
"""
func _duration_for_lines(settings: LevelSettings, lines: float) -> float:
	var min_frames_per_line := RankCalculator.min_frames_per_line(PieceSpeeds.speed(settings.difficulty))
	var min_lines_per_frame := 1 / min_frames_per_line
	var master_lines_per_second := 60 * min_lines_per_frame + 2 * settings.rank.extra_seconds_per_piece
	var master_lines_per_minute := 60 * master_lines_per_second
	master_lines_per_minute *= pow(RankCalculator.RDF_SPEED, _rank(settings))
	# minimum 8.0 lines per minute; novices don't play THAT slowly
	master_lines_per_minute = max(MIN_LINES_PER_MINUTE, master_lines_per_minute)
	return 60 * lines / master_lines_per_minute


"""
Returns the rank the player is expected to perform at for the specified level.
"""
func _rank(settings: LevelSettings) -> float:
	return RANKS_BY_DIFFICULTY[settings.get_difficulty()]


"""
Returns the estimated score per line for the specified level.

We calculate an approprate rank based on the level difficulty, and then estimate how many bonus points a player of
that rank would achieve from combos and boxes.
"""
func _score_per_line(settings: LevelSettings) -> float:
	var combo_score_per_line := RankCalculator.master_combo_score(settings)
	combo_score_per_line *= pow(RankCalculator.RDF_COMBO_SCORE_PER_LINE, _rank(settings))
	
	var box_score_per_line := RankCalculator.master_box_score(settings)
	box_score_per_line *= pow(RankCalculator.RDF_BOX_SCORE_PER_LINE, _rank(settings))
	
	var pickup_score_per_line := RankCalculator.master_pickup_score_per_line(settings)
	pickup_score_per_line *= pow(RankCalculator.RDF_PICKUP_SCORE_PER_LINE, _rank(settings))
	
	return box_score_per_line + combo_score_per_line + pickup_score_per_line + 1
