extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
"""
Tests the j/l piece's kick behavior.
"""

func test_j_lwallkick_cw() -> void:
	from_grid = [
		"    ",
		"jj  ",
		"j   ",
		"j   ",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		"jjj ",
		"  j ",
		"    ",
	]
	assert_kick()


func test_j_lwallkick_ccw() -> void:
	from_grid = [
		"    ",
		"jj  ",
		"j   ",
		"j   ",
		"    ",
	]
	to_grid = [
		"    ",
		"j   ",
		"jjj ",
		"    ",
		"    ",
	]
	assert_kick()


func test_l_lwallkick_cw() -> void:
	from_grid = [
		"    ",
		"l   ",
		"l   ",
		"ll  ",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		"lll ",
		"l   ",
		"    ",
	]
	assert_kick()


func test_l_lwallkick_ccw() -> void:
	from_grid = [
		"    ",
		"l   ",
		"l   ",
		"ll  ",
		"    ",
	]
	to_grid = [
		"    ",
		"  l ",
		"lll ",
		"    ",
		"    ",
	]
	assert_kick()



func test_j_rwallkick_cw() -> void:
	from_grid = [
		"    ",
		"   j",
		"   j",
		"  jj",
		"    ",
	]
	to_grid = [
		"    ",
		" j  ",
		" jjj",
		"    ",
		"    ",
	]
	assert_kick()


func test_j_rwallkick_ccw() -> void:
	from_grid = [
		"    ",
		"   j",
		"   j",
		"  jj",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		" jjj",
		"   j",
		"    ",
	]
	assert_kick()


func test_l_rwallkick_cw() -> void:
	from_grid = [
		"    ",
		"  ll",
		"   l",
		"   l",
		"    ",
	]
	to_grid = [
		"    ",
		"   l",
		" lll",
		"    ",
		"    ",
	]
	assert_kick()


func test_l_rwallkick_ccw() -> void:
	from_grid = [
		"    ",
		"  ll",
		"   l",
		"   l",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		" lll",
		" l  ",
		"    ",
	]
	assert_kick()


func test_j_floorkick_cw() -> void:
	from_grid = [
		"     ",
		"     ",
		" j   ",
		" jjj ",
	]
	to_grid = [
		"     ",
		" jj  ",
		" j   ",
		" j   ",
	]
	assert_kick()


func test_j_floorkick_ccw() -> void:
	from_grid = [
		"     ",
		"     ",
		" j   ",
		" jjj ",
	]
	to_grid = [
		"     ",
		"   j ",
		"   j ",
		"  jj ",
	]
	assert_kick()


func test_l_floorkick_cw() -> void:
	from_grid = [
		"     ",
		"     ",
		"   l ",
		" lll ",
	]
	to_grid = [
		"     ",
		" l   ",
		" l   ",
		" ll  ",
	]
	assert_kick()


func test_l_floorkick_ccw() -> void:
	from_grid = [
		"     ",
		"     ",
		"   l ",
		" lll ",
	]
	to_grid = [
		"     ",
		"  ll ",
		"   l ",
		"   l ",
	]
	assert_kick()


"""
A 'vee kick' is when a J/L piece pivots like a V piece to hook its long end into a gap
"""
func test_j_vee_kick0() -> void:
	from_grid = [
		"   ::",
		"   : ",
		"  j: ",
		"  jjj",
	]
	to_grid = [
		"   ::",
		"   :j",
		"   :j",
		"   jj",
	]
	assert_kick()


"""
It would be nice if this kick worked, but it conflicts with the wall kicks and snack kicks.
"""
func test_j_vee_kick0_failed() -> void:
	from_grid = [
		"   ::",
		"   : ",
		"  j: ",
		"  jjj",
		"   ::",
	]
	to_grid = [
		"   ::",
		"   : ",
		"  j: ",
		"  j  ",
		" jj::",
	]
	assert_kick()


func test_j_vee_kick1() -> void:
	from_grid = [
		"     ",
		"  j  ",
		"::j  ",
		" jj  ",
	]
	to_grid = [
		"     ",
		"jjj  ",
		"::j  ",
		"     ",
	]
	assert_kick()


func test_j_vee_kick2() -> void:
	from_grid = [
		":    ",
		"jjj  ",
		" :j  ",
		" :   ",
	]
	to_grid = [
		":    ",
		"jj   ",
		"j:   ",
		"j:   ",
	]
	assert_kick()


