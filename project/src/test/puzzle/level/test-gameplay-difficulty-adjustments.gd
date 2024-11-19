extends GutTest

func before_each() -> void:
	PlayerData.difficulty.reset()


func after_all() -> void:
	PlayerData.difficulty.reset()


func test_adjust_line_milestone() -> void:
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(50), 50)
	
	# slowing down gameplay speed decreases lines required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(50), 43)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(50), 35)
	
	# lines required won't decrease below a certain threshold (1 line)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(3), 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(50), 50)


func test_adjust_piece_milestone() -> void:
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(50), 50)
	
	# slowing down gameplay speed decreases pieces required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(50), 43)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(50), 35)
	
	# pieces required won't decrease below a certain threshold (1 piece)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(3), 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(50), 50)


func test_adjust_score_milestone() -> void:
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(500), 500)
	
	# slowing down gameplay speed decreases score required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(500), 350)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(500), 200)
	
	# score required won't decrease below a certain threshold (¥1)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(3), 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(500), 500)


func test_adjust_time_over_milestone() -> void:
	# 'slow' and 'default' gameplay speeds do not affect level duration
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 180)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 180)
	
	# decreasing gameplay speed beyond 'slow' decreases level duration
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 162)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWEST
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 126)
	
	# level duration won't decrease below a certain threshold (0:01)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(3), 2)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 180)
