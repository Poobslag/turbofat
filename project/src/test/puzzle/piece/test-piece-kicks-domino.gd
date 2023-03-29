extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
## Tests the domino piece's kick behavior.

func test_floor_kick_0r_0() -> void:
	from_orientation = 0
	from_grid = [
		"    ",
		"    ",
		" -- ",
	]
	to_orientation = 1
	to_grid = [
		"    ",
		" -  ",
		" -  ",
	]
	assert_kick()


func test_floor_kick_0l_0() -> void:
	from_orientation = 2
	from_grid = [
		"    ",
		"    ",
		" -- ",
	]
	to_orientation = 1
	to_grid = [
		"    ",
		" -  ",
		" -  ",
	]
	assert_kick()


func test_wall_kick_r0_0() -> void:
	from_orientation = 1
	from_grid = [
		"   ",
		"-  ",
		"-  ",
		"   ",
	]
	to_orientation = 0
	to_grid = [
		"   ",
		"   ",
		"-- ",
		"   ",
	]
	assert_kick()


func test_wall_kick_r0_1() -> void:
	from_orientation = 1
	from_grid = [
		"   ",
		"  -",
		"  -",
		"   ",
	]
	to_orientation = 0
	to_grid = [
		"   ",
		"   ",
		" --",
		"   ",
	]
	assert_kick()


func test_wall_kick_r2_0() -> void:
	from_orientation = 1
	from_grid = [
		"   ",
		"-  ",
		"-  ",
		"   ",
	]
	to_orientation = 2
	to_grid = [
		"   ",
		"   ",
		"-- ",
		"   ",
	]
	assert_kick()


func test_wall_kick_r2_1() -> void:
	from_orientation = 1
	from_grid = [
		"   ",
		"  -",
		"  -",
		"   ",
	]
	to_orientation = 2
	to_grid = [
		"   ",
		"   ",
		" --",
		"   ",
	]
	assert_kick()


func test_kick_0r_0() -> void:
	from_orientation = 0
	from_grid = [
		"    ",
		" :  ",
		" -- ",
		"    ",
	]
	to_orientation = 1
	to_grid = [
		"    ",
		" :- ",
		"  - ",
		"    ",
	]
	assert_kick()


func test_kick_0r_1() -> void:
	from_orientation = 0
	from_grid = [
		"    ",
		" :: ",
		" -- ",
		"    ",
	]
	to_orientation = 1
	to_grid = [
		"    ",
		" :: ",
		" -  ",
		" -  ",
	]
	assert_kick()


func test_kick_0r_2() -> void:
	from_orientation = 0
	from_grid = [
		"    ",
		" :: ",
		" -- ",
		" :  ",
	]
	to_orientation = 1
	to_grid = [
		"    ",
		" :: ",
		"  - ",
		" :- ",
	]
	assert_kick()


func test_kick_0l_0() -> void:
	from_orientation = 0
	from_grid = [
		"    ",
		" :  ",
		" -- ",
		"    ",
	]
	to_orientation = 3
	to_grid = [
		"    ",
		" :- ",
		"  - ",
		"    ",
	]
	assert_kick()


func test_kick_0l_1() -> void:
	from_orientation = 0
	from_grid = [
		"    ",
		" :: ",
		" -- ",
		"    ",
	]
	to_orientation = 3
	to_grid = [
		"    ",
		" :: ",
		" -  ",
		" -  ",
	]
	assert_kick()


func test_kick_0l_2() -> void:
	from_orientation = 0
	from_grid = [
		"    ",
		" :: ",
		" -- ",
		" :  ",
	]
	to_orientation = 3
	to_grid = [
		"    ",
		" :: ",
		"  - ",
		" :- ",
	]
	assert_kick()


func test_kick_l0_0() -> void:
	from_orientation = 1
	from_grid = [
		"    ",
		" -  ",
		" -: ",
		"    ",
	]
	to_orientation = 0
	to_grid = [
		"    ",
		"    ",
		"--: ",
		"    ",
	]
	assert_kick()


func test_kick_l0_1() -> void:
	from_orientation = 1
	from_grid = [
		"    ",
		" -  ",
		":-: ",
		"    ",
	]
	to_orientation = 0
	to_grid = [
		"    ",
		" -- ",
		": : ",
		"    ",
	]
	assert_kick()


func test_kick_l0_2() -> void:
	from_orientation = 1
	from_grid = [
		"    ",
		" -: ",
		":-: ",
		"    ",
	]
	to_orientation = 0
	to_grid = [
		"    ",
		"--: ",
		": : ",
		"    ",
	]
	assert_kick()


func test_kick_2r_0() -> void:
	from_orientation = 2
	from_grid = [
		"    ",
		" :  ",
		" -- ",
		"    ",
	]
	to_orientation = 1
	to_grid = [
		"    ",
		" :- ",
		"  - ",
		"    ",
	]
	assert_kick()


func test_kick_2r_1() -> void:
	from_orientation = 2
	from_grid = [
		"    ",
		" :: ",
		" -- ",
		"    ",
	]
	to_orientation = 1
	to_grid = [
		"    ",
		" :: ",
		" -  ",
		" -  ",
	]
	assert_kick()


func test_kick_2r_2() -> void:
	from_orientation = 2
	from_grid = [
		"    ",
		" :: ",
		" -- ",
		" :  ",
	]
	to_orientation = 1
	to_grid = [
		"    ",
		" :: ",
		"  - ",
		" :- ",
	]
	assert_kick()


func test_kick_2l_0() -> void:
	from_orientation = 2
	from_grid = [
		"    ",
		" :  ",
		" -- ",
		"    ",
	]
	to_orientation = 3
	to_grid = [
		"    ",
		" :- ",
		"  - ",
		"    ",
	]
	assert_kick()


func test_kick_2l_1() -> void:
	from_orientation = 2
	from_grid = [
		"    ",
		" :: ",
		" -- ",
		"    ",
	]
	to_orientation = 3
	to_grid = [
		"    ",
		" :: ",
		" -  ",
		" -  ",
	]
	assert_kick()


func test_kick_2l_2() -> void:
	from_orientation = 2
	from_grid = [
		"    ",
		" :: ",
		" -- ",
		" :  ",
	]
	to_orientation = 3
	to_grid = [
		"    ",
		" :: ",
		"  - ",
		" :- ",
	]
	assert_kick()
