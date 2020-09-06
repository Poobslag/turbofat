extends "res://addons/gut/test.gd"
"""
Unit test for utils functions.
"""

func test_weighted_rand_value() -> void:
	# item #575 should be picked 99.9% of the time
	var weights_map := {}
	for i in range(1000):
		weights_map["item-%s" % i] = 0.001
	weights_map["item-575"] = 1000.0
	
	# we pick three times, just in case we hit the 0.1% chance
	var results := {}
	for _i in range(3):
		results[Utils.weighted_rand_value(weights_map)] = true
	
	assert_has(results, "item-575")
