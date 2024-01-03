extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
## Tests the K-Block's kick behavior.

## The K-Block can't technically wall kick, but it can kick against other blocks similar to a wall kick
func test_wall_kick_0r() -> void:
	from_grid = [
		"    :",
		"    :",
		"  k :",
		"  kk ",
		"  kkk",
	]
	to_grid = [
		"    :",
		"    :",
		" kkk:",
		" kk  ",
		" k   ",
	]
	assert_kick()


func test_wall_kick_0l() -> void:
	from_grid = [
		"    :",
		"    :",
		"  k :",
		"  kk ",
		"  kkk",
	]
	to_grid = [
		"    :",
		"    :",
		"   k:",
		"  kk ",
		" kkk ",
	]
	assert_kick()


func test_wall_kick_r2_0() -> void:
	from_grid = [
		"     ",
		"     ",
		"  kkk",
		"  kk:",
		"  k :",
	]
	to_grid = [
		"     ",
		"     ",
		" kkk ",
		"  kk:",
		"   k:",
	]
	assert_kick()


func test_wall_kick_r2_1() -> void:
	from_grid = [
		"     ",
		"     ",
		" kkk ",
		" kk::",
		" k ::",
	]
	to_grid = [
		"     ",
		"     ",
		"kkk  ",
		" kk::",
		"  k::",
	]
	assert_kick()


func test_wall_kick_2r_0() -> void:
	from_grid = [
		"     ",
		"     ",
		"kkk  ",
		":kk  ",
		": k  ",
	]
	to_grid = [
		"     ",
		"     ",
		" kkk ",
		":kk  ",
		":k   ",
	]
	assert_kick()


func test_wall_kick_2r_1() -> void:
	from_grid = [
		"     ",
		"     ",
		" kkk ",
		"::kk ",
		":: k ",
	]
	to_grid = [
		"     ",
		"     ",
		"  kkk",
		"::kk ",
		"::k  ",
	]
	assert_kick()


func test_wall_kick_2l() -> void:
	from_grid = [
		"     ",
		"     ",
		"kkk  ",
		" kk  ",
		": k  ",
	]
	to_grid = [
		"     ",
		"     ",
		"   k ",
		"  kk ",
		":kkk ",
	]
	assert_kick()


func test_wall_kick_l0() -> void:
	from_grid = [
		":    ",
		":    ",
		": k  ",
		" kk  ",
		"kkk  ",
	]
	to_grid = [
		":    ",
		":    ",
		":k   ",
		" kk  ",
		" kkk ",
	]
	assert_kick()


func test_wall_kick_l2() -> void:
	from_grid = [
		":    ",
		":    ",
		": k  ",
		" kk  ",
		"kkk  ",
	]
	to_grid = [
		":    ",
		":    ",
		":kkk ",
		"  kk ",
		"   k ",
	]
	assert_kick()



func test_wall_kick_r0() -> void:
	from_grid = [
		"     ",
		"     ",
		"  kkk",
		"  kk ",
		"  k :",
	]
	to_grid = [
		"     ",
		"     ",
		" k   ",
		" kk  ",
		" kkk:",
	]
	assert_kick()


func test_climb_r0_0() -> void:
	from_grid = [
		"    ",
		" kkk",
		" kk ",
		":k: ",
	]
	to_grid = [
		"k   ",
		"kk  ",
		"kkk ",
		": : ",
	]
	assert_kick()


func test_climb_r0_1() -> void:
	from_grid = [
		"    ",
		":kkk",
		" kk ",
		":k: ",
	]
	to_grid = [
		" k  ",
		":kk ",
		" kkk",
		": : ",
	]
	assert_kick()


func test_climb_r2_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" kkk ",
		" kk  ",
		" k:: ",
	]
	to_grid = [
		"     ",
		" kkk ",
		"  kk ",
		"   k ",
		"  :: ",
	]
	assert_kick()


func test_climb_r2_1() -> void:
	from_grid = [
		"     ",
		"     ",
		" kkk ",
		" kk::",
		" k:::",
	]
	to_grid = [
		"     ",
		"kkk  ",
		" kk  ",
		"  k::",
		"  :::",
	]
	assert_kick()

func test_climb_r2_3() -> void:
	from_grid = [
		"      ",
		"      ",
		"   kkk",
		"   kk ",
		"   k :",
	]
	to_grid = [
		"      ",
		"   kkk",
		"    kk",
		"     k",
		"     :",
	]
	assert_kick()


func test_climb_2r_0() -> void:
	from_grid = [
		"     ",
		"     ",
		" kkk ",
		"  kk ",
		" ::k ",
	]
	to_grid = [
		"     ",
		" kkk ",
		" kk  ",
		" k   ",
		" ::  ",
	]
	assert_kick()


func test_climb_2r_1() -> void:
	from_grid = [
		"      ",
		"      ",
		" kkk  ",
		"::kk  ",
		":::k  ",
	]
	to_grid = [
		"      ",
		"  kkk ",
		"  kk  ",
		"::k   ",
		":::   ",
	]
	assert_kick()


func test_climb_2r_3() -> void:
	from_grid = [
		"      ",
		"      ",
		"kkk   ",
		" kk   ",
		": k   ",
	]
	to_grid = [
		"      ",
		"kkk   ",
		"kk    ",
		"k     ",
		":     ",
	]
	assert_kick()


func test_climb_2l_0() -> void:
	from_grid = [
		"    ",
		"kkk ",
		" kk ",
		" :k:",
	]
	to_grid = [
		"   k",
		"  kk",
		" kkk",
		" : :",
	]
	assert_kick()


