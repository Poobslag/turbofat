extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
## Tests the s and z pieces' kick behavior.

func test_s_floor_kick_0r() -> void:
	from_orientation = 0
	from_grid = [
		"     ",
		"     ",
		"  ss ",
		" ss  ",
	]
	to_orientation = 1
	to_grid = [
		"     ",
		" s   ",
		" ss  ",
		"  s  ",
	]
	assert_kick()


func test_s_floor_kick_0l() -> void:
	from_orientation = 0
	from_grid = [
		"     ",
		"     ",
		"  ss ",
		" ss  ",
	]
	to_orientation = 3
	to_grid = [
		"     ",
		"  s  ",
		"  ss ",
		"   s ",
	]
	assert_kick()


func test_z_floor_kick_0r() -> void:
	from_orientation = 0
	from_grid = [
		"     ",
		"     ",
		" zz  ",
		"  zz ",
	]
	to_orientation = 1
	to_grid = [
		"     ",
		"  z  ",
		" zz  ",
		" z   ",
	]
	assert_kick()


func test_z_floor_kick_0l() -> void:
	from_orientation = 0
	from_grid = [
		"     ",
		"     ",
		" zz  ",
		"  zz ",
	]
	to_orientation = 3
	to_grid = [
		"     ",
		"   z ",
		"  zz ",
		"  z  ",
	]
	assert_kick()


func test_s_wall_kick_r0() -> void:
	from_orientation = 1
	from_grid = [
		"    ",
		"s   ",
		"ss  ",
		" s  ",
		"    ",
	]
	to_orientation = 0
	to_grid = [
		"    ",
		" ss ",
		"ss  ",
		"    ",
		"    ",
	]
	assert_kick()


func test_s_wall_kick_r2() -> void:
	from_orientation = 1
	from_grid = [
		"    ",
		"s   ",
		"ss  ",
		" s  ",
		"    ",
	]
	to_orientation = 2
	to_grid = [
		"    ",
		"    ",
		" ss ",
		"ss  ",
		"    ",
	]
	assert_kick()


func test_s_wall_kick_l0() -> void:
	from_orientation = 3
	from_grid = [
		"    ",
		"  s ",
		"  ss",
		"   s",
		"    ",
	]
	to_orientation = 0
	to_grid = [
		"    ",
		"  ss",
		" ss ",
		"    ",
		"    ",
	]
	assert_kick()


func test_s_wall_kick_l2() -> void:
	from_orientation = 3
	from_grid = [
		"    ",
		"  s ",
		"  ss",
		"   s",
		"    ",
	]
	to_orientation = 2
	to_grid = [
		"    ",
		"    ",
		"  ss",
		" ss ",
		"    ",
	]
	assert_kick()


func test_z_wall_kick_r0() -> void:
	from_orientation = 1
	from_grid = [
		"    ",
		" z  ",
		"zz  ",
		"z   ",
		"    ",
	]
	to_orientation = 0
	to_grid = [
		"    ",
		"zz  ",
		" zz ",
		"    ",
		"    ",
	]
	assert_kick()


func test_z_wall_kick_r2() -> void:
	from_orientation = 1
	from_grid = [
		"    ",
		" z  ",
		"zz  ",
		"z   ",
		"    ",
	]
	to_orientation = 2
	to_grid = [
		"    ",
		"    ",
		"zz  ",
		" zz ",
		"    ",
	]
	assert_kick()


func test_z_wall_kick_l0() -> void:
	from_orientation = 3
	from_grid = [
		"    ",
		"   z",
		"  zz",
		"  z ",
		"    ",
	]
	to_orientation = 0
	to_grid = [
		"    ",
		" zz ",
		"  zz",
		"    ",
		"    ",
	]
	assert_kick()


func test_z_wall_kick_l2() -> void:
	from_orientation = 3
	from_grid = [
		"    ",
		"   z",
		"  zz",
		"  z ",
		"    ",
	]
	to_orientation = 2
	to_grid = [
		"    ",
		"    ",
		" zz ",
		"  zz",
		"    ",
	]
	assert_kick()


## A 'cheeky kick' is where an s piece blinks through a wall in a way that baffles novice players.
func test_s_cheeky_kick_r2() -> void:
	from_orientation = 1
	from_grid = [
		"     ",
		" s   ",
		" ss  ",
		"::s :",
		":  ::",
	]
	to_orientation = 2
	to_grid = [
		"     ",
		"     ",
		"     ",
		"::ss:",
		":ss::",
	]
	assert_kick()


func test_z_cheeky_kick_l2() -> void:
	from_orientation = 3
	from_grid = [
		"     ",
		"   z ",
		"  zz ",
		": z::",
		"::  :",
	]
	to_orientation = 2
	to_grid = [
		"     ",
		"     ",
		"     ",
		":zz::",
		"::zz:",
	]
	assert_kick()
