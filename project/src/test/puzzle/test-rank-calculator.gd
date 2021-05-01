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
	CurrentLevel.settings = LevelSettings.new()
	CurrentLevel.settings.set_start_speed("0")
	PuzzleScore.level_performance = PuzzlePerformance.new()


func test_master_lpm_slow_marathon() -> void:
	CurrentLevel.settings.set_start_speed("0")
	assert_almost_eq(_rank_calculator._master_lpm(), 30.77, 0.1)


func test_master_lpm_medium_marathon() -> void:
	CurrentLevel.settings.set_start_speed("A0")
	assert_almost_eq(_rank_calculator._master_lpm(), 35.64, 0.1)


func test_master_lpm_fast_marathon() -> void:
	CurrentLevel.settings.set_start_speed("F0")
	assert_almost_eq(_rank_calculator._master_lpm(), 68.90, 0.1)


func test_master_lpm_mixed_marathon() -> void:
	CurrentLevel.settings.set_start_speed("0")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 30, "A0")
	CurrentLevel.settings.add_speed_up(Milestone.LINES, 60, "F0")
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 100)
	assert_almost_eq(_rank_calculator._master_lpm(), 46.23, 0.1)


func test_master_lpm_mixed_sprint() -> void:
	CurrentLevel.settings.set_start_speed("0")
	CurrentLevel.settings.add_speed_up(Milestone.TIME_OVER, 30, "A0")
	CurrentLevel.settings.add_speed_up(Milestone.TIME_OVER, 60, "F0")
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 90)
	assert_almost_eq(_rank_calculator._master_lpm(), 50.98, 0.1)


func test_calculate_rank_marathon_300_master() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300)
	PuzzleScore.level_performance.seconds = 580
	PuzzleScore.level_performance.lines = 300
	PuzzleScore.level_performance.box_score = 4400
	PuzzleScore.level_performance.combo_score = 5300
	PuzzleScore.level_performance.score = 10400
	var rank :=  _rank_calculator.calculate_rank()
	assert_eq(rank.speed_rank, 0.0)
	assert_eq(rank.lines_rank, 0.0)
	assert_eq(rank.box_score_per_line_rank, 0.0)
	assert_eq(rank.combo_score_per_line_rank, 0.0)
	assert_eq(rank.score_rank, 0.0)


func test_calculate_rank_marathon_300_mixed() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300)
	PuzzleScore.level_performance.seconds = 240
	PuzzleScore.level_performance.lines = 60
	PuzzleScore.level_performance.box_score = 600
	PuzzleScore.level_performance.combo_score = 500
	PuzzleScore.level_performance.score = 1160
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "S")
	assert_eq(RankCalculator.grade(rank.lines_rank), "A+")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "S+")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "S-")
	assert_eq(RankCalculator.grade(rank.score_rank), "AA+")


func test_calculate_rank_marathon_lenient() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300, 200)
	PuzzleScore.level_performance.seconds = 240
	PuzzleScore.level_performance.lines = 60
	PuzzleScore.level_performance.box_score = 600
	PuzzleScore.level_performance.combo_score = 500
	PuzzleScore.level_performance.score = 1160
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "S")
	assert_eq(RankCalculator.grade(rank.lines_rank), "AA+")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "S+")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "S-")
	assert_eq(RankCalculator.grade(rank.score_rank), "AA+")


func test_calculate_rank_marathon_300_fail() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300)
	PuzzleScore.level_performance.seconds = 0
	PuzzleScore.level_performance.lines = 0
	PuzzleScore.level_performance.box_score = 0
	PuzzleScore.level_performance.combo_score = 0
	PuzzleScore.level_performance.score = 0
	var rank := _rank_calculator.calculate_rank()
	assert_eq(rank.speed_rank, 999.0)
	assert_eq(rank.lines_rank, 999.0)
	assert_eq(rank.box_score_per_line_rank, 999.0)
	assert_eq(rank.combo_score_per_line_rank, 999.0)
	assert_eq(rank.score_rank, 999.0)


func test_calculate_pieces_rank() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 80)
	PuzzleScore.level_performance.pieces = 40
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.pieces_rank), "S")


