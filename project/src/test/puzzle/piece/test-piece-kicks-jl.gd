extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
## Tests kick behavior for J-Blocks and L-Blocks.

func test_j_floor_kick_0r() -> void:
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


func test_j_floor_kick_0l() -> void:
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


func test_l_floor_kick_0r() -> void:
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


func test_l_floor_kick_0l() -> void:
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


func test_j_wall_kick_r2() -> void:
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


func test_j_wall_kick_r0() -> void:
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


func test_l_wall_kick_r0() -> void:
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


func test_l_wall_kick_r2() -> void:
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


func test_j_wall_kick_l0() -> void:
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


func test_j_wall_kick_l2() -> void:
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


func test_l_wall_kick_l0() -> void:
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


func test_l_wall_kick_l2() -> void:
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


## A 'vee kick' is when a J/L-Block pivots like a V-Block to hook its long end into a gap
func test_j_vee_kick_0l() -> void:
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


## It would be nice if this kick worked, but it conflicts with the wall kicks and snack kicks.
func test_j_vee_kick_0l_failed() -> void:
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


func test_j_vee_kick_l2() -> void:
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


func test_j_vee_kick_2r() -> void:
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


func test_j_vee_kick_r0() -> void:
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


func test_l_vee_kick_0r() -> void:
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


## It would be nice if this kick worked, but it conflicts with the wall kicks and snack kicks.
func test_l_vee_kick_0r_failed() -> void:
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


func test_l_vee_kick_r2() -> void:
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


func test_l_vee_kick_2l() -> void:
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


func test_l_vee_kick_l0() -> void:
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


## A 'gold kick' is when a J/L-Block hooks its short end into a small gap
func test_j_gold_kick_2l() -> void:
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


func test_j_gold_kick_l0() -> void:
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


func test_j_gold_kick_0r() -> void:
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


func test_j_gold_kick_r2() -> void:
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


func test_l_gold_kick_2r() -> void:
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


func test_l_gold_kick_r0() -> void:
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


func test_l_gold_kick_0l() -> void:
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


func test_l_gold_kick_l2() -> void:
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


## A 'golder kick' is when a J/L-Block hooks its short end into a small gap from far away.
func test_j_golder_kick_2l() -> void:
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


func test_l_golder_kick_2r() -> void:
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


## It's important a J-Block can climb onto an L-Block against a wall, to start a jlo box
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


## It's important an L-Block can climb onto a J-Block against a wall, to start a jlo box
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


## A 'hammer kick' is where the J-Block pivots around its tip, like swinging a hammer.
func test_j_hammer_kick_r2() -> void:
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


func test_l_hammer_kick_l2() -> void:
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


## A plant kick is when the J/L-Block pivots around its hinge like a T-Block.
func test_j_plant_kick_0r() -> void:
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


func test_j_plant_kick_2l() -> void:
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


func test_l_plant_kick_0l() -> void:
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


func test_l_plant_kick_2r() -> void:
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


## A 'snack kick' is when a J/L-Block's hinge slides one square towards its long end.
func test_j_snack_kick_0r() -> void:
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


## It would be nice if this kick worked, but it conflicts with vee kicks.
func test_j_snack_kick_0r_failed() -> void:
	from_grid = [
		"     ",
		" j:::",
		" jjj:",
		"   ::",
		":: ::",
	]
	to_grid = [
		" jj  ",
		" j:::",
		" j  :",
		"   ::",
		":: ::",
	]
	assert_kick()


func test_j_snack_kick_r2() -> void:
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


func test_l_snack_kick_0l() -> void:
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


## It would be nice if this kick worked, but it conflicts with vee kicks.
func test_l_snack_kick_0l_failed() -> void:
	from_grid = [
		"     ",
		":::l ",
		":lll ",
		"::   ",
		":: ::",
	]
	to_grid = [
		"  ll ",
		":::l ",
		":  l ",
		"::   ",
		":: ::",
	]
	assert_kick()


func test_l_snack_kick_l2() -> void:
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


func test_j_tip_kick_0r() -> void:
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



func test_j_tip_kick_r2() -> void:
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


func test_l_tip_kick_0l() -> void:
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


func test_l_tip_kick_l2() -> void:
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
