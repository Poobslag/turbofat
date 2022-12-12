extends GutTest

var _rank_calculator := RankCalculator.new()

func before_each() -> void:
	CurrentLevel.settings = LevelSettings.new()
	PuzzleState.level_performance = PuzzlePerformance.new()


func test_rank_lpm_slow_marathon() -> void:
	CurrentLevel.settings.speed.set_start_speed("0")
	assert_almost_eq(_rank_calculator.rank_lpm(RankResult.BEST_RANK), 30.77, 0.1)


func test_rank_lpm_medium_marathon() -> void:
	CurrentLevel.settings.speed.set_start_speed("A0")
	assert_almost_eq(_rank_calculator.rank_lpm(RankResult.BEST_RANK), 35.64, 0.1)


func test_rank_lpm_fast_marathon() -> void:
	CurrentLevel.settings.speed.set_start_speed("F0")
	assert_almost_eq(_rank_calculator.rank_lpm(RankResult.BEST_RANK), 65.00, 0.1)


func test_rank_lpm_mixed_marathon() -> void:
	CurrentLevel.settings.speed.set_start_speed("0")
	CurrentLevel.settings.speed.add_speed_up(Milestone.LINES, 30, "A0")
	CurrentLevel.settings.speed.add_speed_up(Milestone.LINES, 60, "F0")
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 100)
	assert_almost_eq(_rank_calculator.rank_lpm(RankResult.BEST_RANK), 45.27, 0.1)


func test_rank_lpm_mixed_sprint() -> void:
	CurrentLevel.settings.speed.set_start_speed("0")
	CurrentLevel.settings.speed.add_speed_up(Milestone.TIME_OVER, 30, "A0")
	CurrentLevel.settings.speed.add_speed_up(Milestone.TIME_OVER, 60, "F0")
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 90)
	assert_almost_eq(_rank_calculator.rank_lpm(RankResult.BEST_RANK), 49.54, 0.1)


func test_calculate_rank_marathon_300_master() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300)
	PuzzleState.level_performance.seconds = 580
	PuzzleState.level_performance.lines = 300
	PuzzleState.level_performance.box_score = 4400
	PuzzleState.level_performance.combo_score = 5300
	PuzzleState.level_performance.leftover_score = 400
	PuzzleState.level_performance.score = 10800
	var rank := _rank_calculator.calculate_rank()
	assert_eq(rank.speed_rank, 0.0)
	assert_eq(rank.lines_rank, 0.0)
	assert_eq(rank.box_score_per_line_rank, 0.0)
	assert_eq(rank.combo_score_per_line_rank, 0.0)
	assert_eq(rank.score_rank, 0.0)


func test_calculate_rank_marathon_300_mixed() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300)
	PuzzleState.level_performance.seconds = 240
	PuzzleState.level_performance.lines = 60
	PuzzleState.level_performance.box_score = 600
	PuzzleState.level_performance.combo_score = 500
	PuzzleState.level_performance.score = 1160
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "S+")
	assert_eq(RankCalculator.grade(rank.lines_rank), "A+")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "S+")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "S-")
	assert_eq(RankCalculator.grade(rank.score_rank), "AA+")


func test_calculate_rank_marathon_lenient() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300, 200)
	PuzzleState.level_performance.seconds = 240
	PuzzleState.level_performance.lines = 60
	PuzzleState.level_performance.box_score = 600
	PuzzleState.level_performance.combo_score = 500
	PuzzleState.level_performance.score = 1160
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "S+")
	assert_eq(RankCalculator.grade(rank.lines_rank), "AA+")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "S+")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "S-")
	assert_eq(RankCalculator.grade(rank.score_rank), "AA+")


func test_calculate_rank_marathon_300_fail() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300)
	PuzzleState.level_performance.seconds = 0
	PuzzleState.level_performance.lines = 0
	PuzzleState.level_performance.box_score = 0
	PuzzleState.level_performance.combo_score = 0
	PuzzleState.level_performance.score = 0
	var rank := _rank_calculator.calculate_rank()
	assert_eq(rank.speed_rank, 999.0)
	assert_eq(rank.lines_rank, 999.0)
	assert_eq(rank.box_score_per_line_rank, 999.0)
	assert_eq(rank.combo_score_per_line_rank, 999.0)
	assert_eq(rank.score_rank, 999.0)


