extends "res://src/test/test-piece-kicks.gd"
"""
Tests the u piece's kick behavior.
"""

func test_u_floor_kick_cw() -> void:
	from_grid = [
		"     ",
		"     ",
		" u u ",
		" uuu ",
	]
	to_grid = [
		"     ",
		" uu  ",
		" u   ",
		" uu  ",
	]
	_assert_kick()


func test_u_floor_kick_ccw() -> void:
	from_grid = [
		"     ",
		"     ",
		" u u ",
		" uuu ",
	]
	to_grid = [
		"     ",
		"  uu ",
		"   u ",
		"  uu ",
	]
	_assert_kick()


func test_u_wall_kick_cw() -> void:
	from_grid = [
		"    ",
		"  uu",
		"   u",
		"  uu",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		" u u",
		" uuu",
		"    ",
	]
	_assert_kick()


func test_u_wall_kick_ccw() -> void:
	from_grid = [
		"    ",
		"uu  ",
		"u   ",
		"uu  ",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		"u u ",
		"uuu ",
		"    ",
	]
	_assert_kick()


"""
A spire kick is when a u piece rotates while a block is in its gap.
"""
func test_u_spire_kick_cw_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" uuu ",
		" u:u ",
	]
	to_grid = [
		"  uu ",
		"   u ",
		"  uu ",
		"  :  ",
	]
	_assert_kick()


func test_u_spire_kick_cw_1() -> void:
	from_grid = [
		"     ",
		"uu   ",
		":u   ",
		"uu   ",
		"     ",
	]
	to_grid = [
		"u u  ",
		"uuu  ",
		":    ",
		"     ",
		"     ",
	]
	_assert_kick()


func test_u_spire_kick_cw_2() -> void:
	from_grid = [
		"     ",
		"   uu",
		"   u:",
		"   uu",
		"     ",
	]
	to_grid = [
		"  uuu",
		"  u u",
		"    :",
		"     ",
		"     ",
	]
	_assert_kick()


func test_u_spire_kick_ccw_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" uuu ",
		" u:u ",
	]
	to_grid = [
		" uu  ",
		" u   ",
		" uu  ",
		"  :  ",
	]
	_assert_kick()


func test_u_spire_kick_ccw_1() -> void:
	from_grid = [
		"     ",
		"   uu",
		"   u:",
		"   uu",
		"     ",
	]
	to_grid = [
		"  u u",
		"  uuu",
		"    :",
		"     ",
		"     ",
	]
	_assert_kick()


func test_u_spire_kick_ccw_2() -> void:
	from_grid = [
		"     ",
		"uu   ",
		":u   ",
		"uu   ",
		"     ",
	]
	to_grid = [
		"uuu  ",
		"u u  ",
		":    ",
		"     ",
		"     ",
	]
	_assert_kick()
