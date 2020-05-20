extends "res://src/test/test-piece-kicks.gd"
"""
Tests the u piece's kick behavior.
"""

func test_u_floorkick_cw() -> void:
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


func test_u_floorkick_ccw() -> void:
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


func test_u_rwallkick_cw() -> void:
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


func test_u_lwallkick_ccw() -> void:
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
func test_u_spire_kick_cw0() -> void:
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


func test_u_spire_kick_cw1() -> void:
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


func test_u_spire_kick_cw2() -> void:
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


func test_u_spire_kick_ccw0() -> void:
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


func test_u_spire_kick_ccw1() -> void:
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


func test_u_spire_kick_ccw2() -> void:
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


"""
'loutish kicks' and 'moutish kicks' demonstrate what happens when the U piece is boxed in by two corners
"""
func test_u_loutish_kick_cw0() -> void:
	from_grid = [
		"::   ",
		":u u ",
		" uuu:",
		"   ::",
	]
	to_grid = [
		"::   ",
		":uu  ",
		" u  :",
		" uu::",
	]
	_assert_kick()


func test_u_moutish_kick_ccw0() -> void:
	from_grid = [
		"   ::",
		" u u:",
		":uuu ",
		"::   ",
	]
	to_grid = [
		"   ::",
		"  uu:",
		":  u ",
		"::uu ",
	]
	_assert_kick()


func test_u_loutish_kick_cw1() -> void:
	from_grid = [
		"::  ",
		":uu ",
		" u  ",
		" uu:",
		"  ::",
	]
	to_grid = [
		"::  ",
		":uuu",
		" u u",
		"   :",
		"  ::",
	]
	_assert_kick()


func test_u_moutish_kick_ccw1() -> void:
	from_grid = [
		"  ::",
		" uu:",
		" u  ",
		":uu ",
		"::  ",
	]
	to_grid = [
		"  ::",
		"u u:",
		"uuu ",
		":   ",
		"::  ",
	]
	_assert_kick()


func test_u_loutish_kick_cw2() -> void:
	from_grid = [
		"::   ",
		":uuu ",
		" u u:",
		"   ::",
	]
	to_grid = [
		"::   ",
		":uu  ",
		"  u :",
		" uu::",
	]
	_assert_kick()


func test_u_moutish_kick_ccw2() -> void:
	from_grid = [
		"   ::",
		" uuu:",
		":u u ",
		"::   ",
	]
	to_grid = [
		"   ::",
		"  uu:",
		": u  ",
		"::uu ",
	]
	_assert_kick()


func test_u_loutish_kick_cw3() -> void:
	from_grid = [
		"::  ",
		":uu ",
		"  u ",
		" uu:",
		"  ::",
	]
	to_grid = [
		"::  ",
		":u u",
		" uuu",
		"   :",
		"  ::",
	]
	_assert_kick()


func test_u_moutish_kick_cw3() -> void:
	from_grid = [
		"  ::",
		" uu:",
		" u  ",
		":uu ",
		"::  ",
	]
	to_grid = [
		"  ::",
		"u u:",
		"uuu ",
		":   ",
		"::  ",
	]
	_assert_kick()

