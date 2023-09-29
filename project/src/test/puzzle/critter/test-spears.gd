extends GutTest

func test_resolve_spear_size_x() -> void:
	assert_eq(Spears.resolve_spear_size_x("l1", 0), "l1")
	assert_eq(Spears.resolve_spear_size_x("l2r3", 1), "l2r3")
	
	assert_eq(Spears.resolve_spear_size_x("x1", 0), "l1")
	assert_eq(Spears.resolve_spear_size_x("x2", 1), "r2")
	
	assert_eq(Spears.resolve_spear_size_x("x1x2", 0), "l1r2")
	assert_eq(Spears.resolve_spear_size_x("x3x4", 1), "r3l4")
	
	assert_eq(Spears.resolve_spear_size_x("X1X2", 0), "L1R2")
	assert_eq(Spears.resolve_spear_size_x("X3X4", 1), "R3L4")
	assert_eq(Spears.resolve_spear_size_x("X1x2", 0), "L1r2")
	assert_eq(Spears.resolve_spear_size_x("x3X4", 1), "r3L4")
