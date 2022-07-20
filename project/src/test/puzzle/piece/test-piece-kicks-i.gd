extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
## Tests the i piece's kick behavior.

func test_floor_kick_0r_0() -> void:
	from_orientation = 0
	from_grid = [
		"      ",
		"      ",
		"      ",
		"      ",
		"      ",
		" iiii ",
	]
	to_orientation = 1
	to_grid = [
		"      ",
		"      ",
		"    i ",
		"    i ",
		"    i ",
		"    i ",
	]
	assert_kick()


func test_floor_kick_0r_1() -> void:
	from_orientation = 0
	from_grid = [
		"      ",
		"      ",
		"      ",
		"      ",
		" iiii ",
		"      ",
	]
	to_orientation = 1
	to_grid = [
		"      ",
		"    i ",
		"    i ",
		"    i ",
		"    i ",
		"      ",
	]
	assert_kick()


func test_floor_kick_0l_0() -> void:
	from_orientation = 0
	from_grid = [
		"      ",
		"      ",
		"      ",
		"      ",
		"      ",
		" iiii ",
	]
	to_orientation = 3
	to_grid = [
		"      ",
		"      ",
		" i    ",
		" i    ",
		" i    ",
		" i    ",
	]
	assert_kick()


func test_floor_kick_0l_1() -> void:
	from_orientation = 0
	from_grid = [
		"      ",
		"      ",
		"      ",
		"      ",
		" iiii ",
		"      ",
	]
	to_orientation = 3
	to_grid = [
		"      ",
		" i    ",
		" i    ",
		" i    ",
		" i    ",
		"      ",
	]
	assert_kick()


func test_floor_kick_2r_0() -> void:
	from_orientation = 2
	from_grid = [
		"      ",
		"      ",
		"      ",
		"      ",
		"      ",
		" iiii ",
	]
	to_orientation = 1
	to_grid = [
		"      ",
		"      ",
		" i    ",
		" i    ",
		" i    ",
		" i    ",
	]
	assert_kick()


func test_floor_kick_2l_0() -> void:
	from_orientation = 2
	from_grid = [
		"      ",
		"      ",
		"      ",
		"      ",
		"      ",
		" iiii ",
	]
	to_orientation = 3
	to_grid = [
		"      ",
		"      ",
		"    i ",
		"    i ",
		"    i ",
		"    i ",
	]
	assert_kick()


