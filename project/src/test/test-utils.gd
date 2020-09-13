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


func test_subtract() -> void:
	assert_eq(Utils.subtract([1, 2, 3], [1, 3]), [2])


func test_subtract_duplicates() -> void:
	assert_eq(Utils.subtract([1, 1, 1, 1, 1], [1, 1]), [1, 1, 1])


func test_remove_all() -> void:
	assert_eq([4, 10, 15], Utils.remove_all([1, 4, 10, 1, 15], 1))


func test_remove_all_not_found() -> void:
	assert_eq([1, 4, 10, 1, 15], Utils.remove_all([1, 4, 10, 1, 15], 2))


func test_remove_all_empty() -> void:
	assert_eq([], Utils.remove_all([], 2))