func test_j_vee_kick3() -> void:
	from_grid = [
		"     ",
		"  jj ",
		": j::",
		": j  ",
	]
	to_grid = [
		"     ",
		"     ",
		": j::",
		": jjj",
	]
	assert_kick()


func test_l_vee_kick_cw0() -> void:
	from_grid = [
		"::   ",
		" :   ",
		" :l  ",
		"lll  ",
	]
	to_grid = [
		"::   ",
		"l:   ",
		"l:   ",
		"ll   ",
	]
	assert_kick()


"""
It would be nice if this kick worked, but it conflicts with the wall kicks and snack kicks.
"""
func test_l_vee_kick_cw0_failed() -> void:
	from_grid = [
		"::   ",
		" :   ",
		" :l  ",
		"lll  ",
		"::   ",
	]
	to_grid = [
		"::   ",
		" :   ",
		" :l  ",
		"  l  ",
		"::ll ",
	]
	assert_kick()


func test_l_vee_kick1() -> void:
	from_grid = [
		"     ",
		"  l  ",
		"  l::",
		"  ll ",
	]
	to_grid = [
		"     ",
		"  lll",
		"  l::",
		"     ",
	]
	assert_kick()


func test_l_vee_kick2() -> void:
	from_grid = [
		"    :",
		"  lll",
		"  l: ",
		"   : ",
	]
	to_grid = [
		"    :",
		"   ll",
		"   :l",
		"   :l",
	]
	assert_kick()


func test_l_vee_kick3() -> void:
	from_grid = [
		"     ",
		" ll  ",
		"::l :",
		"  l :",
	]
	to_grid = [
		"     ",
		"     ",
		"::l :",
		"lll :",
	]
	assert_kick()


"""
A 'gold kick' is when a J/L piece hooks its short end into a small gap
"""
func test_j_gold_kick0() -> void:
	from_grid = [
		"  :  ",
		"     ",
		"jjj  ",
		"::j::",
		":  ::",
	]
	to_grid = [
		"  :  ",
		"     ",
		"  j  ",
		"::j::",
		":jj::",
	]
	assert_kick()


func test_j_gold_kick1() -> void:
	from_grid = [
		"     ",
		"     ",
		"::j  ",
		" :j :",
		" jj :",
	]
	to_grid = [
		"     ",
		"     ",
		"::   ",
		"j:  :",
		"jjj :",
	]
	assert_kick()


func test_j_gold_kick2() -> void:
	from_grid = [
		"     ",
		"     ",
		"     ",
		"  j::",
		"  jjj",
	]
	to_grid = [
		"     ",
		"     ",
		"  jj ",
		"  j::",
		"  j  ",
	]
	assert_kick()


func test_j_gold_kick3() -> void:
	from_grid = [
		"     ",
		"     ",
		"  jj ",
		"  j: ",
		"  j::",
	]
	to_grid = [
		"     ",
		"     ",
		"  jjj",
		"   :j",
		"   ::",
	]
	assert_kick()


func test_l_gold_kick0() -> void:
	from_grid = [
		"  :  ",
		"     ",
		"  lll",
		"::l::",
		"::  :",
	]
	to_grid = [
		"  :  ",
		"     ",
		"  l  ",
		"::l::",
		"::ll:",
	]
	assert_kick()


func test_l_gold_kick1() -> void:
	from_grid = [
		"     ",
		"     ",
		"  l::",
		": l: ",
		": ll ",
	]
	to_grid = [
		"     ",
		"     ",
		"   ::",
		":  :l",
		": lll",
	]
	assert_kick()


func test_l_gold_kick2() -> void:
	from_grid = [
		"     ",
		"     ",
		"     ",
		"::l  ",
		"lll  ",
	]
	to_grid = [
		"     ",
		"     ",
		" ll  ",
		"::l  ",
		"  l  ",
	]
	assert_kick()


func test_l_gold_kick3() -> void:
	from_grid = [
		"     ",
		"::   ",
		" ll  ",
		" :l  ",
		"::l  ",
	]
	to_grid = [
		"     ",
		"     ",
		"lll  ",
		"l:   ",
		"::   ",
	]
	assert_kick()


"""
A 'golder kick' is when a J/L piece hooks its short end into a small gap from far away.
"""
func test_j_golder_kick() -> void:
	from_grid = [
		"     ",
		"   ::",
		"  jjj",
		" :  j",
		"::: :",
		"::  :",
	]
	to_grid = [
		"     ",
		"   ::",
		"     ",
		" : j ",
		":::j:",
		"::jj:",
	]
	assert_kick()


