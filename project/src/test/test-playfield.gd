extends "res://addons/gut/test.gd"

func test_closest_clears() -> void:
	var result := LineClearer.closest_clears([0, 1, 3, 4, 5, 7], [2, 6, 8, 9, 10])
	assert_eq([1, 5, 7, 7, 7], result)
