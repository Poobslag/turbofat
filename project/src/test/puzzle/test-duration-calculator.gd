extends "res://addons/gut/test.gd"
"""
Unit test demonstrating duration calculation logic.
"""

var _duration_calculator := DurationCalculator.new()
var _settings := ScenarioSettings.new()

func before_each() -> void:
	_settings.reset()
	_settings.set_start_level("0")


func test_endless_level() -> void:
	assert_almost_eq(_duration_calculator.duration(_settings), 600.0, 10.0)


func test_score() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 200)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 177, 10)


func test_score_high_value() -> void:
	_settings.finish_condition.set_milestone(Milestone.SCORE, 1000)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 889, 10)


func test_score_high_difficulty() -> void:
	_settings.set_start_level("AA")
	_settings.finish_condition.set_milestone(Milestone.SCORE, 200)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 23, 10)


func test_lines() -> void:
	_settings.finish_condition.set_milestone(Milestone.LINES, 20)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 150, 10)


func test_lines_high_value() -> void:
	_settings.finish_condition.set_milestone(Milestone.LINES, 100)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 750, 10)


func test_lines_high_difficulty() -> void:
	_settings.set_start_level("AA")
	_settings.finish_condition.set_milestone(Milestone.LINES, 20)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 55, 10)


func test_time_over() -> void:
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 90.0)
	
	assert_eq(_duration_calculator.duration(_settings), 90.0)


func test_time_over_high_value() -> void:
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 300.0)
	
	assert_eq(_duration_calculator.duration(_settings), 300.0)


func test_time_over_high_difficulty() -> void:
	_settings.set_start_level("AA")
	_settings.finish_condition.set_milestone(Milestone.TIME_OVER, 90.0)
	
	assert_eq(_duration_calculator.duration(_settings), 90.0)


func test_customers() -> void:
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 5)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 116, 10)


func test_customers_high_value() -> void:
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 25)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 581, 10)


func test_customers_high_difficulty() -> void:
	_settings.set_start_level("AA")
	_settings.finish_condition.set_milestone(Milestone.CUSTOMERS, 5)
	
	assert_almost_eq(_duration_calculator.duration(_settings), 185, 10)
