extends GutTest

var _rank_target_calculator := RankTargetCalculator.new()

func before_each() -> void:
	CurrentLevel.settings = LevelSettings.new()
	PuzzleState.level_performance = PuzzlePerformance.new()


func test_target_for_rank_score() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)
	
	var expected_target := 181
	assert_eq(expected_target, _rank_target_calculator.target_for_rank(20))
	
	var rank_calculator := RankCalculator.new()
	
	PuzzleState.level_performance.seconds = expected_target
	assert_true(rank_calculator.calculate_rank().seconds_rank <= 20.0)
	assert_almost_eq(rank_calculator.calculate_rank().seconds_rank, 20.0, 0.1)
	
	PuzzleState.level_performance.seconds = expected_target + 1
	assert_gt(rank_calculator.calculate_rank().seconds_rank, 20.0)
	assert_almost_eq(rank_calculator.calculate_rank().seconds_rank, 20.0, 0.1)


func test_target_for_rank_time() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 150)
	
	var expected_target := 847
	assert_eq(expected_target, _rank_target_calculator.target_for_rank(20))
	
	var rank_calculator := RankCalculator.new()
	
	PuzzleState.level_performance.score = expected_target
	assert_true(rank_calculator.calculate_rank().score_rank <= 20)
	assert_almost_eq(rank_calculator.calculate_rank().score_rank, 20.0, 0.1)
	
	PuzzleState.level_performance.score = expected_target - 1
	assert_gt(rank_calculator.calculate_rank().score_rank, 20.0)
	assert_almost_eq(rank_calculator.calculate_rank().score_rank, 20.0, 0.1)


func test_target_for_grade_score() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1000)

	assert_eq(8815, _rank_target_calculator.target_for_grade("B-"))
	assert_eq(2195, _rank_target_calculator.target_for_grade("A-"))
	assert_eq(260, _rank_target_calculator.target_for_grade("S-"))
	
	var expected_target := 260
	assert_eq(expected_target, _rank_target_calculator.target_for_grade("S-"))
	
	var rank_calculator := RankCalculator.new()
	
	PuzzleState.level_performance.seconds = expected_target
	assert_eq(rank_calculator.grade(rank_calculator.calculate_rank().seconds_rank), "S-")
	
	PuzzleState.level_performance.seconds = expected_target + 1
	assert_eq(rank_calculator.grade(rank_calculator.calculate_rank().seconds_rank), "AA+")


func test_target_for_grade_ignores_lost() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1800)
	assert_eq(321, _rank_target_calculator.target_for_grade("S"))
	
	PuzzleState.level_performance.lost = true
	
	CurrentLevel.settings.set_finish_condition(Milestone.SCORE, 1800)
	assert_eq(321, _rank_target_calculator.target_for_grade("S"))


func test_target_for_grade_time() -> void:
	CurrentLevel.settings.set_finish_condition(Milestone.TIME_OVER, 150)
	
	var expected_target := 553
	assert_eq(expected_target, _rank_target_calculator.target_for_grade("S-"))
	
	var rank_calculator := RankCalculator.new()
	
	PuzzleState.level_performance.score = expected_target
	assert_eq(rank_calculator.grade(rank_calculator.calculate_rank().score_rank), "S-")
	
	PuzzleState.level_performance.score = expected_target - 1
	assert_eq(rank_calculator.grade(rank_calculator.calculate_rank().score_rank), "AA+")
