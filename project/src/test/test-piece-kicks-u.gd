extends "res://src/test/test-piece-kicks.gd"
"""
Tests the u piece's kick behavior.
"""

func test_floorkick_cw() -> void:
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
	assert_kick()


func test_floorkick_ccw() -> void:
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
	assert_kick()


func test_rwallkick_cw() -> void:
	from_grid = [
		"    ",
		"  uu",
		"   u",
		"  uu",
		"    ",
	]
	to_grid = [
		"    ",
		" u u",
		" uuu",
		"    ",
		"    ",
	]
	assert_kick()


func test_lwallkick_ccw() -> void:
	from_grid = [
		"    ",
		"uu  ",
		"u   ",
		"uu  ",
		"    ",
	]
	to_grid = [
		"    ",
		"u u ",
		"uuu ",
		"    ",
		"    ",
	]
	assert_kick()


"""
A spire kick is when a u piece rotates while a block is in its gap.
"""
func test_spire_kick_cw0() -> void:
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
	assert_kick()


func test_spire_kick_cw1() -> void:
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
	assert_kick()


func test_spire_kick_cw2() -> void:
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
	assert_kick()


func test_spire_kick_ccw0() -> void:
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
	assert_kick()


func test_spire_kick_ccw1() -> void:
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
	assert_kick()


func test_spire_kick_ccw2() -> void:
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
	assert_kick()


"""
a 'diagonalnw kick' is when the u piece is boxed in by the nw/se corners
"""
func test_diagonalnw_kick_ur() -> void:
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
	assert_kick()


func test_diagonalnw_kick_rd() -> void:
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
	assert_kick()


func test_diagonalnw_kick_dl() -> void:
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
	assert_kick()


func test_diagonalnw_kick_lu() -> void:
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
	assert_kick()


"""
a 'diagonalne kick' is when the u piece is boxed in by the ne/sw corners
"""
func test_diagonalne_kick_ur() -> void:
	from_grid = [
		"   ::",
		" u u:",
		":uuu ",
		"::   ",
	]
	to_grid = [
		"   ::",
		"  uu:",
		": u  ",
		"::uu ",
	]
	assert_kick()


func test_diagonalne_kick_rd() -> void:
	from_grid = [
		"  ::",
		" uu:",
		" u  ",
		":uu ",
		"::  ",
	]
	to_grid = [
		"  ::",
		"uuu:",
		"u u ",
		":   ",
		"::  ",
	]
	assert_kick()


func test_diagonalne_kick_dl() -> void:
	from_grid = [
		"   ::",
		" uuu:",
		":u u ",
		"::   ",
	]
	to_grid = [
		"   ::",
		"  uu:",
		":  u ",
		"::uu ",
	]
	assert_kick()


func test_diagonalne_kick_lu() -> void:
	from_grid = [
		"  ::",
		" uu:",
		"  u ",
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
	assert_kick()


"""
a 'shaft kick' is when the u piece rotates after being dropped down a narrow shaft
"""
func test_shaft_kick_lu0() -> void:
	from_grid = [
		"  ::",
		"uu::",
		" u  ",
		"uu  ",
	]
	to_grid = [
		"  ::",
		"  ::",
		"u u ",
		"uuu ",
	]
	assert_kick()


func test_shaft_kick_lu1() -> void:
	from_grid = [
		"::  ",
		"::uu",
		"   u",
		"  uu",
	]
	to_grid = [
		"::  ",
		"::  ",
		" u u",
		" uuu",
	]
	assert_kick()


func test_shaft_kick_ld0() -> void:
	from_grid = [
		"  ::",
		"uu::",
		" u  ",
		"uu  ",
	]
	to_grid = [
		"  ::",
		"  ::",
		"uuu ",
		"u u ",
	]
	assert_kick()


func test_shaft_kick_ld1() -> void:
	from_grid = [
		"::  ",
		"::uu",
		"   u",
		"  uu",
	]
	to_grid = [
		"::  ",
		"::  ",
		" uuu",
		" u u",
	]
	assert_kick()

func test_shaft_kick_ru0() -> void:
	from_grid = [
		"  ::",
		"uu::",
		"u   ",
		"uu  ",
	]
	to_grid = [
		"  ::",
		"  ::",
		"u u ",
		"uuu ",
	]
	assert_kick()


func test_shaft_kick_ru1() -> void:
	from_grid = [
		"::  ",
		"::uu",
		"  u ",
		"  uu",
	]
	to_grid = [
		"::  ",
		"::  ",
		" u u",
		" uuu",
	]
	assert_kick()


func test_shaft_kick_rd0() -> void:
	from_grid = [
		"  ::",
		"uu::",
		"u   ",
		"uu  ",
	]
	to_grid = [
		"  ::",
		"  ::",
		"uuu ",
		"u u ",
	]
	assert_kick()


func test_shaft_kick_rd1() -> void:
	from_grid = [
		"::  ",
		"::uu",
		"  u ",
		"  uu",
	]
	to_grid = [
		"::  ",
		"::  ",
		" uuu",
		" u u",
	]
	assert_kick()