func test_calculate_rank_sprint_120() -> void:
	CurrentLevel.settings.set_start_speed("A0")
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	PuzzleScore.level_performance.seconds = 120
	PuzzleScore.level_performance.lines = 47
	PuzzleScore.level_performance.box_score = 395
	PuzzleScore.level_performance.combo_score = 570
	PuzzleScore.level_performance.score = 1012
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "S+")
	assert_eq(RankCalculator.grade(rank.lines_rank), "S+")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "S")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "SS")
	assert_eq(RankCalculator.grade(rank.score_rank), "S+")


func test_calculate_rank_top_out_once() -> void:
	CurrentLevel.settings.set_start_speed("A0")
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	PuzzleScore.level_performance.seconds = 120
	PuzzleScore.level_performance.lines = 47
	PuzzleScore.level_performance.box_score = 395
	PuzzleScore.level_performance.combo_score = 570
	PuzzleScore.level_performance.score = 1012
	PuzzleScore.level_performance.top_out_count = 1
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "S+")
	assert_eq(RankCalculator.grade(rank.lines_rank), "S+")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "S-")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "S+")
	assert_eq(RankCalculator.grade(rank.score_rank), "S+")


func test_calculate_rank_top_out_twice() -> void:
	CurrentLevel.settings.set_start_speed("A0")
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	PuzzleScore.level_performance.seconds = 120
	PuzzleScore.level_performance.lines = 47
	PuzzleScore.level_performance.box_score = 395
	PuzzleScore.level_performance.combo_score = 570
	PuzzleScore.level_performance.score = 1012
	PuzzleScore.level_performance.top_out_count = 2
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "S")
	assert_eq(RankCalculator.grade(rank.lines_rank), "S")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "AA+")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "S")
	assert_eq(RankCalculator.grade(rank.score_rank), "S")


func test_calculate_rank_ultra_200() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	PuzzleScore.level_performance.seconds = 20.233
	PuzzleScore.level_performance.lines = 8
	PuzzleScore.level_performance.box_score = 135
	PuzzleScore.level_performance.combo_score = 60
	PuzzleScore.level_performance.score = 8
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "SS+")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "M")
	assert_eq(rank.combo_score_per_line, 20.0)
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "M")
	assert_eq(RankCalculator.grade(rank.seconds_rank), "SSS")


func test_calculate_rank_ultra_200_lost() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	PuzzleScore.level_performance.seconds = 60
	PuzzleScore.level_performance.lines = 10
	PuzzleScore.level_performance.box_score = 80
	PuzzleScore.level_performance.combo_score = 60
	PuzzleScore.level_performance.score = 150
	PuzzleScore.level_performance.lost = true
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "AA+")
	assert_eq(rank.seconds_rank, 999.0)
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "S-")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "S")


"""
This is an edge case where, if the player gets too many points for ultra, they can sort of be robbed of a master rank.
"""
func test_calculate_rank_ultra_200_overshot() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	PuzzleScore.level_performance.seconds = 19
	PuzzleScore.level_performance.lines = 10
	PuzzleScore.level_performance.box_score = 150
	PuzzleScore.level_performance.combo_score = 100
	PuzzleScore.level_performance.score = 260
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "M")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "M")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "M")
	assert_eq(RankCalculator.grade(rank.seconds_rank), "SSS")


"""
A level requiring only one line clear used to trigger divide by zero errors.
"""
func test_calculate_rank_ultra_1() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1)
	PuzzleScore.level_performance.seconds = 7.233
	PuzzleScore.level_performance.lines = 1
	PuzzleScore.level_performance.score = 1
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.seconds_rank), "SSS")


func test_calculate_rank_five_creatures_good() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 5)
	CurrentLevel.settings.set_start_speed("4")
	PuzzleScore.level_performance.lines = 100
	PuzzleScore.level_performance.box_score = 1025
	PuzzleScore.level_performance.combo_score = 915
	PuzzleScore.level_performance.score = 2040
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.lines_rank), "SSS")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "S+")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "S")
	assert_eq(RankCalculator.grade(rank.score_rank), "SS")


