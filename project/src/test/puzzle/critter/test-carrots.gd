extends GutTest

func test_deconflict_carrots_width_1() -> void:
	assert_eq(Carrots.deconflict_carrots([3, 4, 5, 1, 2, 0, 6], Vector2i(1, 4)), [3, 4, 5, 1, 2, 0, 6])
	assert_eq(Carrots.deconflict_carrots([6, 0, 1, 5, 4, 2, 3], Vector2i(1, 4)), [6, 0, 1, 5, 4, 2, 3])


func test_deconflict_carrots_width_2() -> void:
	assert_eq(Carrots.deconflict_carrots([3, 4, 5, 1, 2, 0, 6], Vector2i(2, 3)), [3, 5, 1, 4, 2, 0, 6])
	assert_eq(Carrots.deconflict_carrots([6, 0, 1, 5, 4, 2, 3], Vector2i(2, 3)), [6, 0, 4, 2, 1, 5, 3])


func test_deconflict_carrots_width_3() -> void:
	assert_eq(Carrots.deconflict_carrots([3, 4, 5, 1, 2, 0, 6], Vector2i(3, 4)), [3, 0, 6, 4, 5, 1, 2])
	assert_eq(Carrots.deconflict_carrots([6, 0, 1, 5, 4, 2, 3], Vector2i(3, 4)), [6, 0, 3, 1, 5, 4, 2])
