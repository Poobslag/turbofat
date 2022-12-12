extends GutTest

var replay: InputReplay

func before_each() -> void:
	replay = InputReplay.new()


func test_is_default() -> void:
	assert_eq(replay.is_default(), true)
	
	replay.action_timings = {"25 +rotate_cw": true, "33 -rotate_cw": true}
	assert_eq(replay.is_default(), false)


func test_convert_replay_to_json_and_back() -> void:
	replay.action_timings = {"25 +rotate_cw": true, "33 -rotate_cw": true}
	_convert_to_json_and_back()
	
	assert_eq(replay.action_timings.keys(), ["25 +rotate_cw", "33 -rotate_cw"])


func _convert_to_json_and_back() -> void:
	var json := replay.to_json_array()
	replay = InputReplay.new()
	replay.from_json_array(json)
