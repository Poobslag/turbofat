extends "res://src/test/test-piece-kicks.gd"
"""
Tests the p/q piece's kick behavior.
"""

func test_p_floor_kick_cw() -> void:
	from_grid = [
		"     ",
		" ppp ",
		"  pp ",
	]
	to_grid = [
		"   p ",
		"  pp ",
		"  pp ",
	]
	_assert_kick()


func test_p_floor_kick_ccw() -> void:
	from_grid = [
		"     ",
		" ppp ",
		"  pp ",
	]
	to_grid = [
		" pp  ",
		" pp  ",
		" p   ",
	]
	_assert_kick()


func test_q_floor_kick_cw() -> void:
	from_grid = [
		"     ",
		" qqq ",
		" qq  ",
	]
	to_grid = [
		"  qq ",
		"  qq ",
		"   q ",
	]
	_assert_kick()


func test_q_floor_kick_ccw() -> void:
	from_grid = [
		"     ",
		" qqq ",
		" qq  ",
	]
	to_grid = [
		" q   ",
		" qq  ",
		" qq  ",
	]
	_assert_kick()


func test_p_wall_kick_cw() -> void:
	from_grid = [
		"    ",
		"  pp",
		"  pp",
		"  p ",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		" ppp",
		"  pp",
		"    ",
	]
	_assert_kick()


func test_p_wall_kick_ccw() -> void:
	from_grid = [
		"    ",
		" p  ",
		"pp  ",
		"pp  ",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		"ppp ",
		" pp ",
		"    ",
	]
	_assert_kick()


func test_q_wall_kick_cw() -> void:
	from_grid = [
		"    ",
		"  q ",
		"  qq",
		"  qq",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		" qqq",
		" qq ",
		"    ",
	]
	_assert_kick()


func test_q_wall_kick_ccw() -> void:
	from_grid = [
		"    ",
		"qq  ",
		"qq  ",
		" q  ",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		"qqq ",
		"qq  ",
		"    ",
	]
	_assert_kick()


"""
A 'pump kick' is when the nub of a p/q piece swings into a gap, while the other 4 blocks remain in place
"""
func test_p_pump_kick_0() -> void:
	from_grid = [
		" : :",
		" pp ",
		" ppp",
		"  ::"]
	to_grid = [
		" :p:",
		" pp ",
		" pp ",
		"  ::"]
	_assert_kick()


func test_p_pump_kick_1() -> void:
	from_grid = [
		"    ",
		"  p ",
		" pp:",
		":pp "]
	to_grid = [
		"    ",
		"    ",
		" pp:",
		":ppp"]
	_assert_kick()


func test_q_pump_kick_0() -> void:
	from_grid = [
		"    ",
		" q  ",
		":qq ",
		" qq:"]
	to_grid = [
		"    ",
		"    ",
		":qq ",
		"qqq:"]
	_assert_kick()


func test_q_pump_kick_1() -> void:
	from_grid = [
		": : ",
		" qq ",
		"qqq ",
		"::  "]
	to_grid = [
		":q: ",
		" qq ",
		" qq ",
		"::  "]
	_assert_kick()


"""
A 'murky kick' is when the nub of a p/q piece swings into a faraway gap, pulling the piece with it
"""
func test_p_murky_kick_0() -> void:
	from_grid = [
		" :::",
		" pp ",
		" ppp",
		" : :"]
	to_grid = [
		" :::",
		"  pp",
		"  pp",
		" :p:"]
	_assert_kick()


func test_p_murky_kick_1() -> void:
	from_grid = [
		": : ",
		"ppp ",
		" pp ",
		"::: "]
	to_grid = [
		":p: ",
		"pp  ",
		"pp  ",
		"::: "]
	_assert_kick()


func test_p_murky_kick_2() -> void:
	from_grid = [
		" : :",
		" ppp",
		"  pp",
		"  ::"]
	to_grid = [
		" :p:",
		" pp ",
		" pp ",
		"  ::"]
	_assert_kick()


func test_q_murky_kick_0() -> void:
	from_grid = [
		"::: ",
		" qq ",
		"qqq ",
		": : "]
	to_grid = [
		"::: ",
		"qq  ",
		"qq  ",
		":q: "]
	_assert_kick()


func test_q_murky_kick_1() -> void:
	from_grid = [
		" : :",
		" qqq",
		" qq ",
		" :::"]
	to_grid = [
		" :q:",
		"  qq",
		"  qq",
		" :::"]
	_assert_kick()


func test_q_murky_kick_2() -> void:
	from_grid = [
		": : ",
		"qqq ",
		"qq  ",
		"::  "]
	to_grid = [
		":q: ",
		" qq ",
		" qq ",
		"::  "]
	_assert_kick()


func test_p_climb_kick_0() -> void:
	from_grid = [
		"     ",
		"     ",
		"     ",
		":: p ",
		"::pp ",
		"::pp "]
	to_grid = [
		"     ",
		"     ",
		" ppp ",
		"::pp ",
		"::   ",
		"::   "]
	_assert_kick()


func test_p_climb_kick_1() -> void:
	from_grid = [
		"     ",
		"     ",
		" ppp ",
		"::pp ",
		"::   ",
		"::   "]
	to_grid = [
		" pp  ",
		" pp  ",
		" p   ",
		"::   ",
		"::   ",
		"::   "]
	_assert_kick()


func test_q_climb_kick_0() -> void:
	from_grid = [
		"     ",
		"     ",
		"     ",
		" q ::",
		" qq::",
		" qq::"]
	to_grid = [
		"     ",
		"     ",
		" qqq ",
		" qq::",
		"   ::",
		"   ::"]
	_assert_kick()


func test_q_climb_kick_1() -> void:
	from_grid = [
		"     ",
		"     ",
		" qqq ",
		" qq::",
		"   ::",
		"   ::"]
	to_grid = [
		"  qq ",
		"  qq ",
		"   q ",
		"   ::",
		"   ::",
		"   ::"]
	_assert_kick()
