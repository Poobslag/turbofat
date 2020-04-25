extends "res://src/test/test-piece-kicks.gd"
"""
Tests the v piece's kick behavior.
"""

func test_v_climb_kick_cw_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		" v   ",
		" v:::",
	]
	to_grid = [
		"     ",
		" vvv ",
		"   v ",
		"   v ",
		"  :::",
	]
	_assert_kick()


func test_v_climb_kick_cw_1() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		" v ::",
		" v:::",
	]
	to_grid = [
		"     ",
		"vvv  ",
		"  v  ",
		"  v::",
		"  :::",
	]
	_assert_kick()


func test_v_climb_kick_cw_2() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		" v:::",
		" v:::",
	]
	to_grid = [
		"vvv  ",
		"  v  ",
		"  v  ",
		"  :::",
		"  :::",
	]
	_assert_kick()


func test_v_climb_kick_cw_3() -> void:
	from_grid = [
		"    ",
		"vvv ",
		"  v ",
		" :v:",
	]
	to_grid = [
		"   v",
		"   v",
		" vvv",
		" : :",
	]
	_assert_kick()


func test_v_climb_kick_cw_4() -> void:
	from_grid = [
		"    ",
		"vvv:",
		"  v ",
		" :v:",
	]
	to_grid = [
		"  v ",
		"  v ",
		"vvv ",
		" : :",
	]
	_assert_kick()


func test_v_climb_kick_ccw_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		"   v ",
		":::v ",
	]
	to_grid = [
		"     ",
		" vvv ",
		" v   ",
		" v   ",
		":::  ",
	]
	_assert_kick()


func test_v_climb_kick_ccw_1() -> void:
	from_grid = [
		"      ",
		"      ",
		" vvv  ",
		":: v  ",
		":::v  ",
	]
	to_grid = [
		"      ",
		"  vvv ",
		"  v   ",
		"::v   ",
		":::   ",
	]
	_assert_kick()


func test_v_climb_kick_ccw_2() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		":::v ",
		":::v ",
	]
	to_grid = [
		"  vvv",
		"  v  ",
		"  v  ",
		":::  ",
		":::  ",
	]
	_assert_kick()


func test_v_climb_kick_ccw_3() -> void:
	from_grid = [
		"    ",
		" vvv",
		" v  ",
		":v: ",
	]
	to_grid = [
		"v   ",
		"v   ",
		"vvv ",
		": : ",
	]
	_assert_kick()


func test_v_climb_kick_ccw_4() -> void:
	from_grid = [
		"    ",
		":vvv",
		" v  ",
		":v: ",
	]
	to_grid = [
		" v  ",
		" v  ",
		" vvv",
		": : ",
	]
	_assert_kick()


"""
A 'snack kick' is when a v piece rotates around an o piece to make a snack block.
"""
func test_v_snack_kick_cw() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		" v:: ",
		" v:: ",
	]
	to_grid = [
		"     ",
		"     ",
		"  vvv",
		"  ::v",
		"  ::v",
	]
	_assert_kick()


func test_v_snack_kick_ccw() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		" ::v ",
		" ::v ",
	]
	to_grid = [
		"     ",
		"     ",
		"vvv  ",
		"v::  ",
		"v::  ",
	]
	_assert_kick()


"""
The v piece can't technically wall kick, but it can kick against other blocks similar to a wall kick
"""
func test_v_wall_kick_cw_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		" v   ",
		" v ::",
	]
	to_grid = [
		"     ",
		"     ",
		"vvv  ",
		"  v  ",
		"  v::",
	]
	_assert_kick()


func test_v_wall_kick_cw_1() -> void:
	from_grid = [
		"    :",
		"    :",
		"  v :",
		"  v  ",
		"  vvv",
	]
	to_grid = [
		"    :",
		"    :",
		" vvv:",
		" v   ",
		" v   ",
	]
	_assert_kick()


func test_v_wall_kick_cw_2() -> void:
	from_grid = [
		"     ",
		"     ",
		"  vvv",
		"  v  ",
		"  v :",
	]
	to_grid = [
		"     ",
		"     ",
		" vvv ",
		"   v ",
		"   v:",
	]
	_assert_kick()


func test_v_wall_kick_cw_3() -> void:
	from_grid = [
		"     ",
		"     ",
		"vvv  ",
		"  v  ",
		": v  ",
	]
	to_grid = [
		"     ",
		"     ",
		"   v ",
		"   v ",
		":vvv ",
	]
	_assert_kick()


func test_v_wall_kick_cw_4() -> void:
	from_grid = [
		":    ",
		":    ",
		": v  ",
		"  v  ",
		"vvv  ",
	]
	to_grid = [
		":    ",
		":    ",
		":v   ",
		" v   ",
		" vvv ",
	]
	_assert_kick()


func test_v_wall_kick_ccw_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" vvv ",
		"   v ",
		":: v ",
	]
	to_grid = [
		"     ",
		"     ",
		"  vvv",
		"  v  ",
		"::v  ",
	]
	_assert_kick()


func test_v_wall_kick_ccw_1() -> void:
	from_grid = [
		":    ",
		":    ",
		": v  ",
		"  v  ",
		"vvv  ",
	]
	to_grid = [
		":    ",
		":    ",
		":vvv ",
		"   v ",
		"   v ",
	]
	_assert_kick()


