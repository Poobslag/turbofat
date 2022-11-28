extends "res://addons/gut/test.gd"

func before_each() -> void:
	SystemData.gameplay_settings.reset()


func after_all() -> void:
	SystemData.gameplay_settings.reset()


func test_adjust_line_milestone() -> void:
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.DEFAULT
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(50), 50)
	
	# slowing down gameplay speed decreases lines required
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOW
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(50), 42)
	
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWER
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(50), 35)
	
	# lines required won't decrease below a certain threshold (1 line)
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWESTEST
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(3), 1)
	
	# increasing gameplay speed does not affect milestones
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.FASTER
	assert_eq(GameplayDifficultyAdjustments.adjust_line_milestone(50), 50)


func test_adjust_piece_milestone() -> void:
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.DEFAULT
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(50), 50)
	
	# slowing down gameplay speed decreases pieces required
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOW
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(50), 42)
	
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWER
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(50), 35)
	
	# pieces required won't decrease below a certain threshold (1 piece)
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWESTEST
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(3), 1)
	
	# increasing gameplay speed does not affect milestones
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.FASTER
	assert_eq(GameplayDifficultyAdjustments.adjust_piece_milestone(50), 50)


func test_adjust_score_milestone() -> void:
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.DEFAULT
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(500), 500)
	
	# slowing down gameplay speed decreases score required
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOW
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(500), 350)
	
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWER
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(500), 200)
	
	# score required won't decrease below a certain threshold (¥1)
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWESTEST
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(3), 1)
	
	# increasing gameplay speed does not affect milestones
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.FASTER
	assert_eq(GameplayDifficultyAdjustments.adjust_score_milestone(500), 500)


func test_adjust_time_over_milestone() -> void:
	# 'slow' and 'default' gameplay speeds do not affect level duration
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.DEFAULT
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 180)
	
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOW
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 180)
	
	# decreasing gameplay speed beyond 'slow' decreases level duration
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWER
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 162)
	
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWEST
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 125)
	
	# level duration won't decrease below a certain threshold (0:01)
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.SLOWESTEST
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(3), 1)
	
	# increasing gameplay speed does not affect milestones
	SystemData.gameplay_settings.speed = GameplaySettings.Speed.FASTER
	assert_eq(GameplayDifficultyAdjustments.adjust_time_over_milestone(180), 180)
