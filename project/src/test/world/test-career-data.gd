extends "res://addons/gut/test.gd"

const TEMP_PLAYER_FILENAME := "test997.save"

var _data: CareerData

func before_each() -> void:
	_data = CareerData.new()
	
	CareerLevelLibrary.worlds_path = "res://assets/test/ui/level-select/career-worlds.json"
	PlayerSave.data_filename = "user://%s" % TEMP_PLAYER_FILENAME
	PlayerData.reset()

func test_prev_daily_earnings() -> void:
	for i in range(10, 100):
		_data.daily_earnings = i
		_data.advance_calendar()
	
	assert_eq(_data.prev_daily_earnings.size(), CareerData.MAX_DAILY_HISTORY)
	assert_eq(99, _data.prev_daily_earnings[0])
	assert_eq(60, _data.prev_daily_earnings[CareerData.MAX_DAILY_HISTORY - 1])


func test_advance_distance_stops_at_boss_level_0() -> void:
	_data.advance_distance(50, false)
	assert_eq(_data.distance_earned, 50)
	assert_eq(_data.distance_travelled, 9)


func test_advance_distance_stops_at_boss_level_1() -> void:
	_data.distance_travelled = 8 # just before a boss level
	_data.advance_distance(3, true)
	assert_eq(_data.distance_earned, 3)
	assert_eq(_data.distance_travelled, 9)


## The player skips one boss level, but gets stopped by the next boss level
func test_advance_distance_skips_boss_level() -> void:
	PlayerData.career.max_distance_travelled = 10
	_data.advance_distance(50, false)
	assert_eq(_data.distance_earned, 50)
	assert_eq(_data.distance_travelled, 24)


func test_advance_distance_clears_boss_level() -> void:
	_data.distance_travelled = 9 # boss level
	_data.advance_distance(4, true)
	assert_eq(_data.distance_earned, 4)
	assert_eq(_data.distance_travelled, 13)


func test_advance_distance_fails_boss_level() -> void:
	_data.distance_travelled = 9 # boss level
	_data.advance_distance(4, false)
	assert_true(_data.distance_earned < 0,
			"distance_earned should be less than 0 but was %s" % [_data.distance_earned])
	assert_true(_data.distance_travelled < 9,
			"distance_travelled should be less than 9 but was %s" % [_data.distance_travelled])