func test_l_golder_kick() -> void:
	from_grid = [
		"     ",
		"::   ",
		"lll  ",
		"l  : ",
		": :::",
		":  ::",
	]
	to_grid = [
		"     ",
		"::   ",
		"     ",
		" l : ",
		":l:::",
		":ll::",
	]
	assert_kick()


func test_j_climb_r2_0() -> void:
	from_grid = [
		"     ",
		"     ",
		"  jj ",
		": j::",
		": j::",
	]
	to_grid = [
		"     ",
		" jjj ",
		"   j ",
		":  ::",
		":  ::",
	]
	assert_kick()


func test_j_climb_r2_1() -> void:
	from_grid = [
		"    ",
		"    ",
		"jj  ",
		"j:::",
		"j:::",
	]
	to_grid = [
		"    ",
		"jjj ",
		"  j ",
		" :::",
		" :::",
	]
	assert_kick()


"""
It's important a j piece can climb onto an l piece against a wall, to start a jlo box
"""
func test_j_climb_r2_jlo() -> void:
	from_grid = [
		"     ",
		"   jj",
		"   j ",
		"   j:",
		"  :::",
	]
	to_grid = [
		"     ",
		"  jjj",
		"    j",
		"    :",
		"  :::",
	]
	assert_kick()


func test_j_climb_2l() -> void:
	from_grid = [
		"     ",
		"::   ",
		":jjj ",
		":::j ",
	]
	to_grid = [
		"  jj ",
		"::j  ",
		": j  ",
		":::  ",
	]
	assert_kick()


func test_j_climb_l0_0() -> void:
	from_grid = [
		"     ",
		"     ",
		"  j  ",
		": j::",
		":jj::",
	]
	to_grid = [
		"     ",
		" j   ",
		" jjj ",
		":  ::",
		":  ::",
	]
	assert_kick()


func test_j_climb_l0_1() -> void:
	from_grid = [
		"     ",
		"     ",
		"  j: ",
		": j::",
		":jj::",
	]
	to_grid = [
		"     ",
		"j    ",
		"jjj: ",
		":  ::",
		":  ::",
	]
	assert_kick()


func test_j_climb_l2() -> void:
	from_grid = [
		"     ",
		": j  ",
		"::j  ",
		":jj  ",
	]
	to_grid = [
		"     ",
		" jjj ",
		":: j ",
		":    ",
	]
	assert_kick()


func test_l_climb_r0_0() -> void:
	from_grid = [
		"     ",
		"     ",
		"  l  ",
		"::l :",
		"::ll:",
	]
	to_grid = [
		"     ",
		"   l ",
		" lll ",
		"::  :",
		"::  :",
	]
	assert_kick()


func test_l_climb_r0_1() -> void:
	from_grid = [
		"     ",
		"     ",
		" :l  ",
		"::l :",
		"::ll:",
	]
	to_grid = [
		"     ",
		"    l",
		" :lll",
		"::  :",
		"::  :",
	]
	assert_kick()


func test_l_climb_r2() -> void:
	from_grid = [
		"     ",
		"  l :",
		"  l::",
		"  ll:",
	]
	to_grid = [
		"     ",
		" lll:",
		" l ::",
		"    :",
	]
	assert_kick()


func test_l_climb_2l() -> void:
	from_grid = [
		"     ",
		"   ::",
		" lll:",
		" l:::",
	]
	to_grid = [
		" ll  ",
		"  l::",
		"  l :",
		"  :::",
	]
	assert_kick()


func test_l_climb_l2_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" ll  ",
		"::l :",
		"::l :",
	]
	to_grid = [
		"     ",
		" lll ",
		" l   ",
		"::  :",
		"::  :",
	]
	assert_kick()


func test_l_climb_l2_1() -> void:
	from_grid = [
		"    ",
		"    ",
		"  ll",
		":::l",
		":::l",
	]
	to_grid = [
		"    ",
		" lll",
		" l  ",
		"::: ",
		"::: ",
	]
	assert_kick()


"""
It's important an l piece can climb onto an j piece against a wall, to start a jlo box
"""
func test_l_climb_l2_jlo() -> void:
	from_grid = [
		"     ",
		"ll   ",
		" l   ",
		":l   ",
		":::  ",
	]
	to_grid = [
		"     ",
		"lll  ",
		"l    ",
		":    ",
		":::  ",
	]
	assert_kick()


