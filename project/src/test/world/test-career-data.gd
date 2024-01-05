extends GutTest

const TEMP_PLAYER_FILENAME := "test997.save"

var _data: CareerData

func before_each() -> void:
	_data = CareerData.new()
	add_child(_data)
	
	CareerLevelLibrary.regions_path = "res://assets/test/career/career-regions-simple.json"
	PlayerSave.data_filename = "user://%s" % TEMP_PLAYER_FILENAME
	PlayerData.reset()
	
	PlayerData.level_history.add_result("intro_211", RankResult.new())
	PlayerData.level_history.add_result("intro_311", RankResult.new())
	PlayerData.level_history.add_result("intro_411", RankResult.new())
	_data.best_distance_travelled = Careers.MAX_DISTANCE_TRAVELLED


func after_each() -> void:
	## we use 'free' instead of 'queue_free' to avoid warnings from Gut about new orphans
	_data.free()


func test_prev_money() -> void:
	for i in range(10, 100):
		_data.money = i
		_data.advance_calendar()
	
	assert_eq(_data.prev_money.size(), Careers.MAX_DAILY_HISTORY)
	assert_eq(99, _data.prev_money[0])
	assert_eq(60, _data.prev_money[Careers.MAX_DAILY_HISTORY - 1])


func test_advance_clock_stops_at_boss_level_0() -> void:
	_data.best_distance_travelled = 0
	_data.advance_clock(50, false, false)
	assert_eq(_data.distance_earned, 50)
	assert_eq(_data.distance_travelled, 9)
	assert_eq(_data.banked_steps, 41)


func test_advance_clock_stops_at_boss_level_1() -> void:
	_data.best_distance_travelled = 0
	_data.distance_travelled = 8 # just before a boss level
	_data.advance_clock(3, true, false)
	assert_eq(_data.distance_earned, 3)
	assert_eq(_data.distance_travelled, 9)
	assert_eq(_data.banked_steps, 2)


func test_advance_clock_clears_boss_level() -> void:
	_data.best_distance_travelled = 0
	_data.distance_travelled = 9 # boss level
	_data.advance_clock(4, true, false)
	assert_eq(_data.distance_earned, 4)
	assert_eq(_data.distance_travelled, 10)
	assert_eq(_data.banked_steps, 3)


func test_advance_clock_fails_boss_level() -> void:
	_data.best_distance_travelled = 0
	_data.distance_travelled = 9 # boss level
	_data.advance_clock(4, false, false)
	assert_true(_data.distance_earned < 0,
			"distance_earned should be less than 0 but was %s" % [_data.distance_earned])
	assert_true(_data.distance_travelled < 9,
			"distance_travelled should be less than 9 but was %s" % [_data.distance_travelled])
	assert_eq(_data.banked_steps, 0)


func test_advance_clock_stops_at_unbeaten_intro_level() -> void:
	_data.best_distance_travelled = 10
	
	PlayerData.level_history.delete_results("intro_311")
	
	_data.advance_clock(50, false, false)
	assert_eq(_data.distance_earned, 50)
	assert_eq(_data.distance_travelled, 10)
	assert_eq(_data.banked_steps, 40)


## Even if the intro level is a level the player has somehow played before in practice mode, it should still stop them.
func test_advance_clock_stops_at_beaten_intro_level() -> void:
	_data.best_distance_travelled = 10
	
	var result := RankResult.new()
	PlayerData.level_history.add_result("intro_311", result)
	
	_data.advance_clock(50, false, false)
	assert_eq(_data.distance_earned, 50)
	assert_eq(_data.distance_travelled, 10)
	assert_eq(_data.banked_steps, 40)


func test_advance_clock_clears_intro_level() -> void:
	_data.distance_travelled = 10
	_data.best_distance_travelled = 10
	_data.banked_steps = 5
	
	_data.advance_clock(1, false, false)
	assert_eq(_data.distance_earned, 6)
	assert_eq(_data.distance_travelled, 16)
	assert_eq(_data.banked_steps, 0)


func test_advance_clock_fails_intro_level() -> void:
	_data.distance_travelled = 10
	_data.best_distance_travelled = 10
	_data.banked_steps = 5
	
	_data.advance_clock(0, false, false)
	assert_eq(_data.distance_earned, 0)
	assert_eq(_data.distance_travelled, 10)
	assert_eq(_data.banked_steps, 5)