func test_calculate_rank_five_creatures_bad() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 5)
	CurrentLevel.settings.set_start_speed("4")
	PuzzleScore.level_performance.lines = 18
	PuzzleScore.level_performance.box_score = 90
	PuzzleScore.level_performance.combo_score = 60
	PuzzleScore.level_performance.score = 168
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.lines_rank), "A-")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "AA")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "A")
	assert_eq(RankCalculator.grade(rank.score_rank), "A-")


"""
These two times are pretty far apart; they shouldn't yield the same rank
"""
func test_two_rank_s() -> void:
	CurrentLevel.settings.set_start_speed("A0")
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	PuzzleScore.level_performance.seconds = 88.55
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.seconds_rank), "SS+")

	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	PuzzleScore.level_performance.seconds = 128.616
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.seconds_rank), "S+")


"""
This edge case used to result in a combo_score_per_line of 22.5
"""
func test_combo_score_per_line_ultra_overshot() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	PuzzleScore.level_performance.combo_score = 45
	PuzzleScore.level_performance.lines = 7
	var rank := _rank_calculator.calculate_rank()
	assert_eq(rank.combo_score_per_line, 20.0)


"""
This edge case used to result in a combo_score_per_line of 0.305
"""
func test_combo_score_per_line_death() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 200, 150)
	PuzzleScore.level_performance.combo_score = 195
	PuzzleScore.level_performance.lines = 37
	PuzzleScore.level_performance.top_out_count = 1
	var rank := _rank_calculator.calculate_rank()
	assert_almost_eq(rank.combo_score_per_line, 6.09, 0.1)


"""
A player reaching a success condition should be given a rank boost.
"""
func test_success_bonus_score() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300, 200)
	PuzzleScore.level_performance.seconds = 240
	PuzzleScore.level_performance.score = 1160
	CurrentLevel.settings.rank.success_bonus = 8
	
	# the player doesn't achieve the success condition; they get a worse grade
	CurrentLevel.settings.set_success_condition(Milestone.SCORE, 2000)
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.score_rank), "AA+")

	# the player achieves the success condition; they get a better grade
	CurrentLevel.settings.set_success_condition(Milestone.SCORE, 1000)
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.score_rank), "S")


func test_success_bonus_seconds() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	PuzzleScore.level_performance.seconds = 240
	PuzzleScore.level_performance.score = 1160
	CurrentLevel.settings.rank.success_bonus = 8
	
	# the player doesn't achieve the success condition; they get a worse grade
	CurrentLevel.settings.set_success_condition(Milestone.TIME_UNDER, 180)
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.seconds_rank), "S")

	# the player achieves the success condition; they get a better grade
	CurrentLevel.settings.set_success_condition(Milestone.TIME_UNDER, 300)
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.seconds_rank), "S+")


func test_customer_combo() -> void:
	CurrentLevel.settings.rank.customer_combo = 8
	CurrentLevel.settings.rank.leftover_lines = 3
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 1)
	PuzzleScore.level_performance.score = 296
	
	# the player doesn't achieve the success condition; they get a worse grade
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.score_rank), "M")


func test_unranked() -> void:
	CurrentLevel.settings.rank.unranked = true
	
	# the player finishes the level; they automatically get a master rank
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.seconds_rank), "M")
	assert_eq(RankCalculator.grade(rank.score_rank), "M")


func test_unranked_loss() -> void:
	CurrentLevel.settings.rank.unranked = true
	PuzzleScore.level_performance.lost = true
	
	# the player lost the level; they get the worst rank
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.seconds_rank), "-")
	assert_eq(RankCalculator.grade(rank.score_rank), "-")


func test_extra_seconds_per_piece() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 180)
	PuzzleScore.level_performance.seconds = 180
	PuzzleScore.level_performance.lines = 60
	PuzzleScore.level_performance.score = 1160
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.speed_rank), "S+")
	assert_eq(RankCalculator.grade(rank1.score_rank), "S+")
	
	# with the 'extra_seconds_per_piece' setting enabled, the player gets a better grade
	CurrentLevel.settings.rank.extra_seconds_per_piece = 1.2
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.speed_rank), "M")
	assert_eq(RankCalculator.grade(rank2.score_rank), "SSS")
