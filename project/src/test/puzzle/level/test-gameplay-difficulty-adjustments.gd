extends GutTest

var settings: LevelSettings
var default_finish_condition: Milestone = Milestone.new()
var default_success_condition: Milestone = Milestone.new()

func before_each() -> void:
	settings = LevelSettings.new()
	PlayerData.difficulty.reset()


func after_all() -> void:
	PlayerData.difficulty.reset()


func adjust_milestones() -> void:
	settings.finish_condition.set_milestone(default_finish_condition.type, default_finish_condition.value)
	settings.success_condition.set_milestone(default_success_condition.type, default_success_condition.value)
	GameplayDifficultyAdjustments.adjust_milestones(settings)


func test_adjust_line_milestone() -> void:
	default_finish_condition.set_milestone(Milestone.LINES, 50)
	default_success_condition.set_milestone(Milestone.SCORE, 250)
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 50)
	assert_eq(settings.success_condition.value, 250)
	
	# slowing down gameplay speed decreases lines required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 43)
	assert_eq(settings.success_condition.value, 149)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 35)
	assert_eq(settings.success_condition.value, 70)
	
	# lines required won't decrease below a certain threshold (1 line)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	default_finish_condition.set_milestone(Milestone.LINES, 3)
	default_success_condition.set_milestone(Milestone.SCORE, 10)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 1)
	assert_eq(settings.success_condition.value, 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	default_finish_condition.set_milestone(Milestone.LINES, 50)
	default_success_condition.set_milestone(Milestone.SCORE, 250)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 50)
	assert_eq(settings.success_condition.value, 250)


func test_adjust_piece_milestone() -> void:
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	default_finish_condition.set_milestone(Milestone.PIECES, 50)
	default_success_condition.set_milestone(Milestone.SCORE, 250)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 50)
	assert_eq(settings.success_condition.value, 250)
	
	# slowing down gameplay speed decreases pieces required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 43)
	assert_eq(settings.success_condition.value, 149)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 35)
	assert_eq(settings.success_condition.value, 70)
	
	# pieces required won't decrease below a certain threshold (1 piece)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	default_finish_condition.set_milestone(Milestone.PIECES, 3)
	default_success_condition.set_milestone(Milestone.SCORE, 15)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 1)
	assert_eq(settings.success_condition.value, 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	default_finish_condition.set_milestone(Milestone.PIECES, 50)
	default_success_condition.set_milestone(Milestone.SCORE, 250)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 50)
	assert_eq(settings.success_condition.value, 250)


func test_adjust_score_milestone() -> void:
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	default_finish_condition.set_milestone(Milestone.SCORE, 500)
	default_success_condition.set_milestone(Milestone.TIME_UNDER, 180)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 500)
	assert_eq(settings.success_condition.value, 180)
	
	# slowing down gameplay speed decreases score required
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 350)
	assert_eq(settings.success_condition.value, 177)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 200)
	assert_eq(settings.success_condition.value, 180)
	
	# score required won't decrease below a certain threshold (¥1)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	default_finish_condition.set_milestone(Milestone.SCORE, 3)
	default_success_condition.set_milestone(Milestone.TIME_UNDER, 1)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 1)
	assert_eq(settings.success_condition.value, 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	default_finish_condition.set_milestone(Milestone.SCORE, 500)
	default_success_condition.set_milestone(Milestone.TIME_UNDER, 180)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 500)
	assert_eq(settings.success_condition.value, 180)


func test_zen_boss_milestones() -> void:
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	# lemon
	default_finish_condition.set_milestone(Milestone.SCORE, 300)
	default_success_condition.set_milestone(Milestone.TIME_UNDER, 300)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 30)
	assert_eq(settings.success_condition.value, 300)
	
	# welcome
	default_finish_condition.set_milestone(Milestone.TIME_OVER, 180)
	default_success_condition.set_milestone(Milestone.SCORE, 400)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 72)
	assert_eq(settings.success_condition.value, 16)
	
	# poki
	default_finish_condition.set_milestone(Milestone.SCORE, 600)
	default_success_condition.set_milestone(Milestone.TIME_UNDER, 360)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 60)
	assert_eq(settings.success_condition.value, 360)
	
	# poki
	default_finish_condition.set_milestone(Milestone.TIME_OVER, 210)
	default_success_condition.set_milestone(Milestone.SCORE, 650)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 84)
	assert_eq(settings.success_condition.value, 26)
	
	# marsh
	default_finish_condition.set_milestone(Milestone.PIECES, 150)
	default_success_condition.set_milestone(Milestone.SCORE, 1000)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 30)
	assert_eq(settings.success_condition.value, 20)
	
	# lava
	default_finish_condition.set_milestone(Milestone.LINES, 120)
	default_success_condition.set_milestone(Milestone.SCORE, 2000)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 24)
	assert_eq(settings.success_condition.value, 40)


func test_adjust_time_over_milestone() -> void:
	# 'slow' and 'default' gameplay speeds do not affect level duration
	PlayerData.difficulty.speed = DifficultyData.Speed.DEFAULT
	default_finish_condition.set_milestone(Milestone.TIME_OVER, 180)
	default_success_condition.set_milestone(Milestone.SCORE, 500)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 180)
	assert_eq(settings.success_condition.value, 500)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOW
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 180)
	assert_eq(settings.success_condition.value, 350)
	
	# decreasing gameplay speed beyond 'slow' decreases level duration
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWER
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 162)
	assert_eq(settings.success_condition.value, 180)
	
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWEST
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 126)
	assert_eq(settings.success_condition.value, 70)
	
	# level duration won't decrease below a certain threshold (0:01)
	PlayerData.difficulty.speed = DifficultyData.Speed.SLOWESTEST
	default_finish_condition.set_milestone(Milestone.TIME_OVER, 3)
	default_success_condition.set_milestone(Milestone.SCORE, 10)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 2)
	assert_eq(settings.success_condition.value, 1)
	
	# increasing gameplay speed does not affect milestones
	PlayerData.difficulty.speed = DifficultyData.Speed.FASTER
	default_finish_condition.set_milestone(Milestone.TIME_OVER, 180)
	default_success_condition.set_milestone(Milestone.SCORE, 500)
	adjust_milestones()
	assert_eq(settings.finish_condition.value, 180)
	assert_eq(settings.success_condition.value, 500)
