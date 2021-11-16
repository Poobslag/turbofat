extends "res://addons/gut/test.gd"

var _data: CareerData

func before_each() -> void:
	_data = CareerData.new()


func test_it() -> void:
	for i in range(10, 100):
		_data.daily_earnings = i
		_data.advance_calendar()
	
	assert_eq(_data.prev_daily_earnings.size(), CareerData.MAX_DAILY_HISTORY)
	assert_eq(99, _data.prev_daily_earnings[0])
	assert_eq(60, _data.prev_daily_earnings[CareerData.MAX_DAILY_HISTORY - 1])
