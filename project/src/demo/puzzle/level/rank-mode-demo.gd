extends Label
"""
Demo which performs some complex calculations to determine how fast someone would need to play to achieve a rank on a
particular level.

For example, to get rank 28 on the '2 kyu' level, a player would need to score 432 points. This is based on the
rank requirements, the duration of the level, the piece speed and other factors.

This was used to assign a roughly increasing level of difficulty for rank levels.
"""

var _data_per_rank := {
	"7k": ["48", "1", "5:00"],
	"6k": ["40", "2", "3:00"],
	"5k": ["36", "3", "6:00"],
	"4k": ["32", "4", "2:56"],
	"3k": ["30", "5", "9:00"],
	"2k": ["28", "6", "3:00"],
	"1k": ["26", "0", "10:00"],
	"1d": ["24", "A1", "6:00"],
	"2d": ["20", "A5", "5:00"],
	"3d": ["20", "A1", "4:00"],
	"4d": ["16", "AA", "5:00"],
	"5d": ["16", "AA", "6:00"],
	"6d": ["10", "AE", "3:00"],
	"7d": ["10", "A0", "10:00"],
	"8d": ["7", "FA", "3:00"],
	"9d": ["7", "FB", "4:00"],
	"10d": ["4", "FC", "5:00"],
	"M": ["4", "FA", "10:00"],
}

var _rank_calculator := RankCalculator.new()

func _ready() -> void:
	for data_key in _data_per_rank.keys():
		# parse inputs
		var target_rank: float = int(_data_per_rank[data_key][0])
		var start_speed: String = _data_per_rank[data_key][1]
		var duration_string: String = _data_per_rank[data_key][2]
		var seconds: float = StringUtils.parse_duration(duration_string)
		
		# calculate target lines and score for a fake level which resembles the game's level
		CurrentLevel.start_level(_level_settings(data_key, start_speed, seconds))
		var target_score := _target_score(target_rank)
		var target_lines := _target_lines(target_rank)
		
		# print the resulting lines and score
		text += "Rank %s: %s points in %s" % [data_key, target_score, duration_string]
		text += " (%s lines, %01d bpm, %01d ppl)\n" \
				% [target_lines, (2 * target_lines) / (seconds / 60.0), target_score / target_lines]
		
		# for marathon levels, also print a diminished score which is more realistic to reach under pressure
		match data_key:
			"1k", "7d", "M":
				var marathon_points := (target_score - target_lines) * 0.6 + target_lines
				text += "  (%s marathon: %s points)\n" % [data_key, marathon_points]


