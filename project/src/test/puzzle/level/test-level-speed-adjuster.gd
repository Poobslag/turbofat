extends GutTest

var settings: LevelSettings
var adjuster: LevelSpeedAdjuster

func before_each() -> void:
	settings = LevelSettings.new()
	adjuster = LevelSpeedAdjuster.new(settings)


func assert_start_speed(expected: String) -> void:
	assert_eq(settings.speed.speed_ups[0].get_meta("speed"), expected)


func assert_speed_up(speed_up_index: int, expected: String) -> void:
	assert_eq(settings.speed.speed_ups[speed_up_index].get_meta("speed"), expected)


func set_start_speed(new_start_speed: String) -> void:
	settings.speed.set_start_speed(new_start_speed)


func add_speed_up(speed: String) -> void:
	settings.speed.add_speed_up(Milestone.LINES, settings.speed.speed_ups.size() * 10, speed)


func test_adjust_3_0() -> void:
	settings.speed.set_start_speed("3")
	adjuster.adjust("0")
	
	assert_start_speed("0")


func test_adjust_3_6() -> void:
	settings.speed.set_start_speed("3")
	adjuster.adjust("6")
	
	assert_start_speed("6")


## Can't adjust level from 3 to A5; this changes the lock timings allowing for MUCH faster play, invalidating rankings
# and high scores
func test_adjust_3_A5() -> void:
	set_start_speed("3")
	adjuster.adjust("A5")
	
	assert_start_speed("3")


## Can't adjust level from A5 to FF; this changes the lock timings allowing for MUCH faster play, invalidating rankings
# and high scores
func test_adjust_A5_FF() -> void:
	set_start_speed("A5")
	adjuster.adjust("FF")
	
	assert_start_speed("A5")


func test_adjust_A3_A5() -> void:
	set_start_speed("A3")
	adjuster.adjust("A5")
	
	assert_start_speed("A5")


func test_adjust_speed_ups() -> void:
	set_start_speed("2")
	add_speed_up("4")
	add_speed_up("6")
	adjuster.adjust("5")
	
	assert_start_speed("5")
	assert_speed_up(1, "7")
	assert_speed_up(2, "9")


func test_adjust_speed_ups_too_slow() -> void:
	set_start_speed("5")
	add_speed_up("3")
	add_speed_up("1")
	adjuster.adjust("1")
	
	assert_start_speed("1")
	assert_speed_up(1, "0")
	assert_speed_up(2, "0")


func test_get_adjusted_speed_unique() -> void:
	assert_eq(adjuster.get_adjusted_speed("T", -1), "T")
	assert_eq(adjuster.get_adjusted_speed("T", 1), "T")


func test_get_adjusted_speed_3() -> void:
	assert_eq(adjuster.get_adjusted_speed("3", -1), "2")
	assert_eq(adjuster.get_adjusted_speed("3", 1), "4")
	assert_eq(adjuster.get_adjusted_speed("3", 3), "6")
	
	assert_eq(adjuster.get_adjusted_speed("3", -99), "0")
	assert_eq(adjuster.get_adjusted_speed("3", 99), "9")


func test_get_adjusted_speed_AB() -> void:
	assert_eq(adjuster.get_adjusted_speed("AB", -3), "A8")
	assert_eq(adjuster.get_adjusted_speed("AB", -1), "AA")
	assert_eq(adjuster.get_adjusted_speed("AB", 1), "AC")
	
	assert_eq(adjuster.get_adjusted_speed("AB", -99), "A0")
	assert_eq(adjuster.get_adjusted_speed("AB", 99), "AF")


func test_get_adjusted_speed_FC() -> void:
	assert_eq(adjuster.get_adjusted_speed("FC", -1), "FB")
	assert_eq(adjuster.get_adjusted_speed("FC", 1), "FD")
	assert_eq(adjuster.get_adjusted_speed("FC", 3), "FF")
	
	assert_eq(adjuster.get_adjusted_speed("FC", -99), "F0")
	assert_eq(adjuster.get_adjusted_speed("FC", 99), "FFF")
