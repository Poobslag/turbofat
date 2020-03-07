extends "res://addons/gut/test.gd"

var RankCalculator = preload("res://scenes/RankCalculator.gd").new()

func before_each():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.set_win_condition("lines", 100)
	Global.scenario_performance = Global.ScenarioPerformance.new()

func test_max_lpm_slow_marathon():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	assert_almost_eq(RankCalculator._max_lpm(), 25.31, 0.1)

func test_max_lpm_medium_marathon():
	Global.scenario.set_start_level(PieceSpeeds.hard_level_0)
	assert_almost_eq(RankCalculator._max_lpm(), 28.51, 0.1)

func test_max_lpm_fast_marathon():
	Global.scenario.set_start_level(PieceSpeeds.crazy_level_0)
	assert_almost_eq(RankCalculator._max_lpm(), 77.42, 0.1)

func test_max_lpm_mixed_marathon():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.add_level_up("lines", 30, PieceSpeeds.crazy_level_0)
	Global.scenario.add_level_up("lines", 60, PieceSpeeds.hard_level_0)
	Global.scenario.set_win_condition("lines", 100)
	assert_almost_eq(RankCalculator._max_lpm(), 34.73, 0.1)

func test_max_lpm_mixed_sprint():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.add_level_up("time", 30, PieceSpeeds.crazy_level_0)
	Global.scenario.add_level_up("time", 60, PieceSpeeds.hard_level_0)
	Global.scenario.set_win_condition("time", 90)
	assert_almost_eq(RankCalculator._max_lpm(), 38.04, 0.1)

func test_calculate_rank_marathon_300_master():
	Global.scenario.set_win_condition("lines", 300)
	Global.scenario_performance.seconds = 600
	Global.scenario_performance.lines = 300
	Global.scenario_performance.box_score = 4100
	Global.scenario_performance.combo_score = 5100
	Global.scenario_performance.score = 9500
	var rank = RankCalculator.calculate_rank()
	assert_eq(rank.speed_rank, 0.0)
	assert_eq(rank.lines_rank, 0.0)
	assert_eq(rank.box_score_rank, 0.0)
	assert_eq(rank.combo_score_rank, 0.0)
	assert_eq(rank.score_rank, 0.0)

func test_calculate_rank_marathon_300_mixed():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.set_win_condition("lines", 300)
	Global.scenario_performance.seconds = 240
	Global.scenario_performance.lines = 60
	Global.scenario_performance.box_score = 600
	Global.scenario_performance.combo_score = 500
	Global.scenario_performance.score = 1160
	var rank = RankCalculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "S-")
	assert_eq(Global.grade(rank.lines_rank), "C")
	assert_eq(Global.grade(rank.box_score_rank), "S")
	assert_eq(Global.grade(rank.combo_score_rank), "B")
	assert_eq(Global.grade(rank.score_rank), "B")

func test_calculate_rank_marathon_lenient():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.set_win_condition("lines", 300, 200)
	Global.scenario_performance.seconds = 240
	Global.scenario_performance.lines = 60
	Global.scenario_performance.box_score = 600
	Global.scenario_performance.combo_score = 500
	Global.scenario_performance.score = 1160
	var rank = RankCalculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "S-")
	assert_eq(Global.grade(rank.lines_rank), "B")
	assert_eq(Global.grade(rank.box_score_rank), "S")
	assert_eq(Global.grade(rank.combo_score_rank), "B")
	assert_eq(Global.grade(rank.score_rank), "B+")

func test_calculate_rank_marathon_300_fail():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.set_win_condition("lines", 300)
	Global.scenario_performance.seconds = 0
	Global.scenario_performance.lines = 0
	Global.scenario_performance.box_score = 0
	Global.scenario_performance.combo_score = 0
	Global.scenario_performance.score = 0
	var rank = RankCalculator.calculate_rank()
	assert_eq(rank.speed_rank, 999.0)
	assert_eq(rank.lines_rank, 999.0)
	assert_eq(rank.box_score_rank, 999.0)
	assert_eq(rank.combo_score_rank, 999.0)
	assert_eq(rank.score_rank, 999.0)

func test_calculate_rank_sprint_120():
	Global.scenario.set_start_level(PieceSpeeds.hard_level_0)
	Global.scenario.set_win_condition("time", 120)
	Global.scenario_performance.seconds = 120
	Global.scenario_performance.lines = 47
	Global.scenario_performance.box_score = 395
	Global.scenario_performance.combo_score = 570
	Global.scenario_performance.score = 1012
	var rank = RankCalculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "S+")
	assert_eq(Global.grade(rank.lines_rank), "S+")
	assert_eq(Global.grade(rank.box_score_rank), "A+")
	assert_eq(Global.grade(rank.combo_score_rank), "A+")
	assert_eq(Global.grade(rank.score_rank), "S")

func test_calculate_rank_ultra_200():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.set_win_condition("score", 200)
	Global.scenario_performance.seconds = 21.233
	Global.scenario_performance.lines = 8
	Global.scenario_performance.box_score = 115
	Global.scenario_performance.combo_score = 80
	Global.scenario_performance.score = 8
	var rank = RankCalculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "M")
	assert_eq(Global.grade(rank.box_score_rank), "M")
	assert_eq(Global.grade(rank.combo_score_rank), "M")
	assert_eq(Global.grade(rank.seconds_rank), "M")

func test_calculate_rank_ultra_200_died():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.set_win_condition("score", 200)
	Global.scenario_performance.seconds = 60
	Global.scenario_performance.lines = 10
	Global.scenario_performance.box_score = 80
	Global.scenario_performance.combo_score = 60
	Global.scenario_performance.score = 150
	Global.scenario_performance.died = true
	var rank = RankCalculator.calculate_rank()
	assert_eq(Global.grade(rank.speed_rank), "A")
	assert_eq(rank.seconds_rank, 999.0)
	assert_eq(Global.grade(rank.box_score_rank), "B-")
	assert_eq(Global.grade(rank.combo_score_rank), "-")
