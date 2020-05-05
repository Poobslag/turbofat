extends "res://src/test/test-piece-kicks.gd"
"""
Tests the p/q piece's kick behavior.
"""

func test_p_floorkick_cw() -> void:
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


func test_p_floorkick_ccw() -> void:
	from_grid = [
		"     ",
		" ppp ",
		"  pp ",
	]
	to_grid = [
		"  pp ",
		"  pp ",
		"  p  ",
	]
	_assert_kick()


func test_q_floorkick_cw() -> void:
	from_grid = [
		"     ",
		" qqq ",
		" qq  ",
	]
	to_grid = [
		" qq  ",
		" qq  ",
		"  q  ",
	]
	_assert_kick()


func test_q_floorkick_ccw() -> void:
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


func test_p_rwallkick_cw() -> void:
	from_grid = [
		"    ",
		"  pp",
		"  pp",
		"  p ",
		"    ",
	]
	to_grid = [
		"    ",
		" ppp",
		"  pp",
		"    ",
		"    ",
	]
	_assert_kick()


func test_p_lwallkick_ccw() -> void:
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


func test_q_rwallkick_cw() -> void:
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


func test_q_lwallkick_ccw() -> void:
	from_grid = [
		"    ",
		"qq  ",
		"qq  ",
		" q  ",
		"    ",
	]
	to_grid = [
		"    ",
		"qqq ",
		"qq  ",
		"    ",
		"    ",
	]
	_assert_kick()


"""
A 'pump kick' is when the nub of a p/q piece swings into a gap, while the other 4 blocks remain in place
"""
func test_p_pump_kick0() -> void:
	from_grid = [
		"    ",
		"  p ",
		" pp:",
		":pp ",
	]
	to_grid = [
		"    ",
		"    ",
		" pp:",
		":ppp",
	]
	_assert_kick()


func test_p_pump_kick1() -> void:
	from_grid = [
		"    ",
		": p ",
		" pp ",
		":pp "]
	to_grid = [
		"    ",
		":   ",
		"ppp ",
		":pp "]
	_assert_kick()


func test_p_pump_kick2() -> void:
	from_grid = [
		"    ",
		" pp:",
		" pp ",
		" p::",
	]
	to_grid = [
		"    ",
		" pp:",
		" ppp",
		"  ::",
	]
	_assert_kick()


func test_p_pump_kick3() -> void:
	from_grid = [
		"    ",
		":   ",
		" pp ",
		":pp:",
		":p::",
	]
	to_grid = [
		"    ",
		":   ",
		"ppp ",
		":pp:",
		": ::",
	]
	_assert_kick()


func test_q_pump_kick0() -> void:
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


func test_q_pump_kick1() -> void:
	from_grid = [
		"    ",
		" q :",
		" qq ",
		" qq:"]
	to_grid = [
		"    ",
		"   :",
		" qqq",
		" qq:"]
	_assert_kick()


func test_q_pump_kick2() -> void:
	from_grid = [
		"    ",
		":qq ",
		" qq ",
		"::q ",
	]
	to_grid = [
		"    ",
		":qq ",
		"qqq ",
		"::  ",
	]
	_assert_kick()


func test_q_pump_kick3() -> void:
	from_grid = [
		"    ",
		":   ",
		" qq ",
		":qq:",
		"::q:",
	]
	to_grid = [
		"    ",
		"   :",
		" qqq",
		":qq:",
		":: :",
	]
	_assert_kick()


"""
A 'murky kick' is when the nub of a p/q piece swings into a faraway gap, pulling the piece with it
"""
func test_p_murky_kick0() -> void:
	# there's enough space above the piece to do a (0, -2) kick, which would be bad
	from_grid = [
		"    ",
		"    ",
		"  ::",
		" pp ",
		" ppp",
		" : :"]
	to_grid = [
		"    ",
		"    ",
		"  ::",
		"  pp",
		"  pp",
		" :p:"]
	_assert_kick()


func test_p_murky_kick1() -> void:
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


func test_p_murky_kick2() -> void:
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


func test_q_murky_kick0() -> void:
	# there's enough space above the piece to do a (0, -2) kick, which would be bad
	from_grid = [
		"    ",
		"    ",
		"::  ",
		" qq ",
		"qqq ",
		": : "]
	to_grid = [
		"    ",
		"    ",
		"::  ",
		"qq  ",
		"qq  ",
		":q: "]
	_assert_kick()


func test_q_murky_kick1() -> void:
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


func test_q_murky_kick2() -> void:
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


func test_p_climb_kick0() -> void:
	from_grid = [
		"     ",
		"     ",
		"     ",
		":: p ",
		"::pp ",
		"::pp:"]
	to_grid = [
		"     ",
		"     ",
		" ppp ",
		"::pp ",
		"::   ",
		"::  :"]
	_assert_kick()


func test_p_failed_climb_kick1() -> void:
	from_grid = [
		"     ",
		"     ",
		" ppp ",
		"::pp ",
		"::   ",
		"::   "]
	to_grid = [
		"     ",
		"     ",
		"  pp ",
		"::pp ",
		"::p  ",
		"::   "]
	_assert_kick()


func test_q_climb_kick0() -> void:
	from_grid = [
		"     ",
		"     ",
		"     ",
		" q ::",
		" qq::",
		":qq::"]
	to_grid = [
		"     ",
		"     ",
		" qqq ",
		" qq::",
		"   ::",
		":  ::"]
	_assert_kick()


func test_q_failed_climb_kick1() -> void:
	from_grid = [
		"     ",
		"     ",
		" qqq ",
		" qq::",
		"   ::",
		"   ::"]
	to_grid = [
		"     ",
		"     ",
		" qq  ",
		" qq::",
		"  q::",
		"   ::"]
	_assert_kick()
