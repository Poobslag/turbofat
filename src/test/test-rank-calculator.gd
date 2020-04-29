extends "res://addons/gut/test.gd"
"""
Unit test demonstrating the rank calculator. If a player scores a lot of points, the game should give them a higher
rank. Short levels with slower pieces require lower scores, because even a perfect player couldn't score very many
points.

There are a lot of variables and edge cases involved in the rank calculations, and it's easy to introduce obscure bugs
where it's impossible to get a master rank, or the rank system is too forgiving, which is why unit tests are
particularly important for this code.
"""

var _rank_calculator := RankCalculator.new()

func before_each() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.set_win_condition("lines", 100)
	Global.scenario_performance = ScenarioPerformance.new()

func test_max_lpm_slow_marathon() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	assert_almost_eq(_rank_calculator._max_lpm(), 34.29, 0.1)

func test_max_lpm_medium_marathon() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.hard_level_0)
	assert_almost_eq(_rank_calculator._max_lpm(), 40.44, 0.1)

func test_max_lpm_fast_marathon() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.crazy_level_0)
	assert_almost_eq(_rank_calculator._max_lpm(), 81.36, 0.1)

func test_max_lpm_mixed_marathon() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.add_level_up("lines", 30, PieceSpeeds.crazy_level_0)
	Global.scenario_settings.add_level_up("lines", 60, PieceSpeeds.hard_level_0)
	Global.scenario_settings.set_win_condition("lines", 100)
	assert_almost_eq(_rank_calculator._max_lpm(), 46.51, 0.1)

func test_max_lpm_mixed_sprint() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.add_level_up("time", 30, PieceSpeeds.crazy_level_0)
	Global.scenario_settings.add_level_up("time", 60, PieceSpeeds.hard_level_0)
	Global.scenario_settings.set_win_condition("time", 90)
	assert_almost_eq(_rank_calculator._max_lpm(), 49.95, 0.1)

func test_calculate_rank_marathon_300_master() -> void:
	Global.scenario_settings.set_win_condition("lines", 300)
	Global.scenario_performance.seconds = 580
	Global.scenario_performance.lines = 300
	Global.scenario_performance.box_score = 4400
	Global.scenario_performance.combo_score = 5300
	Global.scenario_performance.score = 10000
	var rank :=  _rank_calculator.calculate_rank()
	assert_eq(rank.speed_rank, 0.0)
	assert_eq(rank.lines_rank, 0.0)
	assert_eq(rank.box_score_per_line_rank, 0.0)
	assert_eq(rank.combo_score_per_line_rank, 0.0)
	assert_eq(rank.score_rank, 0.0)

func test_calculate_rank_marathon_300_mixed() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.set_win_condition("lines", 300)
	Global.scenario_performance.seconds = 240
	Global.scenario_performance.lines = 60
	Global.scenario_performance.box_score = 600
	Global.scenario_performance.combo_score = 500
	Global.scenario_performance.score = 1160
	var rank := _rank_calculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "A")
	assert_eq(Global.grade(rank.lines_rank), "C")
	assert_eq(Global.grade(rank.box_score_per_line_rank), "S-")
	assert_eq(Global.grade(rank.combo_score_per_line_rank), "B")
	assert_eq(Global.grade(rank.score_rank), "B")

func test_calculate_rank_marathon_lenient() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.set_win_condition("lines", 300, 200)
	Global.scenario_performance.seconds = 240
	Global.scenario_performance.lines = 60
	Global.scenario_performance.box_score = 600
	Global.scenario_performance.combo_score = 500
	Global.scenario_performance.score = 1160
	var rank := _rank_calculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "A")
	assert_eq(Global.grade(rank.lines_rank), "B")
	assert_eq(Global.grade(rank.box_score_per_line_rank), "S-")
	assert_eq(Global.grade(rank.combo_score_per_line_rank), "B")
	assert_eq(Global.grade(rank.score_rank), "B+")

func test_calculate_rank_marathon_300_fail() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.set_win_condition("lines", 300)
	Global.scenario_performance.seconds = 0
	Global.scenario_performance.lines = 0
	Global.scenario_performance.box_score = 0
	Global.scenario_performance.combo_score = 0
	Global.scenario_performance.score = 0
	var rank := _rank_calculator.calculate_rank()
	assert_eq(rank.speed_rank, 999.0)
	assert_eq(rank.lines_rank, 999.0)
	assert_eq(rank.box_score_per_line_rank, 999.0)
	assert_eq(rank.combo_score_per_line_rank, 999.0)
	assert_eq(rank.score_rank, 999.0)