func test_wall_kick_r0_0() -> void:
	from_orientation = 1
	from_grid = [
		"      ",
		"i     ",
		"i     ",
		"i     ",
		"i     ",
		"      ",
	]
	to_orientation = 0
	to_grid = [
		"      ",
		"      ",
		"iiii  ",
		"      ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_r0_1() -> void:
	from_orientation = 1
	from_grid = [
		"      ",
		" i    ",
		" i    ",
		" i    ",
		" i    ",
		"      ",
	]
	to_orientation = 0
	to_grid = [
		"      ",
		"      ",
		" iiii ",
		"      ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_r0_2() -> void:
	from_orientation = 1
	from_grid = [
		"      ",
		"     i",
		"     i",
		"     i",
		"     i",
		"      ",
	]
	to_orientation = 0
	to_grid = [
		"      ",
		"      ",
		"  iiii",
		"      ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_r2_0() -> void:
	from_orientation = 1
	from_grid = [
		"      ",
		"i     ",
		"i     ",
		"i     ",
		"i     ",
		"      ",
	]
	to_orientation = 2
	to_grid = [
		"      ",
		"      ",
		"      ",
		"iiii  ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_r2_1() -> void:
	from_orientation = 1
	from_grid = [
		"      ",
		" i    ",
		" i    ",
		" i    ",
		" i    ",
		"      ",
	]
	to_orientation = 2
	to_grid = [
		"      ",
		"      ",
		"      ",
		" iiii ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_r2_2() -> void:
	from_orientation = 1
	from_grid = [
		"      ",
		"     i",
		"     i",
		"     i",
		"     i",
		"      ",
	]
	to_orientation = 2
	to_grid = [
		"      ",
		"      ",
		"      ",
		"  iiii",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_l0_0() -> void:
	from_orientation = 3
	from_grid = [
		"      ",
		"i     ",
		"i     ",
		"i     ",
		"i     ",
		"      ",
	]
	to_orientation = 0
	to_grid = [
		"      ",
		"      ",
		"iiii  ",
		"      ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_l0_1() -> void:
	from_orientation = 3
	from_grid = [
		"      ",
		"    i ",
		"    i ",
		"    i ",
		"    i ",
		"      ",
	]
	to_orientation = 0
	to_grid = [
		"      ",
		"      ",
		" iiii ",
		"      ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_l0_2() -> void:
	from_orientation = 3
	from_grid = [
		"      ",
		"     i",
		"     i",
		"     i",
		"     i",
		"      ",
	]
	to_orientation = 0
	to_grid = [
		"      ",
		"      ",
		"  iiii",
		"      ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_l2_0() -> void:
	from_orientation = 3
	from_grid = [
		"      ",
		"i     ",
		"i     ",
		"i     ",
		"i     ",
		"      ",
	]
	to_orientation = 2
	to_grid = [
		"      ",
		"      ",
		"      ",
		"iiii  ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_l2_1() -> void:
	from_orientation = 3
	from_grid = [
		"      ",
		"    i ",
		"    i ",
		"    i ",
		"    i ",
		"      ",
	]
	to_orientation = 2
	to_grid = [
		"      ",
		"      ",
		"      ",
		" iiii ",
		"      ",
		"      ",
	]
	assert_kick()


func test_wall_kick_l2_2() -> void:
	from_orientation = 3
	from_grid = [
		"      ",
		"     i",
		"     i",
		"     i",
		"     i",
		"      ",
	]
	to_orientation = 2
	to_grid = [
		"      ",
		"      ",
		"      ",
		"  iiii",
		"      ",
		"      ",
	]
	assert_kick()


## A 'pinch kick' is where the piece slinks in sideways into a faraway gap.
func test_pinch_kick_0r_0() -> void:
	from_orientation = 0
	from_grid = [
		"      ",
		":     ",
		"      ",
		"iiii  ",
		"      ",
		" :::::",
	]
	to_orientation = 1
	to_grid = [
		"      ",
		":     ",
		"i     ",
		"i     ",
		"i     ",
		"i:::::",
	]
	assert_kick()


func test_pinch_kick_0r_1() -> void:
	from_orientation = 0
	from_grid = [
		"      ",
		"     :",
		"      ",
		"  iiii",
		"      ",
		"::::: ",
	]
	to_orientation = 1
	to_grid = [
		"      ",
		"     :",
		"     i",
		"     i",
		"     i",
		":::::i",
	]
	assert_kick()


func test_pinch_kick_0l_0() -> void:
	from_orientation = 0
	from_grid = [
		"      ",
		":     ",
		"      ",
		"iiii  ",
		"      ",
		" :::::",
	]
	to_orientation = 3
	to_grid = [
		"      ",
		":     ",
		"i     ",
		"i     ",
		"i     ",
		"i:::::",
	]
	assert_kick()


func test_pinch_kick_0l_1() -> void:
	from_orientation = 0
	from_grid = [
		"      ",
		"     :",
		"      ",
		"  iiii",
		"      ",
		"::::: ",
	]
	to_orientation = 3
	to_grid = [
		"      ",
		"     :",
		"     i",
		"     i",
		"     i",
		":::::i",
	]
	assert_kick()


func test_pinch_kick_2r_0() -> void:
	from_orientation = 2
	from_grid = [
		"      ",
		":     ",
		"      ",
		"      ",
		"iiii  ",
		" :::::",
	]
	to_orientation = 1
	to_grid = [
		"      ",
		":     ",
		"i     ",
		"i     ",
		"i     ",
		"i:::::",
	]
	assert_kick()


func test_pinch_kick_2r_1() -> void:
	from_orientation = 2
	from_grid = [
		"      ",
		"     :",
		"      ",
		"      ",
		"  iiii",
		"::::: ",
	]
	to_orientation = 1
	to_grid = [
		"      ",
		"     :",
		"     i",
		"     i",
		"     i",
		":::::i",
	]
	assert_kick()


func test_pinch_kick_2l_0() -> void:
	from_orientation = 2
	from_grid = [
		"      ",
		":     ",
		"      ",
		"      ",
		"iiii  ",
		" :::::",
	]
	to_orientation = 3
	to_grid = [
		"      ",
		":     ",
		"i     ",
		"i     ",
		"i     ",
		"i:::::",
	]
	assert_kick()


func test_pinch_kick_2l_1() -> void:
	from_orientation = 2
	from_grid = [
		"      ",
		"     :",
		"      ",
		"      ",
		"  iiii",
		"::::: ",
	]
	to_orientation = 3
	to_grid = [
		"      ",
		"     :",
		"     i",
		"     i",
		"     i",
		":::::i",
	]
	assert_kick()