func test_calculate_rank_40_pieces() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 80)
	PuzzleState.level_performance.pieces = 40
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.pieces_rank), "S+")


func test_calculate_rank_1_piece() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.PIECES, 1)
	PuzzleState.level_performance.pieces = 0
	var rank := _rank_calculator.calculate_rank()
	# most importantly, this should avoid a divide-by-zero error
	assert_eq(RankCalculator.grade(rank.pieces_rank), "-")


func test_calculate_rank_sprint_120_top_out() -> void:
	CurrentLevel.settings.speed.set_start_speed("A0")
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 120)
	PuzzleState.level_performance.seconds = 120
	PuzzleState.level_performance.lines = 47
	PuzzleState.level_performance.box_score = 395
	PuzzleState.level_performance.combo_score = 570
	PuzzleState.level_performance.score = 1012
	
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.speed_rank), "SS+")
	assert_eq(RankCalculator.grade(rank1.lines_rank), "SS+")
	assert_eq(RankCalculator.grade(rank1.box_score_per_line_rank), "S")
	assert_eq(RankCalculator.grade(rank1.combo_score_per_line_rank), "SS")
	assert_eq(RankCalculator.grade(rank1.score_rank), "S+")
	
	# even when topping out, ranks stay the same
	PuzzleState.level_performance.top_out_count = 1
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.speed_rank), "SS+")
	assert_eq(RankCalculator.grade(rank2.lines_rank), "SS+")
	assert_eq(RankCalculator.grade(rank2.box_score_per_line_rank), "S")
	assert_eq(RankCalculator.grade(rank2.combo_score_per_line_rank), "SS")
	assert_eq(RankCalculator.grade(rank2.score_rank), "S+")


func test_calculate_rank_ultra_200() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	PuzzleState.level_performance.seconds = 20.233
	PuzzleState.level_performance.lines = 8
	PuzzleState.level_performance.box_score = 135
	PuzzleState.level_performance.combo_score = 60
	PuzzleState.level_performance.score = 8
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "SS+")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "M")
	assert_eq(rank.combo_score_per_line, 20.0)
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "M")
	assert_eq(RankCalculator.grade(rank.seconds_rank), "SS+")


## This is an edge case where, if the player clears too many lines for ultra, they can sort of be robbed of a master
## rank. But, they should try to clear fewer lines.
func test_calculate_rank_ultra_200_overshot() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	PuzzleState.level_performance.seconds = 19
	PuzzleState.level_performance.lines = 10
	PuzzleState.level_performance.box_score = 150
	PuzzleState.level_performance.combo_score = 100
	PuzzleState.level_performance.score = 260
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.speed_rank), "M")
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "M")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "M")
	assert_eq(RankCalculator.grade(rank.seconds_rank), "SSS")


## A level requiring only one line clear used to trigger divide by zero errors.
func test_calculate_rank_ultra_1() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1)
	PuzzleState.level_performance.seconds = 7.233
	PuzzleState.level_performance.lines = 1
	PuzzleState.level_performance.score = 1
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.seconds_rank), "AA")


func test_calculate_rank_five_creatures() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 5)
	CurrentLevel.settings.speed.set_start_speed("4")
	
	# good score
	PuzzleState.level_performance.lines = 100
	PuzzleState.level_performance.box_score = 1025
	PuzzleState.level_performance.combo_score = 915
	PuzzleState.level_performance.score = 2040
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.lines_rank), "SSS")
	assert_eq(RankCalculator.grade(rank1.box_score_per_line_rank), "S+")
	assert_eq(RankCalculator.grade(rank1.combo_score_per_line_rank), "S")
	assert_eq(RankCalculator.grade(rank1.score_rank), "SS")
	
	# bad score
	PuzzleState.level_performance.lines = 18
	PuzzleState.level_performance.box_score = 90
	PuzzleState.level_performance.combo_score = 60
	PuzzleState.level_performance.score = 168
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.lines_rank), "A-")
	assert_eq(RankCalculator.grade(rank2.box_score_per_line_rank), "AA")
	assert_eq(RankCalculator.grade(rank2.combo_score_per_line_rank), "A")
	assert_eq(RankCalculator.grade(rank2.score_rank), "A+")


## This edge case used to result in a combo_score_per_line of 22.5
func test_combo_score_per_line_ultra_overshot() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	PuzzleState.level_performance.combo_score = 45
	PuzzleState.level_performance.lines = 7
	var rank := _rank_calculator.calculate_rank()
	assert_eq(rank.combo_score_per_line, 20.0)


