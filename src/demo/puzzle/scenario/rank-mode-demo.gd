extends Label
"""
Demo which performs some complex calculations to determine how fast someone would need to play to achieve a rank on a
particular scenario.

For example, to get rank 28 on the '2 kyu' scenario, a player would need to score 432 points. This is based on the
rank requirements, the duration of the scenario, the piece speed and other factors.

This was used to assign a roughly increasing level of difficulty for rank scenarios.
"""

var _data_per_rank := {
	"7k": ["48", "1", "5:00"],
	"6k": ["40", "2", "3:00"],
	"5k": ["30", "3", "6:00"],
	"4k": ["32", "4", "2:56"],
	"3k": ["30", "5", "9:00"],
	"2k": ["28", "6", "3:00"],
	"1k": ["26", "0", "10:00"],
	"1d": ["24", "A1", "6:00"],
	"2d": ["20", "A5", "5:00"],
	"3d": ["20", "A5", "4:00"],
	"4d": ["16", "AA", "5:00"],
	"5d": ["16", "AA", "6:00"],
	"6d": ["10", "AE", "3:00"],
	"7d": ["10", "A0", "10:00"],
	"8d": ["7", "FA", "3:00"],
	"9d": ["7", "FB", "4:00"],
	"10d": ["4", "FC", "5:00"],
	"M": ["4", "F0", "10:00"],
}

var _rank_calculator := RankCalculator.new()

func _ready() -> void:
	for data_key in _data_per_rank.keys():
		# parse inputs
		var target_rank: float = int(_data_per_rank[data_key][0])
		var start_level: String = _data_per_rank[data_key][1]
		var duration_string: String = _data_per_rank[data_key][2]
		var seconds: float = StringUtils.parse_duration(duration_string)
		
		# calculate target lines and score for a fake scenario which resembles the game's scenario
		Scenario.start_scenario(_scenario_settings(data_key, start_level, seconds))
		var target_score := _target_score(target_rank)
		var target_lines := _target_lines(target_rank)
		
		# print the resulting lines and score
		text += "Rank %s: %s points in %s (%s lines)\n" % [data_key, target_score, duration_string, target_lines]
		
		# for survival scenarios, also print a diminished score which is more realistic to reach under pressure
		match(data_key):
			"1k", "3d", "7d", "M":
				var survival_points := (target_score - target_lines) * 0.6 + target_lines
				text += "  (%s survival: %s points)\n" % [data_key, survival_points]


