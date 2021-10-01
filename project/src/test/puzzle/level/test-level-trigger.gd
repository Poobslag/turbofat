extends "res://addons/gut/test.gd"
"""
Tests triggers which causes strange things to happen during a level.
"""

func test_after_line_cleared_012345() -> void:
	var json_dict := {
		"phases": ["after_line_cleared y=0-5"],
		"effect": "insert_line"
	}
	
	var trigger := LevelTrigger.new()
	trigger.from_json_dict(json_dict)
	assert_true(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 19}), "should_run y=0")
	assert_true(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 16}), "should_run y=3")
	assert_true(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 14}), "should_run y=5")
	assert_false(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 13}), "should_run y=6")


func test_after_line_cleared_135() -> void:
	var json_dict := {
		"phases": ["after_line_cleared y=1,3,5"],
		"effect": "insert_line"
	}
	
	var trigger := LevelTrigger.new()
	trigger.from_json_dict(json_dict)
	assert_false(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 19}), "should_run y=0")
	assert_true(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 16}), "should_run y=3")
	assert_true(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 14}), "should_run y=5")
	assert_false(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 13}), "should_run y=6")


func test_after_line_cleared_0456() -> void:
	var json_dict := {
		"phases": ["after_line_cleared y=1,4-6"],
		"effect": "insert_line"
	}
	
	var trigger := LevelTrigger.new()
	trigger.from_json_dict(json_dict)
	assert_false(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 19}), "should_run y=0")
	assert_false(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 16}), "should_run y=3")
	assert_true(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 14}), "should_run y=5")
	assert_true(trigger.should_run(LevelTrigger.AFTER_LINE_CLEARED, {"y": 13}), "should_run y=6")


func test_dict_config_from_array_unkeyed() -> void:
	var params := LevelTrigger.dict_config_from_array(["uppity", "fragile"])
	assert_eq(params.get("0"), "uppity", "params.get(\"0\")")
	assert_eq(params.get("1"), "fragile", "params.get(\"1\")")


func test_dict_config_from_array_keyed() -> void:
	var params := LevelTrigger.dict_config_from_array(["uppity=736", "fragile=662"])
	assert_eq(params.get("uppity"), "736", "params.get(\"uppity\")")
	assert_eq(params.get("fragile"), "662", "params.get(\"fragile\")")


func test_dict_config_from_array_mixed() -> void:
	var params := LevelTrigger.dict_config_from_array(["uppity", "fragile=662", "stiff"])
	assert_eq(params.get("0"), "uppity", "params.get(\"0\")")
	assert_eq(params.get("fragile"), "662", "params.get(\"fragile\")")
	assert_eq(params.get("1"), "stiff", "params.get(\"1\")")