## This edge case used to result in a combo_score_per_line of 0.305
func test_combo_score_per_line_death() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 200, 150)
	PuzzleState.level_performance.combo_score = 195
	PuzzleState.level_performance.lines = 37
	PuzzleState.level_performance.top_out_count = 1
	var rank := _rank_calculator.calculate_rank()
	assert_almost_eq(rank.combo_score_per_line, 6.09, 0.1)


## A player reaching a success condition should be given a rank boost.
func test_success_bonus_score() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 300, 200)
	PuzzleState.level_performance.seconds = 240
	PuzzleState.level_performance.score = 1160
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
	PuzzleState.level_performance.seconds = 240
	PuzzleState.level_performance.score = 1160
	CurrentLevel.settings.rank.success_bonus = 8
	
	# the player doesn't achieve the success condition; they get a worse grade
	CurrentLevel.settings.set_success_condition(Milestone.TIME_UNDER, 180)
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.seconds_rank), "S-")

	# the player achieves the success condition; they get a better grade
	CurrentLevel.settings.set_success_condition(Milestone.TIME_UNDER, 300)
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.seconds_rank), "S+")


func test_customer_combo() -> void:
	CurrentLevel.settings.rank.customer_combo = 8
	CurrentLevel.settings.rank.leftover_lines = 3
	CurrentLevel.settings.set_finish_condition(Milestone.CUSTOMERS, 1)
	PuzzleState.level_performance.score = 296
	
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
	PuzzleState.level_performance.lost = true
	
	# the player lost the level; they get the worst rank
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.seconds_rank), "-")
	assert_eq(RankCalculator.grade(rank.score_rank), "-")


func test_extra_seconds_per_piece() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 180)
	PuzzleState.level_performance.seconds = 180
	PuzzleState.level_performance.lines = 60
	PuzzleState.level_performance.score = 1160
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.speed_rank), "SS+")
	assert_eq(RankCalculator.grade(rank1.score_rank), "S")
	
	# with the 'extra_seconds_per_piece' setting enabled, the player gets a better grade
	CurrentLevel.settings.rank.extra_seconds_per_piece = 1.2
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.speed_rank), "M")
	assert_eq(RankCalculator.grade(rank2.score_rank), "SS")


func test_box_factor_zero() -> void:
	PuzzleState.level_performance.lines = 100
	PuzzleState.level_performance.box_score = 440
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.box_score_per_line_rank), "A+")
	
	CurrentLevel.settings.rank.box_factor = 0.0
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.box_score_per_line_rank), "M")


func test_combo_factor_zero() -> void:
	PuzzleState.level_performance.lines = 100
	PuzzleState.level_performance.combo_score = 550
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.combo_score_per_line_rank), "A+")
	
	CurrentLevel.settings.rank.combo_factor = 0.0
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.combo_score_per_line_rank), "M")


func test_master_pickup_score() -> void:
	PuzzleState.level_performance.pickup_score = 100
	CurrentLevel.settings.rank.master_pickup_score = 100
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.pickup_score_rank), "M")

	CurrentLevel.settings.rank.master_pickup_score = 200
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.pickup_score_rank), "AA")


func test_master_pickup_score_per_line() -> void:
	PuzzleState.level_performance.lines = 100
	PuzzleState.level_performance.pickup_score = 1000
	CurrentLevel.settings.rank.master_pickup_score_per_line = 10
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.pickup_score_rank), "M")

	CurrentLevel.settings.rank.master_pickup_score_per_line = 20
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.pickup_score_rank), "S-")


func test_avoid_infinite_ranks() -> void:
	PuzzleState.level_performance.lines = 0
	PuzzleState.level_performance.pickup_score = 0
	
	CurrentLevel.settings.rank.master_pickup_score_per_line = 0
	CurrentLevel.settings.rank.master_pickup_score = 10
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(rank1.pickup_score_rank, 999.0)
	
	CurrentLevel.settings.rank.master_pickup_score = 0
	CurrentLevel.settings.rank.master_pickup_score_per_line = 10
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(rank2.pickup_score_rank, 999.0)