"""
Creates a scenario with the specified duration.

The piece speed starts at the specified start level, but might increase depending on the specified data key. The speed
increases defined in this method should align with the speed increases of the rank scenarios in the game.
"""
func _scenario_settings(data_key: String, start_level: String, seconds: float) -> ScenarioSettings:
	var settings := ScenarioSettings.new()
	settings.set_start_level(start_level)
	settings.set_finish_condition(Milestone.TIME_OVER, seconds)
	
	match(data_key):
		"1k":
			settings.set_start_level("0")
			settings.add_level_up(Milestone.LINES, 10, "1")
			settings.add_level_up(Milestone.LINES, 20, "2")
			settings.add_level_up(Milestone.LINES, 30, "3")
			settings.add_level_up(Milestone.LINES, 40, "4")
			settings.add_level_up(Milestone.LINES, 50, "5")
			settings.add_level_up(Milestone.LINES, 60, "6")
			settings.add_level_up(Milestone.LINES, 110, "7")
			settings.add_level_up(Milestone.LINES, 120, "8")
			settings.add_level_up(Milestone.LINES, 130, "9")
		"1d":
			settings.set_start_level("A1")
			settings.add_level_up(Milestone.LINES, 40, "A2")
			settings.add_level_up(Milestone.LINES, 60, "A3")
			settings.add_level_up(Milestone.LINES, 80, "A4")
			settings.add_level_up(Milestone.LINES, 100, "A5")
		"3d":
			settings.set_start_level("A5")
			settings.add_level_up(Milestone.LINES, 5, "A6")
			settings.add_level_up(Milestone.LINES, 10, "A7")
			settings.add_level_up(Milestone.LINES, 15, "A8")
			settings.add_level_up(Milestone.LINES, 20, "A9")
			settings.add_level_up(Milestone.LINES, 25, "AA")
			settings.add_level_up(Milestone.LINES, 30, "AB")
			settings.add_level_up(Milestone.LINES, 35, "AC")
			settings.add_level_up(Milestone.LINES, 40, "AD")
		"5d":
			settings.set_start_level("AA")
			settings.add_level_up(Milestone.TIME_OVER, 60, "AB")
			settings.add_level_up(Milestone.TIME_OVER, 120, "AC")
			settings.add_level_up(Milestone.TIME_OVER, 180, "AD")
			settings.add_level_up(Milestone.TIME_OVER, 240, "AA")
			settings.add_level_up(Milestone.TIME_OVER, 300, "AE")
		"7d":
			# similar to 1-dan
			settings.set_start_level("A0")
			settings.add_level_up(Milestone.LINES, 20, "A1")
			settings.add_level_up(Milestone.LINES, 40, "A2")
			settings.add_level_up(Milestone.LINES, 60, "A3")
			settings.add_level_up(Milestone.LINES, 80, "A4")
			settings.add_level_up(Milestone.LINES, 100, "A5")
			
			# ramp up to 20G
			settings.add_level_up(Milestone.LINES, 150, "AA")
			settings.add_level_up(Milestone.LINES, 170, "AC")
			settings.add_level_up(Milestone.LINES, 190, "AF")
			
			# 20G+
			settings.add_level_up(Milestone.LINES, 240, "A1")
			settings.add_level_up(Milestone.LINES, 260, "A5")
			settings.add_level_up(Milestone.LINES, 300, "AA")
			settings.add_level_up(Milestone.LINES, 320, "AF")
			settings.add_level_up(Milestone.LINES, 340, "FA")
		"M":
			settings.set_start_level("FA")
			settings.add_level_up(Milestone.TIME_OVER, 60, "FB")
			settings.add_level_up(Milestone.TIME_OVER, 120, "FC")
			settings.add_level_up(Milestone.TIME_OVER, 180, "FD")
			settings.add_level_up(Milestone.TIME_OVER, 240, "FE")
			settings.add_level_up(Milestone.TIME_OVER, 300, "FF")
			settings.add_level_up(Milestone.TIME_OVER, 360, "FD")
			settings.add_level_up(Milestone.TIME_OVER, 480, "FFF")
	return settings


"""
Binary search for how many points are needed to achieve the specified score_rank.

This depends on the current scenario's duration and piece speed.
"""
func _target_score(target_rank: float) -> float:
	var min_score := 0
	var max_score := 50000
	var rank_result: RankResult
	for _i in range(20):
		PuzzleScore.scenario_performance.score = (min_score + max_score) / 2.0
		rank_result = _rank_calculator.calculate_rank()
		if rank_result.score_rank > target_rank:
			# graded poorly; we need to score more points
			min_score = PuzzleScore.scenario_performance.score
		else:
			# graded well; we need to score fewer points
			max_score = PuzzleScore.scenario_performance.score
	return (min_score + max_score) / 2.0


"""
Binary search for how many lines are needed to achieve the specified line_rank.

This depends on the current scenario's duration and piece speed.
"""
func _target_lines(target_rank: int) -> float:
	Scenario.settings.finish_condition.type = Milestone.LINES
	var min_target_lines := 0
	var max_target_lines := 5000
	var rank_result: RankResult
	for _i in range(20):
		PuzzleScore.scenario_performance.lines = ceil((min_target_lines + max_target_lines) / 2.0)
		rank_result = _rank_calculator.calculate_rank()
		if rank_result.lines_rank > target_rank:
			# graded poorly; we need to clear more lines than that
			min_target_lines = PuzzleScore.scenario_performance.lines
		else:
			# graded well; we need to clear fewer lines than that
			max_target_lines = PuzzleScore.scenario_performance.lines
	return (max_target_lines + min_target_lines) / 2.0