"""
A 'hammer kick' is where the J piece pivots around its tip, like swinging a hammer.
"""
func test_j_hammer_kick0() -> void:
	from_grid = [
		"    ",
		"jj::",
		"j:::",
		"j  :",
		":: :",
	]
	to_grid = [
		"    ",
		"  ::",
		" :::",
		"jjj:",
		"::j:",
	]
	assert_kick()


func test_l_hammer_kick() -> void:
	from_grid = [
		"    ",
		"::ll",
		":::l",
		":  l",
		": ::",
	]
	to_grid = [
		"    ",
		"::  ",
		"::: ",
		":lll",
		":l::",
	]
	assert_kick()


"""
A plant kick is when the j/l piece pivots around its hinge like a t block.
"""
func test_j_plant_kick0() -> void:
	from_grid = [
		":: ::",
		"  j::",
		"  jjj",
		":: ::",
		":: ::",
	]
	to_grid = [
		":: ::",
		"   ::",
		"  jj ",
		"::j::",
		"::j::",
	]
	assert_kick()


func test_j_plant_kick1() -> void:
	from_grid = [
		":: ::",
		"   ::",
		"jjj  ",
		"::j::",
		":: ::",
	]
	to_grid = [
		"::j::",
		"  j::",
		" jj  ",
		":: ::",
		":: ::",
	]
	assert_kick()


func test_l_plant_kick0() -> void:
	from_grid = [
		":: ::",
		"::l  ",
		"lll  ",
		":: ::",
		":: ::",
	]
	to_grid = [
		":: ::",
		"::   ",
		" ll  ",
		"::l::",
		"::l::",
	]
	assert_kick()


func test_l_plant_kick1() -> void:
	from_grid = [
		":: ::",
		"::   ",
		"  lll",
		"::l::",
		":: ::",
	]
	to_grid = [
		"::l::",
		"::l  ",
		"  ll ",
		":: ::",
		":: ::",
	]
	assert_kick()


"""
A 'snack kick' is when a j piece wraps around a p piece to make a snack block.
"""
func test_j_snack_kick0() -> void:
	from_grid = [
		"  :::",
		" j:::",
		" jjj:",
		"   ::",
		":: ::",
	]
	to_grid = [
		"  :::",
		"  :::",
		"  jj:",
		"  j::",
		"::j::",
	]
	assert_kick()


func test_j_snack_kick1() -> void:
	from_grid = [
		"   :::",
		"   :::",
		" j   :",
		" jjj::",
		"  : ::",
	]
	to_grid = [
		"   :::",
		"   :::",
		"   jj:",
		"   j::",
		"  :j::",
	]
	assert_kick()


func test_j_snack_kick2() -> void:
	from_grid = [
		":    ",
		": jj ",
		"  j::",
		"::j::",
		":::::",
	]
	to_grid = [
		":    ",
		":    ",
		"jjj::",
		"::j::",
		":::::",
	]
	assert_kick()


func test_j_snack_kick3() -> void:
	from_grid = [
		"     ",
		":jj  ",
		":j ::",
		" j ::",
		":: ::",
		":::::",
	]
	to_grid = [
		"     ",
		":  ::",
		":  ::",
		"jjj::",
		"::j::",
		":::::",
	]
	assert_kick()


func test_l_snack_kick0() -> void:
	from_grid = [
		":::  ",
		":::l ",
		":lll ",
		"::   ",
		":: ::",
	]
	to_grid = [
		":::  ",
		":::  ",
		":ll  ",
		"::l  ",
		"::l::",
	]
	assert_kick()


func test_l_snack_kick1() -> void:
	from_grid = [
		":::   ",
		":::   ",
		":   l ",
		"::lll ",
		":: :  ",
	]
	to_grid = [
		":::   ",
		":::   ",
		":ll   ",
		"::l   ",
		"::l:  ",
	]
	assert_kick()


func test_l_snack_kick2() -> void:
	from_grid = [
		"    :",
		" ll :",
		"::l  ",
		"::l::",
		":::::",
	]
	to_grid = [
		"    :",
		"    :",
		"::lll",
		"::l::",
		":::::",
	]
	assert_kick()


func test_l_snack_kick3() -> void:
	from_grid = [
		"     ",
		"  ll:",
		":: l:",
		":: l ",
		":: ::",
		":::::",
	]
	to_grid = [
		"     ",
		"    :",
		"::  :",
		"::lll",
		"::l::",
		":::::",
	]
	assert_kick()
