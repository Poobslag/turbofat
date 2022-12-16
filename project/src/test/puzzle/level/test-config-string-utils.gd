extends GutTest

func test_ints_from_config_string() -> void:
	assert_eq(ConfigStringUtils.ints_from_config_string("").keys(), [])
	assert_eq(ConfigStringUtils.ints_from_config_string("2").keys(), [2])
	assert_eq(ConfigStringUtils.ints_from_config_string("1,3,5").keys(), [1, 3, 5])
	assert_eq(ConfigStringUtils.ints_from_config_string("0-3").keys(), [0, 1, 2, 3])
	assert_eq(ConfigStringUtils.ints_from_config_string("1-2,4-5").keys(), [1, 2, 4, 5])
	assert_eq(ConfigStringUtils.ints_from_config_string("0,4-6").keys(), [0, 4, 5, 6])
	assert_eq(ConfigStringUtils.ints_from_config_string("6,2-4,13").keys(), [6, 2, 3, 4, 13])


func test_ints_from_config_string_ellipses() -> void:
	assert_eq(ConfigStringUtils.ints_from_config_string("10,11,12...", 15).keys(), [10, 11, 12, 13, 14, 15])
	assert_eq(ConfigStringUtils.ints_from_config_string("5,8...", 15).keys(), [5, 8, 11, 14])
	assert_eq(ConfigStringUtils.ints_from_config_string("2...", 5).keys(), [2, 3, 4, 5])


func test_config_string_from_ints() -> void:
	assert_eq("", ConfigStringUtils.config_string_from_ints([]))
	assert_eq("2", ConfigStringUtils.config_string_from_ints([2]))
	assert_eq("1,3,5", ConfigStringUtils.config_string_from_ints([1, 3, 5]))
	assert_eq("1-2,4-5", ConfigStringUtils.config_string_from_ints([1, 2, 4, 5]))
	assert_eq("0-3", ConfigStringUtils.config_string_from_ints([0, 1, 2, 3]))
	assert_eq("0,4-6", ConfigStringUtils.config_string_from_ints([0, 4, 5, 6]))
	assert_eq("2-4,6,13", ConfigStringUtils.config_string_from_ints([4, 3, 6, 13, 2]))


func test_config_string_from_ints_ellipses() -> void:
	assert_eq(ConfigStringUtils.config_string_from_ints([10, 11, 12, 13, 14, 15], 15), "10...")
	assert_eq(ConfigStringUtils.config_string_from_ints([10, 11, 12, 13, 14, 15, 16], 15), "10...")
	assert_eq(ConfigStringUtils.config_string_from_ints([10, 11, 12, 13, 14], 15), "10-14")
	assert_eq(ConfigStringUtils.config_string_from_ints([5, 10, 11, 12, 13, 14, 15], 15), "5,10,11...")
	assert_eq(ConfigStringUtils.config_string_from_ints([5, 8, 11, 14], 15), "5,8...")
	assert_eq(ConfigStringUtils.config_string_from_ints([2, 3, 4, 5], 5), "2...")
