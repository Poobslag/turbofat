extends "res://src/test/test-piece-kicks.gd"
"""
Tests the u piece's kick behavior.
"""


"""
A rose kick is when the t piece pivots around the middle of its three extrusions.

 T  <--- it rotates around this part. doesn't it look like a rose?
ttt
"""
func test_rose_kick_left() -> void:
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


func test_rose_kick_down0() -> void:
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


func test_rose_kick_down1() -> void:
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


func test_rose_kick_right() -> void:
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


"""
A duck kick is when the T-piece tries to rotate an extrusion towards its flat side, and gets shoved away.

This does not replace the usual floor kick, but acts as a replacement if the floor kick fails.
"""
func test_duck_kick_down0() -> void:
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


func test_duck_kick_down1() -> void:
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


func test_duck_kick_left0() -> void:
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


func test_duck_kick_left1() -> void:
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


func test_duck_kick_right0() -> void:
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


func test_duck_kick_right1() -> void:
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


func test_duck_kick_up0() -> void:
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


func test_duck_kick_up1() -> void:
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


func test_floorkick_cw() -> void:
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


func test_floorkick_ccw() -> void:
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


func test_lwallkick0() -> void:
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


func test_lwallkick1() -> void:
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


func test_rwallkick0() -> void:
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


func test_rwallkick1() -> void:
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
