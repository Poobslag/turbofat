extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
## Tests the u piece's kick behavior.

func test_floor_kick_2l() -> void:
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


func test_floor_kick_2r() -> void:
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


func test_wall_kick_r0_0() -> void:
	from_grid = [
		"    ",
		"uu  ",
		" u  ",
		"uu  ",
		"    ",
	]
	to_grid = [
		"    ",
		"uuu ",
		"u u ",
		"    ",
		"    ",
	]
	assert_kick()


func test_wall_kick_r0_1() -> void:
	from_grid = [
		"    ",
		"  uu",
		"   u",
		"  uu",
		"    ",
	]
	to_grid = [
		"    ",
		" uuu",
		" u u",
		"    ",
		"    ",
	]
	assert_kick()


func test_wall_kick_r2_0() -> void:
	from_grid = [
		"    ",
		"uu  ",
		" u  ",
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


func test_wall_kick_r2_1() -> void:
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


func test_wall_kick_l0_0() -> void:
	from_grid = [
		"    ",
		"uu  ",
		"u   ",
		"uu  ",
		"    ",
	]
	to_grid = [
		"    ",
		"uuu ",
		"u u ",
		"    ",
		"    ",
	]
	assert_kick()


func test_wall_kick_l0_1() -> void:
	from_grid = [
		"    ",
		"  uu",
		"  u ",
		"  uu",
		"    ",
	]
	to_grid = [
		"    ",
		" uuu",
		" u u",
		"    ",
		"    ",
	]
	assert_kick()


func test_wall_kick_l2_0() -> void:
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


func test_wall_kick_l2_1() -> void:
	from_grid = [
		"    ",
		"  uu",
		"  u ",
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


## A spire kick is when a u piece rotates while a block is in its gap.
func test_spire_kick_0r() -> void:
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


func test_spire_kick_r2() -> void:
	from_grid = [
		"     ",
		"uu   ",
		":u   ",
		"uu   ",
		"     ",
	]
	to_grid = [
		"     ",
		" u u ",
		":uuu ",
		"     ",
		"     ",
	]
	assert_kick()


func test_spire_kick_l0() -> void:
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


func test_spire_kick_0l() -> void:
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


func test_spire_kick_l2() -> void:
	from_grid = [
		"     ",
		"   uu",
		"   u:",
		"   uu",
		"     ",
	]
	to_grid = [
		"     ",
		" u u ",
		" uuu:",
		"     ",
		"     ",
	]
	assert_kick()


func test_spire_kick_r0() -> void:
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


## a 'diagonalnw kick' is when the u piece is boxed in by the nw/se corners
func test_diagonalnw_kick_0r() -> void:
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


func test_diagonalnw_kick_r2() -> void:
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


func test_diagonalnw_kick_2l() -> void:
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


func test_diagonalnw_kick_l0() -> void:
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


## a 'diagonalne kick' is when the u piece is boxed in by the ne/sw corners
func test_diagonalne_kick_0r() -> void:
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


func test_diagonalne_kick_r2() -> void:
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


func test_diagonalne_kick_2l() -> void:
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


func test_diagonalne_kick_l0() -> void:
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


## a 'shaft kick' is when the u piece rotates after being dropped down a narrow shaft
func test_shaft_kick_r0_0() -> void:
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


func test_shaft_kick_r0_1() -> void:
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


func test_shaft_kick_r2_0() -> void:
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


func test_shaft_kick_r2_1() -> void:
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


func test_shaft_kick_l0_0() -> void:
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


func test_shaft_kick_l0_1() -> void:
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


func test_shaft_kick_l2_0() -> void:
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


func test_shaft_kick_l2_1() -> void:
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


func test_flip_kick_rl_narrow() -> void:
	from_grid = [
		"  ",
		"uu",
		" u",
		"uu",
		"  ",
	]
	to_grid = [
		"  ",
		"uu",
		"u ",
		"uu",
		"  ",
	]
	assert_kick()


func test_flip_kick_rl_wide() -> void:
	from_grid = [
		"   ",
		" uu",
		"  u",
		" uu",
		"   ",
	]
	to_grid = [
		"   ",
		" uu",
		" u ",
		" uu",
		"   ",
	]
	assert_kick()


func test_flip_kick_02_narrow() -> void:
	from_grid = [
		"uuu",
		"u u",
	]
	to_grid = [
		"u u",
		"uuu",
	]
	assert_kick()


func test_flip_kick_02_wide() -> void:
	from_grid = [
		"   ",
		"uuu",
		"u u",
	]
	to_grid = [
		"   ",
		"u u",
		"uuu",
	]
	assert_kick()


## A spine flip is where the U piece flips, with its three central pieces remaining in place.
func test_spine_flip_02() -> void:
	from_grid = [
		" : ",
		"uuu",
		"u:u",
	]
	to_grid = [
		"u:u",
		"uuu",
		" : ",
	]
	assert_kick()


func test_spine_flip_rl() -> void:
	from_grid = [
		"uu ",
		":u:",
		"uu ",
	]
	to_grid = [
		" uu",
		":u:",
		" uu",
	]
	assert_kick()


func test_spine_flip_lr() -> void:
	from_grid = [
		" uu",
		":u:",
		" uu",
	]
	to_grid = [
		"uu ",
		":u:",
		"uu ",
	]
	assert_kick()


func test_spine_flip_20() -> void:
	from_grid = [
		"u:u",
		"uuu",
		" : ",
	]
	to_grid = [
		" : ",
		"uuu",
		"u:u",
	]
	assert_kick()


func test_snack_kick_2l() -> void:
	from_grid = [
		"     ",
		"u u :",
		"uuu::",
		"::  :",
	]
	to_grid = [
		"     ",
		"  uu:",
		"  u::",
		"::uu:",
	]
	assert_kick()


func test_snack_kick_2r() -> void:
	from_grid = [
		"     ",
		": u u",
		"::uuu",
		":  ::",
	]
	to_grid = [
		"     ",
		":uu  ",
		"::u  ",
		":uu::",
	]
	assert_kick()