func test_calculate_rank_sprint_120() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.hard_level_0)
	Global.scenario_settings.set_win_condition("time", 120)
	Global.scenario_performance.seconds = 120
	Global.scenario_performance.lines = 47
	Global.scenario_performance.box_score = 395
	Global.scenario_performance.combo_score = 570
	Global.scenario_performance.score = 1012
	var rank := _rank_calculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "A+")
	assert_eq(Global.grade(rank.lines_rank), "A+")
	assert_eq(Global.grade(rank.box_score_per_line_rank), "A")
	assert_eq(Global.grade(rank.combo_score_per_line_rank), "A+")
	assert_eq(Global.grade(rank.score_rank), "A+")

func test_calculate_rank_ultra_200() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.set_win_condition("score", 200)
	Global.scenario_performance.seconds = 20.233
	Global.scenario_performance.lines = 8
	Global.scenario_performance.box_score = 135
	Global.scenario_performance.combo_score = 60
	Global.scenario_performance.score = 8
	var rank := _rank_calculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "S")
	assert_eq(Global.grade(rank.box_score_per_line_rank), "M")
	assert_eq(rank.combo_score_per_line, 20.0)
	assert_eq(Global.grade(rank.combo_score_per_line_rank), "M")
	assert_eq(Global.grade(rank.seconds_rank), "S++")

func test_calculate_rank_ultra_200_died() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.set_win_condition("score", 200)
	Global.scenario_performance.seconds = 60
	Global.scenario_performance.lines = 10
	Global.scenario_performance.box_score = 80
	Global.scenario_performance.combo_score = 60
	Global.scenario_performance.score = 150
	Global.scenario_performance.died = true
	var rank := _rank_calculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "B")
	assert_eq(rank.seconds_rank, 999.0)
	assert_eq(Global.grade(rank.box_score_per_line_rank), "C+")
	assert_eq(Global.grade(rank.combo_score_per_line_rank), "-")

"""
This is an edge case where, if the player gets too many points for ultra, they can sort of be robbed of a master rank.
"""
func test_calculate_rank_ultra_200_overshot() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.set_win_condition("score", 200)
	Global.scenario_performance.seconds = 24
	Global.scenario_performance.lines = 10
	Global.scenario_performance.box_score = 150
	Global.scenario_performance.combo_score = 100
	Global.scenario_performance.score = 260
	var rank := _rank_calculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "S")
	assert_eq(Global.grade(rank.box_score_per_line_rank), "M")
	assert_eq(Global.grade(rank.combo_score_per_line_rank), "M")
	assert_eq(Global.grade(rank.seconds_rank), "S")

"""
These two times are pretty far apart; they shouldn't yield the same rank
"""
func test_two_rank_s() -> void:
	Global.scenario_settings.set_start_level(PieceSpeeds.hard_level_0)
	Global.scenario_settings.set_win_condition("score", 1000)
	Global.scenario_performance.seconds = 88.55
	var rank := _rank_calculator.calculate_rank()
	assert_eq(Global.grade(rank.seconds_rank), "S")

	Global.scenario_settings.set_win_condition("score", 1000)
	Global.scenario_performance.seconds = 128.616
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(Global.grade(rank2.seconds_rank), "A+")

"""
This edge case used to result in a combo_score_per_line of 22.5
"""
func test_combo_score_per_line_ultra_overshot() -> void:
	Global.scenario_settings.set_win_condition("score", 200)
	Global.scenario_performance.combo_score = 45
	Global.scenario_performance.lines = 7
	var rank := _rank_calculator.calculate_rank()
	assert_eq(rank.combo_score_per_line, 20.0)

"""
This edge case used to result in a combo_score_per_line of 0.305
"""
func test_combo_score_per_line_death() -> void:
	Global.scenario_settings.set_win_condition("lines", 200, 150)
	Global.scenario_performance.combo_score = 195
	Global.scenario_performance.lines = 37
	Global.scenario_performance.died = true
	var rank := _rank_calculator.calculate_rank()
	assert_almost_eq(rank.combo_score_per_line, 6.09, 0.1)
