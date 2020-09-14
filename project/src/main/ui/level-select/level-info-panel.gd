extends Panel
"""
A panel on the level select screen which summarizes level details.

This includes details such as the level's duration, difficulty, and the player's high score.
"""

# All calculated durations are rounded to one of these aesthetically pleasing values.
const DURATIONS := [
	10, 15, 20, 30, 45, 60,
	90, 120, 150, 180, 270, 360, 480, 600
]

var _duration_calculator := DurationCalculator.new()

"""
Updates the info panel when a new level is selected.
"""
func _on_LevelButtons_level_selected(settings: ScenarioSettings) -> void:
	var text := ""
	var difficulty_string := "Unknown"
	match settings.get_difficulty():
		"T", "0", "1", "2": difficulty_string = "Very Easy"
		"3", "4", "5", "6": difficulty_string = "Easy"
		"7", "8", "9", "A0", "A1": difficulty_string = "Normal"
		"A2", "A3", "A4": difficulty_string = "Hard"
		"A5", "A6", "A7", "A8", "A9", "AA", "AB", "AC", "AD": difficulty_string = "Very Hard"
		"AE", "AF", "F0", "F1": difficulty_string = "Expert"
		"FA", "FB", "FC": difficulty_string = "Very Expert"
		"FD", "FE", "FF", "FFF": difficulty_string = "Master"
	text += "Difficulty: %s\n" % [difficulty_string]
	
	var duration_string: String
	var duration: int
	if settings.finish_condition.type == Milestone.TIME_OVER:
		duration = settings.finish_condition.value
	else:
		duration = _duration_calculator.duration(settings)
		duration = DURATIONS[Utils.find_closest(DURATIONS, duration)]
	
	duration_string = StringUtils.format_duration(duration)
	
	text += "Duration: %s\n" % [duration_string]
	
	var prev_result := PlayerData.scenario_history.prev_result(settings.id)
	var best_results := PlayerData.scenario_history.best_results(settings.id)
	if prev_result:
		text += "New: %s\n" % [PoolStringArray(HighScoreTable.rank_result_row(prev_result)).join("   ")]
	else:
		text += "\n"
	if best_results:
		text += "Top: %s" % [PoolStringArray(HighScoreTable.rank_result_row(best_results[0])).join("   ")]
	else:
		text += ""
	$MarginContainer/Label.text = text


"""
When the 'overall' button is selected, we generate and show some level statistics.
"""
func _on_LevelButtons_overall_selected(ranks: Array) -> void:
	var text := ""
	
	# calculate the worst rank
	var worst_rank := 0.0
	for rank in ranks:
		worst_rank = max(worst_rank, rank)
	
	# count the total number of 'stars' for all of the levels
	var star_count := 0
	for rank in ranks:
		match RankCalculator.grade(rank):
			"S-": star_count += 1
			"S": star_count += 2
			"S+": star_count += 3
			"SS": star_count += 4
			"SS+": star_count += 5
			"SSS": star_count += 6
			"M": star_count += 7
	
	# calculate the percent of levels where the player's rank is already high enough to rank up
	var worst_rank_count := 0
	for rank in ranks:
		if RankCalculator.grade(worst_rank) == RankCalculator.grade(rank):
			worst_rank_count += 1
	var next_rank_pct := float(ranks.size() - worst_rank_count) / ranks.size()
	
	text += "Overall grade: %s" % [RankCalculator.grade(worst_rank)]
	if RankCalculator.grade(worst_rank) != RankCalculator.HIGHEST_GRADE:
		text += "\nProgress towards next grade: %.1f%%" % [100 * next_rank_pct]
	if star_count > 0:
		text += "\nTotal stars: %s" % [star_count]
	$MarginContainer/Label.text = text

