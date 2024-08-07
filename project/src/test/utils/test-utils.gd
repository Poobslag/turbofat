extends GutTest

enum MoldyFlap {
	BIT_PUNY,
	ROB_RECEIPT,
	MEATY_FALSE,
}


func test_brightness() -> void:
	# white and black should return exactly 0.0 and 1.0
	assert_eq(Utils.brightness(Color("000000")), 0.0)
	assert_eq(Utils.brightness(Color("ffffff")), 1.0)
	
	# green is brighter than red, red is brighter than blue
	assert_almost_eq(Utils.brightness(Color("800000")), 0.15, 0.1)
	assert_almost_eq(Utils.brightness(Color("008000")), 0.29, 0.1)
	assert_almost_eq(Utils.brightness(Color("000080")), 0.05, 0.1)


func test_convert_floats_to_ints_in_array() -> void:
	var input := ["a", 2, 3.0]
	var result := Utils.convert_floats_to_ints_in_array(input)
	assert_eq_shallow(result, ["a", 2, 3])


func test_convert_floats_to_ints_in_array_input_unmodified() -> void:
	var input := ["a", 2, 3.0]
	Utils.convert_floats_to_ints_in_array(input)
	assert_eq_shallow(input, ["a", 2, 3.0])


func test_convert_floats_to_ints_in_dict_keys() -> void:
	var input := {"a": "b", 2: "c", 3.0: "d"}
	var result := Utils.convert_floats_to_ints_in_dict(input)
	assert_eq_shallow(result, {"a": "b", 2: "c", 3: "d"})


func test_convert_floats_to_ints_in_dict_values() -> void:
	var input := {"b": "a", "c": 2, "d": 3.0}
	var result := Utils.convert_floats_to_ints_in_dict(input)
	assert_eq_shallow(result, {"b": "a", "c": 2, "d": 3})


func test_convert_floats_to_ints_in_dict_keys_and_values() -> void:
	var input := {62: 94, 48.0: 54, 44: 90.0, 38.0: 73.0}
	var result := Utils.convert_floats_to_ints_in_dict(input)
	assert_eq_shallow(result, {62: 94, 48: 54, 44: 90, 38: 73})


func test_convert_floats_to_ints_in_dict_input_unmodified() -> void:
	var input := {62: 94, 48.0: 54, 44: 90.0, 38.0: 73.0}
	Utils.convert_floats_to_ints_in_dict(input)
	assert_eq_shallow(input, {62: 94, 48.0: 54, 44: 90.0, 38.0: 73.0})


func test_disjunction() -> void:
	assert_eq(Utils.disjunction([1, 2, 3], [2, 3, 4]), [1, 4])
	assert_eq(Utils.disjunction([1, 2, 3], [2]), [1, 3])
	assert_eq(Utils.disjunction([2], [1, 2, 3]), [1, 3])
	assert_eq(Utils.disjunction([], [1]), [1])
	assert_eq(Utils.disjunction([1], []), [1])


func test_disjunction_duplicates() -> void:
	assert_eq(Utils.disjunction([1, 1, 1], [1, 1]), [1])
	assert_eq(Utils.disjunction([1, 2, 2, 3, 3, 3], [1, 1, 1, 2, 2, 3]), [1, 1, 3, 3])


func test_enum_to_snake_case() -> void:
	assert_eq(Utils.enum_to_snake_case(MoldyFlap, MoldyFlap.ROB_RECEIPT, "meaty_false"), "rob_receipt")
	assert_eq(Utils.enum_to_snake_case(MoldyFlap, MoldyFlap.ROB_RECEIPT), "rob_receipt")
	assert_eq(Utils.enum_to_snake_case(MoldyFlap, 13, "meaty_false"), "meaty_false")
	assert_eq(Utils.enum_to_snake_case(MoldyFlap, 13), "bit_puny")


func test_enum_from_snake_case() -> void:
	assert_eq(Utils.enum_from_snake_case(MoldyFlap, "rob_receipt", MoldyFlap.MEATY_FALSE), MoldyFlap.ROB_RECEIPT)
	assert_eq(Utils.enum_from_snake_case(MoldyFlap, "rob_receipt"), MoldyFlap.ROB_RECEIPT)
	assert_eq(Utils.enum_from_snake_case(MoldyFlap, "bogus_610", MoldyFlap.MEATY_FALSE), MoldyFlap.MEATY_FALSE)
	assert_eq(Utils.enum_from_snake_case(MoldyFlap, "bogus_610"), MoldyFlap.BIT_PUNY)


func test_intersection() -> void:
	assert_eq(Utils.intersection([1, 2, 3], [2, 3, 4]), [2, 3])
	assert_eq(Utils.intersection([1, 2, 3], [2]), [2])
	assert_eq(Utils.intersection([2], [1, 2, 3]), [2])
	assert_eq(Utils.intersection([], [1]), [])
	assert_eq(Utils.intersection([1], []), [])


func test_intersection_duplicates() -> void:
	assert_eq(Utils.intersection([1, 1, 1], [1, 1]), [1, 1])
	assert_eq(Utils.intersection([1, 2, 2, 3, 3, 3], [1, 1, 1, 2, 2, 3]), [1, 2, 2, 3])


func test_remove_all() -> void:
	assert_eq([4, 10, 15], Utils.remove_all([1, 4, 10, 1, 15], 1))


func test_remove_all_not_found() -> void:
	assert_eq([1, 4, 10, 1, 15], Utils.remove_all([1, 4, 10, 1, 15], 2))


func test_remove_all_empty() -> void:
	assert_eq([], Utils.remove_all([], 2))