func test_advance_clock_banked_steps_for_failed_boss_level() -> void:
	_data.best_distance_travelled = 0
	_data.banked_steps = 5
	_data.distance_travelled = 9 # boss level
	_data.advance_clock(4, false, false)
	assert_true(_data.distance_earned < 0,
			"distance_earned should be less than 0 but was %s" % [_data.distance_earned])
	assert_eq(_data.banked_steps, 5)


func test_advance_clock_banked_steps_for_failed_level() -> void:
	_data.banked_steps = 5
	_data.advance_clock(0, false, false)
	assert_eq(_data.distance_earned, 0)
	assert_eq(_data.distance_travelled, 0)
	assert_eq(_data.banked_steps, 5)


func test_advance_clock_lost_level() -> void:
	_data.advance_clock(0, false, true)
	assert_eq(_data.hours_passed, Careers.HOURS_PER_CAREER_DAY)


func test_advance_clock_banked_steps_for_finished_level() -> void:
	_data.banked_steps = 5
	_data.advance_clock(1, false, false)
	assert_eq(_data.distance_earned, 6)
	assert_eq(_data.distance_travelled, 6)
	assert_eq(_data.banked_steps, 0)


func test_distance_penalties_short() -> void:
	_data.distance_travelled = 8
	_data.distance_earned = 0
	assert_eq(_data.distance_penalties(), [0, 0, 0])
	
	_data.distance_earned = 1
	assert_eq(_data.distance_penalties(), [0, 0, 0])
	
	_data.distance_earned = 2
	assert_eq(_data.distance_penalties(), [1, 1, 0])


func test_distance_penalties_medium() -> void:
	_data.distance_travelled = 8
	_data.distance_earned = 3
	assert_eq(_data.distance_penalties(), [2, 1, 0])
	
	_data.distance_earned = 5
	assert_eq(_data.distance_penalties(), [2, 1, 0])
	
	_data.distance_earned = 6
	assert_eq(_data.distance_penalties(), [3, 2, 0])
	
	_data.distance_earned = 7
	assert_eq(_data.distance_penalties(), [4, 2, 0])


func test_distance_penalties_long() -> void:
	_data.distance_travelled = 8
	_data.distance_earned = 10
	assert_eq(_data.distance_penalties(), [4, 2, 0])
	
	_data.distance_earned = 15
	assert_eq(_data.distance_penalties(), [4, 2, 0])
	
	_data.distance_earned = 25
	assert_eq(_data.distance_penalties(), [4, 2, 0])


func test_distance_penalties_negative() -> void:
	_data.distance_travelled = 8
	_data.distance_earned = -1
	assert_eq(_data.distance_penalties(), [1, 0, 0])

	_data.distance_earned = -10
	assert_eq(_data.distance_penalties(), [1, 0, 0])


func test_distance_penalties_boss_level() -> void:
	_data.distance_travelled = 9
	_data.best_distance_travelled = 9
	assert_eq(_data.distance_penalties(), [0, 0, 0])


func test_distance_penalties_cant_cross_regions() -> void:
	_data.distance_earned = 7
	_data.distance_travelled = 10
	assert_eq(_data.distance_penalties(), [0, 0, 0])
	
	_data.distance_travelled = 12
	assert_eq(_data.distance_penalties(), [2, 2, 0])


func test_advance_past_chat_region() -> void:
	CareerLevelLibrary.regions[0].cutscene_path = "chat/career/permissible"
	_data.distance_travelled = 3
	_data.best_distance_travelled = 3
	_data.distance_earned = 2
	_data.remain_in_region = true
	_data.advance_past_chat_region("chat/career/permissible/boss_level_end_2")
	
	assert_eq(_data.distance_travelled, 10)
	assert_eq(_data.best_distance_travelled, 10)
	assert_eq(_data.distance_earned, 9)
	assert_eq(_data.remain_in_region, false)


func test_advance_past_chat_region_previous_region() -> void:
	CareerLevelLibrary.regions[0].cutscene_path = "chat/career/permissible"
	_data.distance_travelled = 13
	_data.best_distance_travelled = 13
	_data.distance_earned = 2
	_data.remain_in_region = false
	_data.advance_past_chat_region("chat/career/permissible/boss_level_end_2")
	
	assert_eq(_data.distance_travelled, 13)
	assert_eq(_data.best_distance_travelled, 13)
	assert_eq(_data.distance_earned, 2)
	assert_eq(_data.remain_in_region, false)
