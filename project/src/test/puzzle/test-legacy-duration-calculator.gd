extends GutTest

var _duration_calculator := LegacyDurationCalculator.new()
var _settings: LevelSettings

func before_each() -> void:
	_settings = LevelSettings.new()


func test_endless_level() -> void:
	assert_almost_eq(_duration_calculator.duration(_settings), 600.0, 10.0)


func test_score_high_target() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 200) # low target
	assert_almost_eq(_duration_calculator.duration(_settings), 177.0, 10.0)
	
	_settings.finish_condition.set_milestone(Milestone.SCORE, 1000) # high target
	assert_almost_eq(_duration_calculator.duration(_settings), 889.0, 10.0)


func test_score_high_speed() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 200)
	
	_settings.speed.set_start_speed("0") # low speed
	assert_almost_eq(_duration_calculator.duration(_settings), 178.0, 10.0)
	
	_settings.speed.set_start_speed("AA") # high speed
	assert_almost_eq(_duration_calculator.duration(_settings), 30.0, 10.0)


func test_lines_high_target() -> void:
	_settings.finish_condition.set_milestone(Milestone.LINES, 20) # low value
	assert_almost_eq(_duration_calculator.duration(_settings), 150.0, 10.0)
	
	_settings.finish_condition.set_milestone(Milestone.LINES, 100) # high value
	assert_almost_eq(_duration_calculator.duration(_settings), 750.0, 10.0)


func test_lines_high_speed() -> void:
	_settings.finish_condition.set_milestone(Milestone.LINES, 20)
	
	_settings.speed.set_start_speed("0") # low speed
	assert_almost_eq(_duration_calculator.duration(_settings), 150.0, 10.0)
	
	_settings.speed.set_start_speed("AA") # high speed
	assert_almost_eq(_duration_calculator.duration(_settings), 70.0, 10.0)


func test_time_over_high_target() -> void:
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 90.0)
	assert_eq(_duration_calculator.duration(_settings), 90.0) # low target
	
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 300.0)
	assert_eq(_duration_calculator.duration(_settings), 300.0) # high target


func test_time_over_high_speed() -> void:
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 90.0)
	
	_settings.speed.set_start_speed("0") # low speed
	assert_eq(_duration_calculator.duration(_settings), 90.0)
	
	_settings.speed.set_start_speed("AA") # high speed
	assert_eq(_duration_calculator.duration(_settings), 90.0)


func test_customers_high_target() -> void:
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 5) # low target
	assert_almost_eq(_duration_calculator.duration(_settings), 113.0, 10.0)
	
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 25) # high target
	assert_almost_eq(_duration_calculator.duration(_settings), 562.5, 10.0)


func test_customers_high_speed() -> void:
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 5)
	
	_settings.speed.set_start_speed("0") # low speed
	assert_almost_eq(_duration_calculator.duration(_settings), 112.0, 10.0)
	
	_settings.speed.set_start_speed("AA") # high speed
	assert_almost_eq(_duration_calculator.duration(_settings), 230.0, 10.0)


func test_master_pickup_score() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 1000)
	
	_settings.rank.legacy_rules["master_pickup_score"] = 0 # low pickup score
	assert_almost_eq(_duration_calculator.duration(_settings), 889.0, 10.0)
	
	_settings.rank.legacy_rules["master_pickup_score"] = 800 # high pickup score
	assert_almost_eq(_duration_calculator.duration(_settings), 177.0, 10.0)


func test_master_pickup_score_per_line() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 1000)
	
	_settings.rank.legacy_rules["master_pickup_score_per_line"] = 0 # low pickup score
	assert_almost_eq(_duration_calculator.duration(_settings), 889.0, 10.0)
	
	_settings.rank.legacy_rules["master_pickup_score_per_line"] = 20 # high pickup score
	assert_almost_eq(_duration_calculator.duration(_settings), 574.0, 10.0)