func test_climb_2l_1() -> void:
	from_grid = [
		"    ",
		"kkk:",
		" kk ",
		" :k:",
	]
	to_grid = [
		"  k ",
		" kk: ",
		"kkk ",
		" : :",
	]
	assert_kick()


func test_snack_kick_r0() -> void:
	from_grid = [
		"     ",
		"     ",
		" kkk ",
		":kk::",
		":k ::",
		"     ",
	]
	to_grid = [
		"     ",
		"     ",
		"     ",
		":k ::",
		":kk::",
		" kkk ",
	]
	assert_kick()


func test_snack_kick_2l() -> void:
	from_grid = [
		"     ",
		"     ",
		" kkk ",
		"::kk:",
		":: k:",
		"     ",
	]
	to_grid = [
		"     ",
		"     ",
		"     ",
		":: k:",
		"::kk:",
		" kkk ",
	]
	assert_kick()


## A ritzy kick is when the hinge of the V-Block pivots one square diagonally.
func test_ritzy_kick_0r() -> void:
	from_grid = [
		"k ::",
		"kk  ",
		"kkk ",
		":   ",
	]
	to_grid = [
		"  ::",
		" kkk",
		" kk ",
		":k  ",
	]
	assert_kick()


func test_ritzy_kick_r2() -> void:
	from_grid = [
		":kkk",
		" kk:",
		" k  ",
		"    ",
	]
	to_grid = [
		":   ",
		"kkk:",
		" kk ",
		"  k ",
	]
	assert_kick()


func test_ritzy_kick_2l() -> void:
	from_grid = [
		"   :",
		" kkk",
		"  kk",
		" ::k",
	]
	to_grid = [
		"  k:",
		" kk ",
		"kkk ",
		" :: ",
	]
	assert_kick()


func test_ritzy_kick_l0() -> void:
	from_grid = [
		"    ",
		"  k ",
		":kk ",
		"kkk:",
	]
	to_grid = [
		" k  ",
		" kk ",
		":kkk",
		"   :",
	]
	assert_kick()


func test_ritzy_kick_0l() -> void:
	from_grid = [
		"    ",
		" k  ",
		" kk:",
		":kkk",
	]
	to_grid = [
		"  k ",
		" kk ",
		"kkk:",
		":   ",
	]
	assert_kick()


func test_ritzy_kick_r0() -> void:
	from_grid = [
		":   ",
		"kkk ",
		"kk  ",
		"k:: ",
	]
	to_grid = [
		":k  ",
		" kk ",
		" kkk",
		" :: ",
	]
	assert_kick()


func test_ritzy_kick_2r() -> void:
	from_grid = [
		"kkk:",
		":kk ",
		"  k ",
		"    ",
	]
	to_grid = [
		"   :",
		":kkk",
		" kk ",
		" k  ",
	]
	assert_kick()


func test_ritzy_kick_l2() -> void:
	from_grid = [
		":: k",
		"  kk",
		" kkk",
		"   :",
	]
	to_grid = [
		"::  ",
		"kkk ",
		" kk ",
		"  k:",
	]
	assert_kick()


## A plant kick is when the V-Block pivots around its hinge like a T-Block. This is disorienting and should be a last
## resort.
func test_plant_kick_0r() -> void:
	from_grid = [
		"  k::",
		"::kk:",
		"  kkk",
		"    :",
		"   ::",
	]
	to_grid = [
		"   ::",
		"::  :",
		"  kkk",
		"  kk:",
		"  k::",
	]
	assert_kick()


func test_plant_kick_0l() -> void:
	from_grid = [
		"::k::",
		": kk:",
		"  kkk",
	]
	to_grid = [
		"::k::",
		":kk :",
		"kkk  ",
	]
	assert_kick()


func test_plant_kick_r0() -> void:
	from_grid = [
		"     ",
		"     ",
		"  kkk",
		"::kk:",
		"::k::",
	]
	to_grid = [
		"  k  ",
		"  kk ",
		"  kkk",
		"::  :",
		":: ::",
	]
	assert_kick()


func test_plant_kick_r2() -> void:
	from_grid = [
		"   ::",
		"   ::",
		"  kkk",
		": kk:",
		"::k::",
	]
	to_grid = [
		"   ::",
		"   ::",
		"kkk  ",
		":kk :",
		"::k::",
	]
	assert_kick()


func test_plant_kick_2r() -> void:
	from_grid = [
		"::   ",
		"::   ",
		"kkk  ",
		":kk :",
		"::k::",
	]
	to_grid = [
		"::   ",
		"::   ",
		"  kkk",
		": kk:",
		"::k::",
	]
	assert_kick()


func test_plant_kick_2l() -> void:
	from_grid = [
		"     ",
		"     ",
		"kkk  ",
		":kk::",
		"::k::",
	]
	to_grid = [
		"  k  ",
		" kk  ",
		"kkk  ",
		":  ::",
		":: ::",
	]
	assert_kick()


func test_plant_kick_l0() -> void:
	from_grid = [
		"::k::",
		":kk :",
		"kkk  ",
	]
	to_grid = [
		"::k::",
		": kk:",
		"  kkk",
	]
	assert_kick()


func test_plant_kick_l2() -> void:
	from_grid = [
		"::k  ",
		":kk::",
		"kkk  ",
		":    ",
		"::   ",
	]
	to_grid = [
		"::   ",
		":  ::",
		"kkk  ",
		":kk  ",
		"::k  ",
	]
	assert_kick()
