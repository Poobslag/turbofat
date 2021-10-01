extends "res://addons/gut/test.gd"
"""
Tests for rank information for a playthrough.
"""

var result: RankResult

func before_each() -> void:
	result = RankResult.new()


func test_to_json_lost() -> void:
	result.lost = true
	var json1 := result.to_json_dict()
	assert_eq(json1.get("lost"), true)
	
	result.lost = false
	var json2 := result.to_json_dict()
	assert_eq(json2.get("lost"), false)


func test_from_json_lost() -> void:
	result.from_json_dict({"lost": true})
	assert_eq(result.get("lost"), true)
	
	result = RankResult.new()
	result.from_json_dict({"lost": false})
	assert_eq(result.get("lost"), false)