"""
Creates a level with the specified duration.

The piece speed starts at the specified start level, but might increase depending on the specified data key. The speed
increases defined in this method should align with the speed increases of the rank levels in the game.
"""
func _level_settings(data_key: String, start_speed: String, seconds: float) -> LevelSettings:
	var settings := LevelSettings.new()
	settings.id = data_key
	settings.set_start_speed(start_speed)
	settings.set_finish_condition(Milestone.TIME_OVER, seconds)
	
	match data_key:
		"1k":
			settings.set_start_speed("0")
			settings.add_speed_up(Milestone.LINES, 10, "1")
			settings.add_speed_up(Milestone.LINES, 20, "2")
			settings.add_speed_up(Milestone.LINES, 30, "3")
			settings.add_speed_up(Milestone.LINES, 40, "4")
			settings.add_speed_up(Milestone.LINES, 50, "5")
			settings.add_speed_up(Milestone.LINES, 60, "6")
			settings.add_speed_up(Milestone.LINES, 110, "7")
			settings.add_speed_up(Milestone.LINES, 120, "8")
			settings.add_speed_up(Milestone.LINES, 130, "9")
		"1d":
			settings.set_start_speed("A1")
			settings.add_speed_up(Milestone.LINES, 40, "A2")
			settings.add_speed_up(Milestone.LINES, 60, "A3")
			settings.add_speed_up(Milestone.LINES, 80, "A4")
			settings.add_speed_up(Milestone.LINES, 100, "A5")
		"3d":
			settings.set_start_speed("A1")
			settings.add_speed_up(Milestone.LINES, 1, "A2")
			settings.add_speed_up(Milestone.LINES, 5, "A3")
			settings.add_speed_up(Milestone.LINES, 9, "A4")
			settings.add_speed_up(Milestone.LINES, 13, "A5")
			settings.add_speed_up(Milestone.LINES, 17, "A6")
			settings.add_speed_up(Milestone.LINES, 21, "A7")
			settings.add_speed_up(Milestone.LINES, 25, "A8")
			settings.add_speed_up(Milestone.LINES, 29, "A9")
			settings.add_speed_up(Milestone.LINES, 33, "AA")
			settings.add_speed_up(Milestone.LINES, 37, "AB")
			settings.add_speed_up(Milestone.LINES, 41, "AC")
			settings.add_speed_up(Milestone.LINES, 45, "AD")
		"5d":
			settings.set_start_speed("AA")
			settings.add_speed_up(Milestone.TIME_OVER, 60, "AB")
			settings.add_speed_up(Milestone.TIME_OVER, 120, "AC")
			settings.add_speed_up(Milestone.TIME_OVER, 180, "AD")
			settings.add_speed_up(Milestone.TIME_OVER, 240, "AA")
			settings.add_speed_up(Milestone.TIME_OVER, 300, "AE")
		"7d":
			# similar to 1-dan
			settings.set_start_speed("A0")
			settings.add_speed_up(Milestone.LINES, 20, "A1")
			settings.add_speed_up(Milestone.LINES, 40, "A2")
			settings.add_speed_up(Milestone.LINES, 60, "A3")
			settings.add_speed_up(Milestone.LINES, 80, "A4")
			settings.add_speed_up(Milestone.LINES, 100, "A5")
			
			# ramp up to 20G
			settings.add_speed_up(Milestone.LINES, 150, "AA")
			settings.add_speed_up(Milestone.LINES, 170, "AC")
			settings.add_speed_up(Milestone.LINES, 190, "AF")
			
			# 20G+
			settings.add_speed_up(Milestone.LINES, 240, "A1")
			settings.add_speed_up(Milestone.LINES, 260, "A5")
			settings.add_speed_up(Milestone.LINES, 300, "AA")
			settings.add_speed_up(Milestone.LINES, 320, "AF")
			settings.add_speed_up(Milestone.LINES, 340, "FA")
		"M":
			settings.set_start_speed("FA")
			settings.add_speed_up(Milestone.TIME_OVER, 60, "FB")
			settings.add_speed_up(Milestone.TIME_OVER, 120, "FC")
			settings.add_speed_up(Milestone.TIME_OVER, 180, "FD")
			settings.add_speed_up(Milestone.TIME_OVER, 240, "FE")
			settings.add_speed_up(Milestone.TIME_OVER, 300, "FF")
			settings.add_speed_up(Milestone.TIME_OVER, 360, "FD")
			settings.add_speed_up(Milestone.TIME_OVER, 480, "FFF")
	return settings


"""
Binary search for how many points are needed to achieve the specified score_rank.

This depends on the current level's duration and piece speed.
"""
func _target_score(target_rank: float) -> float:
	var min_score := 0
	var max_score := 50000
	var rank_result: RankResult
	for _i in range(20):
		PuzzleScore.level_performance.score = (min_score + max_score) / 2.0
		rank_result = _rank_calculator.calculate_rank()
		if rank_result.score_rank > target_rank:
			# graded poorly; we need to score more points
			min_score = PuzzleScore.level_performance.score
		else:
			# graded well; we need to score fewer points
			max_score = PuzzleScore.level_performance.score
	return (min_score + max_score) / 2.0


"""
Binary search for how many lines are needed to achieve the specified line_rank.

This depends on the current level's duration and piece speed.
"""
func _target_lines(target_rank: int) -> float:
	var min_target_lines := 0
	var max_target_lines := 5000
	var rank_result: RankResult
	for _i in range(20):
		PuzzleScore.level_performance.lines = ceil((min_target_lines + max_target_lines) / 2.0)
		rank_result = _rank_calculator.calculate_rank()
		if rank_result.lines_rank > target_rank:
			# graded poorly; we need to clear more lines than that
			min_target_lines = PuzzleScore.level_performance.lines
		else:
			# graded well; we need to clear fewer lines than that
			max_target_lines = PuzzleScore.level_performance.lines
	return (max_target_lines + min_target_lines) / 2.0