func test_seeded_shuffle_shuffles() -> void:
	var source := ["a", "b", "c", "d", "e", "f", "g"]
	
	var shuffled1 := source.duplicate()
	Utils.seeded_shuffle(shuffled1, 26)
	
	assert_false(shuffled1 == source, "shuffle did not reorder source array (%s, %s)" % [shuffled1, source])


func test_seeded_shuffle_same_seed() -> void:
	var source := ["a", "b", "c", "d", "e", "f", "g"]
	
	var shuffled1 := source.duplicate()
	Utils.seeded_shuffle(shuffled1, 26)
	
	var shuffled2 := source.duplicate()
	Utils.seeded_shuffle(shuffled2, 26)
	
	assert_true(shuffled1 == shuffled2, "same seed resulted in different output (%s, %s)" % [shuffled1, shuffled2])


func test_seeded_shuffle_different_seed() -> void:
	var source := ["a", "b", "c", "d", "e", "f", "g"]
	
	var shuffled1 := source.duplicate()
	Utils.seeded_shuffle(shuffled1, 26)
	
	var shuffled2 := source.duplicate()
	Utils.seeded_shuffle(shuffled2, 18)
	
	assert_false(shuffled1 == shuffled2, "different seed resulted in same output (%s, %s)" % [shuffled1, shuffled2])


func test_subtract() -> void:
	assert_eq(Utils.subtract([1, 2, 3], [1, 3]), [2])


func test_subtract_duplicates() -> void:
	assert_eq(Utils.subtract([1, 1, 1, 1, 1], [1, 1]), [1, 1, 1])


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


func test_is_json_deep_equal_basic() -> void:
	assert_eq(true, Utils.is_json_deep_equal({"a": "a"}, {"a": "a"}))
	assert_eq(false, Utils.is_json_deep_equal({"a": "a"}, {"a": "b"}))
	assert_eq(false, Utils.is_json_deep_equal({"b": "a"}, {"a": "a"}))
	assert_eq(false, Utils.is_json_deep_equal({"a": "a"}, {"a": "a", "b": "b"}))
	assert_eq(false, Utils.is_json_deep_equal({"a": "a", "b": "b"}, {"a": "a"}))


func test_is_json_deep_equal_data_types() -> void:
	assert_eq(true, Utils.is_json_deep_equal({"a": 10}, {"a": 10}))
	assert_eq(false, Utils.is_json_deep_equal({"a": 10}, {"a": 10.0}))
	assert_eq(true, Utils.is_json_deep_equal({10: "a"}, {10: "a"}))
	assert_eq(false, Utils.is_json_deep_equal({10: "a"}, {10.0: "a"}))


func test_is_json_deep_equal_dictionaries() -> void:
	assert_eq(true, Utils.is_json_deep_equal({"z": {"a": "a"}}, {"z": {"a": "a"}}))
	assert_eq(false, Utils.is_json_deep_equal({"z": {"a": "a"}}, {"z": {"a": "b"}}))
	assert_eq(false, Utils.is_json_deep_equal({"z": {"b": "a"}}, {"z": {"a": "a"}}))
	assert_eq(false, Utils.is_json_deep_equal({"z": {"a": "a"}}, {"z": {"a": "a", "b": "b"}}))
	assert_eq(false, Utils.is_json_deep_equal({"z": {"a": "a", "b": "b"}}, {"z": {"a": "a"}}))


func test_is_json_deep_equal_arrays() -> void:
	assert_eq(true, Utils.is_json_deep_equal({"a": ["b"]}, {"a": ["b"]}))
	assert_eq(false, Utils.is_json_deep_equal({"a": ["b"]}, {"a": []}))
	assert_eq(false, Utils.is_json_deep_equal({"a": ["b"]}, {"a": ["b", "c"]}))
	assert_eq(false, Utils.is_json_deep_equal({"a": []}, {"a": ["b"]}))
	assert_eq(false, Utils.is_json_deep_equal({"a": ["b", "c"]}, {"a": ["b"]}))


func test_is_json_deep_equal_recursive() -> void:
	var dict1 := {"a": 10, "b": 2, "c": {"d": 4, "e": [1, 2, 3]}}
	assert_eq(true, Utils.is_json_deep_equal(dict1, {"a": 10, "b": 2, "c": {"d": 4, "e": [1, 2, 3]}}))
	assert_eq(false, Utils.is_json_deep_equal(dict1, {"a": 10, "b": 2, "c": {"d": 4, "e": [1, 2]}}))
	assert_eq(false, Utils.is_json_deep_equal(dict1, {"a": 10, "b": 2, "c": {"d": 4, "e": [1, 2, 4]}}))
	assert_eq(false, Utils.is_json_deep_equal(dict1, {"a": 10, "b": 2, "c": {"d": 4, "e": [1, 2, 3, 4]}}))
	assert_eq(false, Utils.is_json_deep_equal(dict1, {"a": 10, "b": 2, "c": {"e": [1, 2, 3]}}))
	assert_eq(false, Utils.is_json_deep_equal(dict1, {"a": 10, "b": 2, "c": {"d": 4, "e": [1, 2, 3], "f": 5}}))
	assert_eq(false, Utils.is_json_deep_equal(dict1, {"a": 10, "b": 2, "c": {"d": 5, "e": [1, 2, 3]}}))


func test_color_distance_rgb() -> void:
	assert_eq(0.0, Utils.color_distance_rgb(Color("1a1a1a"), Color("1a1a1a")))
	assert_almost_eq(sqrt(3), Utils.color_distance_rgb(Color("000000"), Color("ffffff")), 0.001)