func test_v_wall_kick_ccw_2() -> void:
	from_grid = [
		"     ",
		"     ",
		"vvv  ",
		"  v  ",
		": v  ",
	]
	to_grid = [
		"     ",
		"     ",
		" vvv ",
		" v   ",
		":v   ",
	]
	_assert_kick()



func test_v_wall_kick_ccw_3() -> void:
	from_grid = [
		"     ",
		"     ",
		"  vvv",
		"  v  ",
		"  v :",
	]
	to_grid = [
		"     ",
		"     ",
		" v   ",
		" v   ",
		" vvv:",
	]
	_assert_kick()


func test_v_wall_kick_ccw_4() -> void:
	from_grid = [
		"    :",
		"    :",
		"  v :",
		"  v  ",
		"  vvv",
	]
	to_grid = [
		"    :",
		"    :",
		"   v:",
		"   v ",
		" vvv ",
	]
	_assert_kick()


"""
A ritzy kick is when the hinge of the v piece pivots one square diagonally.
"""
func test_ritzy_kick_cw_0() -> void:
	from_grid = [
		"    ",
		"  v ",
		": v ",
		"vvv:",
	]
	to_grid = [
		" v  ",
		" v  ",
		":vvv",
		"   :",
	]
	_assert_kick()


func test_ritzy_kick_cw_1() -> void:
	from_grid = [
		"v ::",
		"v   ",
		"vvv ",
		":   ",
	]
	to_grid = [
		"  ::",
		" vvv",
		" v  ",
		":v  ",
	]
	_assert_kick()


func test_ritzy_kick_cw_2() -> void:
	from_grid = [
		":vvv",
		" v :",
		" v  ",
		"    ",
	]
	to_grid = [
		":   ",
		"vvv:",
		"  v ",
		"  v ",
	]
	_assert_kick()


func test_ritzy_kick_cw_3() -> void:
	from_grid = [
		"   :",
		" vvv",
		"   v",
		" ::v",
	]
	to_grid = [
		"  v:",
		"  v ",
		"vvv ",
		" :: ",
	]
	_assert_kick()


func test_ritzy_kick_ccw_0() -> void:
	from_grid = [
		"    ",
		" v  ",
		" v :",
		":vvv",
	]
	to_grid = [
		"  v ",
		"  v ",
		"vvv:",
		":   ",
	]
	_assert_kick()


func test_ritzy_kick_ccw_1() -> void:
	from_grid = [
		":: v",
		"   v",
		" vvv",
		"   :",
	]
	to_grid = [
		"::  ",
		"vvv ",
		"  v ",
		"  v:",
	]
	_assert_kick()


func test_ritzy_kick_ccw_2() -> void:
	from_grid = [
		"vvv:",
		": v ",
		"  v ",
		"    ",
	]
	to_grid = [
		"   :",
		":vvv",
		" v  ",
		" v  ",
	]
	_assert_kick()


func test_ritzy_kick_ccw_3() -> void:
	from_grid = [
		":   ",
		"vvv ",
		"v   ",
		"v:: ",
	]
	to_grid = [
		":v  ",
		" v  ",
		" vvv",
		" :: ",
	]
	_assert_kick()


"""
A plant kick is when the v piece pivots around its hinge like a t block. This is disorienting and should be a last
resort.
"""
func test_plant_kick_cw_0() -> void:
	from_grid = [
		"::   ",
		"     ",
		"  vvv",
		"::v::",
		"::v::",
	]
	to_grid = [
		"::   ",
		"     ",
		"vvv  ",
		"::v::",
		"::v::",
	]
	_assert_kick()


func test_plant_kick_cw_1() -> void:
	from_grid = [
		"     ",
		"     ",
		"vvv  ",
		"::v::",
		"::v::",
	]
	to_grid = [
		"  v  ",
		"  v  ",
		"vvv  ",
		":: ::",
		":: ::",
	]
	_assert_kick()


func test_plant_kick_cw_2() -> void:
	from_grid = [
		"::v::",
		"::v::",
		"vvv  ",
	]
	to_grid = [
		"::v::",
		"::v::",
		"  vvv",
	]
	_assert_kick()


func test_plant_kick_cw_3() -> void:
	from_grid = [
		"  v::",
		"::v::",
		"  vvv",
		"   ::",
		"   ::",
	]
	to_grid = [
		"   ::",
		":: ::",
		"  vvv",
		"  v::",
		"  v::",
	]
	_assert_kick()


func test_plant_kick_ccw_0() -> void:
	from_grid = [
		"   ::",
		"     ",
		"vvv  ",
		"::v::",
		"::v::",
	]
	to_grid = [
		"   ::",
		"     ",
		"  vvv",
		"::v::",
		"::v::",
	]
	_assert_kick()


func test_plant_kick_ccw_1() -> void:
	from_grid = [
		"     ",
		"     ",
		"  vvv",
		"::v::",
		"::v::",
	]
	to_grid = [
		"  v  ",
		"  v  ",
		"  vvv",
		":: ::",
		":: ::",
	]
	_assert_kick()


func test_plant_kick_ccw_2() -> void:
	from_grid = [
		"::v::",
		"::v::",
		"  vvv",
	]
	to_grid = [
		"::v::",
		"::v::",
		"vvv  ",
	]
	_assert_kick()


func test_plant_kick_ccw_3() -> void:
	from_grid = [
		"::v  ",
		"::v::",
		"vvv  ",
		"::   ",
		"::   ",
	]
	to_grid = [
		"::   ",
		":: ::",
		"vvv  ",
		"::v::",
		"::v::",
	]
	_assert_kick()
