extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
## Tests the T-Block's kick behavior.

func test_floor_kick_0r() -> void:
	from_grid = [
		"     ",
		"     ",
		"  t  ",
		" ttt "
	]
	to_grid = [
		"     ",
		" t   ",
		" tt  ",
		" t   "
	]
	assert_kick()


func test_floor_kick_0l() -> void:
	from_grid = [
		"     ",
		"     ",
		"  t  ",
		" ttt "
	]
	to_grid = [
		"     ",
		"   t ",
		"  tt ",
		"   t "
	]
	assert_kick()


func test_floor_kick_02() -> void:
	from_grid = [
		"     ",
		"     ",
		"  t  ",
		" ttt "
	]
	to_grid = [
		"     ",
		"     ",
		" ttt ",
		"  t  "
	]
	assert_kick()


func test_wall_kick_r0() -> void:
	from_grid = [
		"     ",
		"t    ",
		"tt   ",
		"t    ",
		"     "
	]
	to_grid = [
		"     ",
		" t   ",
		"ttt  ",
		"     ",
		"     "
	]
	assert_kick()


func test_wall_kick_r2() -> void:
	from_grid = [
		"     ",
		"t    ",
		"tt   ",
		"t    ",
		"     "
	]
	to_grid = [
		"     ",
		"     ",
		"ttt  ",
		" t   ",
		"     "
	]
	assert_kick()


func test_wall_kick_l0() -> void:
	from_grid = [
		"     ",
		"    t",
		"   tt",
		"    t",
		"     "
	]
	to_grid = [
		"     ",
		"   t ",
		"  ttt",
		"     ",
		"     "
	]
	assert_kick()


func test_wall_kick_l2() -> void:
	from_grid = [
		"     ",
		"    t",
		"   tt",
		"    t",
		"     "
	]
	to_grid = [
		"     ",
		"     ",
		"  ttt",
		"   t ",
		"     "
	]
	assert_kick()


## A rose kick is when the T-Block pivots around the middle of its three extrusions.
##
##  T  <--- it rotates around this part. doesn't it look like a rose?
## ttt
func test_rose_kick_r0() -> void:
	from_grid = [
		"   ",
		"t  ",
		"tt:",
		"t  ",
	]
	to_grid = [
		"   ",
		"   ",
		" t:",
		"ttt",
	]
	assert_kick()


func test_rose_kick_2r() -> void:
	from_grid = [
		":: ",
		"ttt",
		" t ",
		" : ",
	]
	to_grid = [
		":: ",
		"t  ",
		"tt ",
		"t: ",
	]
	assert_kick()


func test_rose_kick_2l() -> void:
	from_grid = [
		" ::",
		"ttt",
		" t ",
		" : ",
	]
	to_grid = [
		" ::",
		"  t",
		" tt",
		" :t",
	]
	assert_kick()


func test_rose_kick_l0() -> void:
	from_grid = [
		"   ",
		"  t",
		":tt",
		"  t",
	]
	to_grid = [
		"   ",
		"   ",
		":t ",
		"ttt",
	]
	assert_kick()


## A duck kick is when the T-Block tries to rotate an extrusion towards its flat side, and gets shoved away.
##
## This does not replace the usual floor kick, but acts as a replacement if the floor kick fails.
func test_duck_kick_0r() -> void:
	from_grid = [
		"     ",
		"::   ",
		"  t  ",
		" ttt ",
	]
	to_grid = [
		"     ",
		"::t  ",
		"  tt ",
		"  t  "
	]
	assert_kick()


func test_duck_kick_0l() -> void:
	from_grid = [
		"     ",
		"   ::",
		"  t  ",
		" ttt ",
	]
	to_grid = [
		"     ",
		"  t::",
		" tt  ",
		"  t  "
	]
	assert_kick()


func test_duck_kick_r0() -> void:
	from_grid = [
		"    ",
		" t  ",
		":tt ",
		":t: "
	]
	to_grid = [
		"    ",
		"  t ",
		":ttt",
		": : "
	]
	assert_kick()


func test_duck_kick_r2() -> void:
	from_grid = [
		"    ",
		" t  ",
		":tt ",
		":t  "
	]
	to_grid = [
		"    ",
		"    ",
		":ttt",
		": t "
	]
	assert_kick()


func test_duck_kick_2r() -> void:
	from_grid = [
		"::  ",
		"ttt ",
		":t :",
		": ::"
	]
	to_grid = [
		"::  ",
		" t  ",
		":tt:",
		":t::"
	]
	assert_kick()


func test_duck_kick_2l() -> void:
	from_grid = [
		"  ::",
		" ttt",
		": t:",
		":: :"
	]
	to_grid = [
		"  ::",
		"  t ",
		":tt:",
		"::t:"
	]
	assert_kick()


func test_duck_kick_l0() -> void:
	from_grid = [
		"    ",
		"  t ",
		" tt:",
		" :t:"
	]
	to_grid = [
		"    ",
		" t  ",
		"ttt:",
		" : :"
	]
	assert_kick()


func test_duck_kick_l2() -> void:
	from_grid = [
		"    ",
		"  t ",
		" tt:",
		"  t:"
	]
	to_grid = [
		"    ",
		"    ",
		"ttt:",
		" t :"
	]
	assert_kick()


func test_climb_r0() -> void:
	from_grid = [
		"     ",
		"  t  ",
		"::tt:",
		"::t::",
	]
	to_grid = [
		"  t  ",
		" ttt ",
		"::  :",
		":: ::"
	]
	assert_kick()


func test_climb_r0_failed() -> void:
	from_grid = [
		"    ",
		" t  ",
		":tt ",
		":t::",
	]
	to_grid = [
		"    ",
		"  t ",
		":ttt",
		": ::"
	]
	assert_kick()


func test_climb_l0() -> void:
	from_grid = [
		"     ",
		"  t  ",
		":tt::",
		"::t::",
	]
	to_grid = [
		"  t  ",
		" ttt ",
		":  ::",
		":: ::"
	]
	assert_kick()


func test_climb_l0_failed() -> void:
	from_grid = [
		"    ",
		"  t ",
		" tt:",
		"::t:",
	]
	to_grid = [
		"    ",
		" t  ",
		"ttt:",
		":: :"
	]
	assert_kick()
