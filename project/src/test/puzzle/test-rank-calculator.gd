extends GutTest

var _rank_calculator := RankCalculator.new()

func before_each() -> void:
	CurrentLevel.settings = LevelSettings.new()
	PuzzleState.level_performance = PuzzlePerformance.new()


func test_filled_rank_criteria_marathon() -> void:
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1000)
	var rank_criteria := _rank_calculator.filled_rank_criteria()
	
	assert_eq(rank_criteria.thresholds_by_grade.get("M"), 1000)
	assert_eq(rank_criteria.thresholds_by_grade.get("SSS"), 850)
	assert_eq(rank_criteria.thresholds_by_grade.get("SS"), 690)
	assert_eq(rank_criteria.thresholds_by_grade.get("S-"), 215)


func test_filled_rank_criteria_marathon_with_s() -> void:
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1000)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("S-", 900)
	var rank_criteria := _rank_calculator.filled_rank_criteria()
	
	assert_eq(rank_criteria.thresholds_by_grade.get("M"), 1000)
	assert_eq(rank_criteria.thresholds_by_grade.get("SSS"), 980)
	assert_eq(rank_criteria.thresholds_by_grade.get("SS"), 960)
	assert_eq(rank_criteria.thresholds_by_grade.get("S-"), 900)


func test_filled_rank_criteria_ultra() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 2000)
	CurrentLevel.settings.rank.rank_criteria.duration_criteria = true
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 110)
	var rank_criteria := _rank_calculator.filled_rank_criteria()
	
	assert_eq(rank_criteria.thresholds_by_grade.get("M"), 110)
	assert_eq(rank_criteria.thresholds_by_grade.get("SSS"), 130)
	assert_eq(rank_criteria.thresholds_by_grade.get("SS"), 160)
	assert_eq(rank_criteria.thresholds_by_grade.get("S-"), 510)
	assert_eq(rank_criteria.thresholds_by_grade.get("B-"), 3599)


func test_filled_rank_criteria_ultra_with_s() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 2000)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 110)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("S-", 200)
	var rank_criteria := _rank_calculator.filled_rank_criteria()
	
	assert_eq(rank_criteria.thresholds_by_grade.get("M"), 110)
	assert_eq(rank_criteria.thresholds_by_grade.get("SSS"), 115)
	assert_eq(rank_criteria.thresholds_by_grade.get("SS"), 125)


func test_filled_rank_criteria_sprint_short() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 5)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 50)
	var rank_criteria := _rank_calculator.filled_rank_criteria()
	
	# Score criteria can be identical; some grades are impossible. Score criteria can be low but should never be zero.
	assert_eq(rank_criteria.thresholds_by_grade.get("B+"), 1)
	assert_eq(rank_criteria.thresholds_by_grade.get("B"), 1)
	assert_eq(rank_criteria.thresholds_by_grade.get("B-"), 1)


func test_filled_rank_criteria_ultra_short() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 2)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 4)
	var rank_criteria := _rank_calculator.filled_rank_criteria()
	
	# Score criteria can be identical, some grades are impossible.
	assert_eq(rank_criteria.thresholds_by_grade.get("SS+"), 5)
	assert_eq(rank_criteria.thresholds_by_grade.get("SS"), 5)


func test_calculate_rank_marathon_hard() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 200)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 6939)
	PuzzleState.level_performance.score = 2200
	var rank_result := _rank_calculator.calculate_rank()

	assert_eq(19.2, rank_result.rank)


func test_calculate_rank_marathon_zero_lines() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 10)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 345)
	PuzzleState.level_performance.score = 0
	var rank_result := _rank_calculator.calculate_rank()

	assert_eq(999.0, rank_result.rank)


func test_calculate_rank_marathon_hard_master() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.LINES, 200)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 6939)
	PuzzleState.level_performance.score = 7700
	var rank_result := _rank_calculator.calculate_rank()

	assert_eq(0.0, rank_result.rank)


func test_calculate_rank_ultra_hard() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 44)
	PuzzleState.level_performance.seconds = 74
	var rank_result := _rank_calculator.calculate_rank()

	assert_eq(11.2, rank_result.rank)


func test_calculate_rank_ultra_hard_timeout() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 44)
	PuzzleState.level_performance.seconds = 9999
	var rank_result := _rank_calculator.calculate_rank()

	assert_eq(999.0, rank_result.rank)


func test_calculate_rank_ultra_hard_master() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 44)
	PuzzleState.level_performance.seconds = 34
	var rank_result := _rank_calculator.calculate_rank()

	assert_eq(0.0, rank_result.rank)


func test_calculate_rank_ultra_fail() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 200)
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 44)
	PuzzleState.level_performance.seconds = 34
	PuzzleState.level_performance.lost = true
	var rank_result := _rank_calculator.calculate_rank()

	assert_eq(999.0, rank_result.rank)


func test_unranked() -> void:
	CurrentLevel.settings.rank.unranked = true
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1)
	var rank_result := _rank_calculator.calculate_rank()
	
	# the player finishes the level; they automatically get a master rank
	assert_eq(0.0, rank_result.rank)


func test_unranked_loss() -> void:
	CurrentLevel.settings.rank.unranked = true
	PuzzleState.level_performance.lost = true
	CurrentLevel.settings.rank.rank_criteria.add_threshold("TOP", 1)
	var rank_result := _rank_calculator.calculate_rank()
	
	# the player lost the level; they get the worst rank
	assert_eq(999.0, rank_result.rank)
