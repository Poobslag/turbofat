extends GutTest

var settings: LevelSettings
var default_finish_condition: Milestone = Milestone.new()

func before_each() -> void:
	settings = LevelSettings.new()
	PlayerData.difficulty.reset()


func after_all() -> void:
	PlayerData.difficulty.reset()


func adjust_milestones() -> void:
	settings.finish_condition.set_milestone(default_finish_condition.type, default_finish_condition.value)
	GameplayDifficultyAdjustments.adjust_milestones(settings)


func test_adjust_line_milestone() -> void:
	default_finish_condition.set_milestone(Milestone.LINES, 50)
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 50)
	
	# slowing down gameplay speed decreases lines required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 43)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 35)
	
	# lines required won't decrease below a certain threshold (1 line)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	default_finish_condition.set_milestone(Milestone.LINES, 3)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	default_finish_condition.set_milestone(Milestone.LINES, 50)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 50)


func test_adjust_piece_milestone() -> void:
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	default_finish_condition.set_milestone(Milestone.PIECES, 50)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 50)
	
	# slowing down gameplay speed decreases pieces required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 43)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 35)
	
	# pieces required won't decrease below a certain threshold (1 piece)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	default_finish_condition.set_milestone(Milestone.PIECES, 3)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	default_finish_condition.set_milestone(Milestone.PIECES, 50)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 50)


func test_adjust_score_milestone() -> void:
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	default_finish_condition.set_milestone(Milestone.SCORE, 500)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 500)
	
	# slowing down gameplay speed decreases score required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 350)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 200)
	
	# score required won't decrease below a certain threshold (¥1)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	default_finish_condition.set_milestone(Milestone.SCORE, 3)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	default_finish_condition.set_milestone(Milestone.SCORE, 500)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 500)


func test_adjust_time_over_milestone() -> void:
	# 'slow' and 'default' gameplay speeds do not affect level duration
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	default_finish_condition.set_milestone(Milestone.TIME_OVER, 180)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 180)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 180)
	
	# decreasing gameplay speed beyond 'slow' decreases level duration
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 162)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWEST
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 126)
	
	# level duration won't decrease below a certain threshold (0:01)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	default_finish_condition.set_milestone(Milestone.TIME_OVER, 3)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 2)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	default_finish_condition.set_milestone(Milestone.TIME_OVER, 180)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 180)
