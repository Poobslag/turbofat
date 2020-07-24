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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


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
	assert_kick()


func test_q_climb_0r_failed() -> void:
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
	assert_kick()


func test_p_climb_0l_failed() -> void:
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
	assert_kick()


func test_p_climb_r0() -> void:
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
	assert_kick()


func test_q_climb_l0_failed() -> void:
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
	assert_kick()


"""
A 'bump kick' is when the bulky part of a p/q piece bumps into a block and gets nudged out of the way
"""
func test_p_bump_kick_0r() -> void:
	from_grid = [
		"  :::",
		" ppp:",
		"  pp:",
		"   ::",
	]
	to_grid = [
		"  :::",
		"  p :",
		" pp :",
		" pp::",
	]
	assert_kick()


func test_p_bump_kick_r2() -> void:
	from_grid = [
		"     ",
		"  p  ",
		" pp: ",
		":pp: ",
	]
	to_grid = [
		"     ",
		"pp   ",
		"ppp: ",
		":  : ",
	]
	assert_kick()


func test_p_bump_kick_2l() -> void:
	from_grid = [
		"     ",
		"::   ",
		":pp  ",
		":ppp ",
	]
	to_grid = [
		"     ",
		"::pp ",
		": pp ",
		": p  ",
	]
	assert_kick()


func test_p_bump_kick_l0() -> void:
	from_grid = [
		" ::::",
		" :pp:",
		" :pp ",
		"  p  ",
	]
	to_grid = [
		" ::::",
		" :  :",
		" :ppp",
		"   pp",
	]
	assert_kick()


func test_q_bump_kick_0l() -> void:
	from_grid = [
		":::  ",
		":qqq ",
		":qq  ",
		"::   ",
	]
	to_grid = [
		":::  ",
		": q  ",
		": qq ",
		"::qq ",
	]
	assert_kick()


func test_q_bump_kick_l2() -> void:
	from_grid = [
		"     ",
		"  q  ",
		" :qq ",
		" :qq:",
	]
	to_grid = [
		"     ",
		"   qq",
		" :qqq",
		" :  :",
	]
	assert_kick()


func test_q_bump_kick_2r() -> void:
	from_grid = [
		"     ",
		"   ::",
		"  qq:",
		" qqq:",
	]
	to_grid = [
		"     ",
		" qq::",
		" qq :",
		"  q :",
	]
	assert_kick()


func test_q_bump_kick_r0() -> void:
	from_grid = [
		":::: ",
		":qq: ",
		" qq: ",
		"  q  ",
	]
	to_grid = [
		":::: ",
		":  : ",
		"qqq: ",
		"qq   ",
	]
	assert_kick()
