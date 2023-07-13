extends GutTest

var rules: SpeedRules

func before_each() -> void:
	rules = SpeedRules.new()


func test_start_speed_is_default() -> void:
	assert_eq(rules.start_speed_is_default(), true)
	rules.set_start_speed("6")
	assert_eq(rules.start_speed_is_default(), false)


func test_speed_ups_is_default() -> void:
	assert_eq(rules.speed_ups_is_default(), true)
	rules.add_speed_up(Milestone.LINES, 20, "6")
	assert_eq(rules.speed_ups_is_default(), false)


func test_to_json_start_speed() -> void:
	rules.set_start_speed("FC")
	_convert_to_json_and_back()
	assert_eq(rules.speed_ups.size(), 1)
	assert_eq(rules.speed_ups[0].type, Milestone.LINES)
	assert_eq(rules.speed_ups[0].value, 0)
	assert_eq(rules.speed_ups[0].get_meta("speed"), "FC")


func test_to_json_speed_ups() -> void:
	rules.add_speed_up(Milestone.LINES, 10, "FD")
	rules.add_speed_up(Milestone.LINES, 20, "FE")
	rules.speed_ups[2].set_meta("meta_719", "value_719")
	_convert_to_json_and_back()
	
	assert_eq(rules.speed_ups.size(), 3)
	assert_eq(rules.speed_ups[0].type, Milestone.LINES)
	assert_eq(rules.speed_ups[0].value, 0)
	assert_eq(rules.speed_ups[0].get_meta("speed"), "0")
	assert_eq(rules.speed_ups[1].type, Milestone.LINES)
	assert_eq(rules.speed_ups[1].value, 10)
	assert_eq(rules.speed_ups[1].get_meta("speed"), "FD")
	assert_eq(rules.speed_ups[2].type, Milestone.LINES)
	assert_eq(rules.speed_ups[2].value, 20)
	assert_eq(rules.speed_ups[2].get_meta("speed"), "FE")
	assert_eq(rules.speed_ups[2].get_meta("meta_719"), "value_719")


func _convert_to_json_and_back() -> void:
	var start_speed := rules.start_speed_to_json_string()
	var speed_ups := rules.speed_ups_to_json_array()
	rules = SpeedRules.new()
	rules.start_speed_from_json_string(start_speed)
	rules.speed_ups_from_json_array(speed_ups)