func test_very_short_level() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 10)
	
	PuzzleState.level_performance.leftover_score = 257
	PuzzleState.level_performance.score = 257
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.score_rank), "S+")
	
	PuzzleState.level_performance.leftover_score = 467
	PuzzleState.level_performance.score = 467
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.score_rank), "SSS")


func test_preplaced_pieces_ultra() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	
	# 17 seconds is very fast for scoring 200 points.
	PuzzleState.level_performance.seconds = 17
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.seconds_rank), "M")
	
	# 17 seconds isn't as impressive if the playfield starts with pieces on it.
	CurrentLevel.settings.rank.preplaced_pieces = 5
	PuzzleState.level_performance.seconds = 17
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.seconds_rank), "S+")
	
	# 11 seconds is required, because some pieces are preplaced
	CurrentLevel.settings.rank.preplaced_pieces = 5
	PuzzleState.level_performance.seconds = 11
	var rank3 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank3.seconds_rank), "M")


func test_preplaced_pieces_sprint() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 17)
	
	# 650 points is a lot in 17 seconds.
	PuzzleState.level_performance.score = 650
	var rank1 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank1.score_rank), "M")
	
	# 650 points isn't as impressive if the playfield starts with pieces on it.
	CurrentLevel.settings.rank.preplaced_pieces = 5
	PuzzleState.level_performance.score = 650
	var rank2 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank2.score_rank), "SSS")
	
	# 700 points are required, because some pieces are preplaced
	CurrentLevel.settings.rank.preplaced_pieces = 5
	PuzzleState.level_performance.score = 700
	var rank3 := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank3.score_rank), "M")


func test_target_leftover_score_low_combo_factor() -> void:
	assert_almost_eq(_rank_calculator.target_leftover_score(12), 426.0, 10.0)
	
	# with a combo factor of 0, the leftover score should be 100 less
	CurrentLevel.settings.rank.combo_factor = 0.00
	assert_almost_eq(_rank_calculator.target_leftover_score(12), 326.0, 10.0)


func test_master_leftover_lines_veggie() -> void:
	assert_eq(_rank_calculator.master_leftover_lines(CurrentLevel.settings), 12)
	
	# it's impossible to have leftovers if you can't make boxes
	CurrentLevel.settings.other.tile_set = PuzzleTileMap.TileSetType.VEGGIE
	assert_eq(_rank_calculator.master_leftover_lines(CurrentLevel.settings), 0)


func test_target_lines_for_score() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1)
	assert_eq(1, _rank_calculator.target_lines_for_score(15.0, 15.0))
	
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 20)
	assert_eq(2, _rank_calculator.target_lines_for_score(15.0, 15.0))
	
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 100)
	assert_eq(6, _rank_calculator.target_lines_for_score(15.0, 15.0))
	
	# 20 points per line -- should take a little more than 50 lines because of the time for the combo to ramp up
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	assert_eq(53, _rank_calculator.target_lines_for_score(10.0, 9.0))


## Duplicating a bug where line-based levels would always award SSS rank instead of M rank
func test_calculate_rank_lines_m() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 10)
	CurrentLevel.settings.rank.master_pickup_score = 100
	
	PuzzleState.level_performance.box_score = 200
	PuzzleState.level_performance.combo_score = 120
	PuzzleState.level_performance.pickup_score = 100
	PuzzleState.level_performance.lines = 11
	PuzzleState.level_performance.leftover_score = 515
	PuzzleState.level_performance.score = 946
	
	var rank := _rank_calculator.calculate_rank()
	assert_eq(RankCalculator.grade(rank.box_score_per_line_rank), "M")
	assert_eq(RankCalculator.grade(rank.combo_score_per_line_rank), "M")
	assert_eq(RankCalculator.grade(rank.pickup_score_rank), "M")
	assert_eq(RankCalculator.grade(rank.lines_rank), "M")
	assert_eq(RankCalculator.grade(rank.score_rank), "M")


func test_next_grade() -> void:
	assert_eq(RankCalculator.next_grade(RankCalculator.NO_GRADE), "B-")
	assert_eq(RankCalculator.next_grade("B-"), "B")
	assert_eq(RankCalculator.next_grade("AA+"), "S-")
	assert_eq(RankCalculator.next_grade("SSS"), "M")
	assert_eq(RankCalculator.next_grade("M"), "M")
	assert_eq(RankCalculator.next_grade("crazy-giants"), RankCalculator.NO_GRADE)
