extends "res://src/test/puzzle/piece/test-piece-kicks.gd"
## Tests the C-Block's kick behavior.

func test_wall_kick_0r() -> void:
	from_grid = [
		"::  ",
		"cc  ",
		":c  ",
		":   ",
	]
	to_grid = [
		"::  ",
		"  c ",
		":cc ",
		":   ",
	]
	assert_kick()


func test_wall_kick_0l() -> void:
	from_grid = [
		":   ",
		"cc  ",
		":c  ",
		":   ",
	]
	to_grid = [
		":   ",
		" cc ",
		":c  ",
		":   ",
	]
	assert_kick()


func test_wall_kick_r0() -> void:
	from_grid = [
		":   ",
		":c  ",
		"cc  ",
		":   ",
	]
	to_grid = [
		":   ",
		":cc ",
		"  c ",
		"::  ",
	]
	assert_kick()


func test_wall_kick_r2() -> void:
	from_grid = [
		":   ",
		":c  ",
		"cc  ",
		":   ",
	]
	to_grid = [
		":   ",
		":c  ",
		" cc ",
		":   ",
	]
	assert_kick()


func test_wall_kick_2r() -> void:
	from_grid = [
		"   :",
		"  c:",
		"  cc",
		"   :",
	]
	to_grid = [
		"   :",
		"  c:",
		" cc ",
		"   :",
	]
	assert_kick()


func test_wall_kick_2l() -> void:
	from_grid = [
		"   :",
		"  c:",
		"  cc",
		"  ::",
	]
	to_grid = [
		"   :",
		" cc:",
		" c  ",
		"  ::",
	]
	assert_kick()


func test_wall_kick_l0() -> void:
	from_grid = [
		"   :",
		"  cc",
		"  c:",
		"   :",
	]
	to_grid = [
		"   :",
		" cc ",
		"  c:",
		"   :",
	]
	assert_kick()


func test_wall_kick_l2() -> void:
	from_grid = [
		"  ::",
		"  cc",
		"  c:",
		"   :",
	]
	to_grid = [
		"  ::",
		" c  ",
		" cc:",
		"   :",
	]
	assert_kick()


func test_climb_0l_0() -> void:
	from_grid = [
		"    ",
		" cc ",
		"::c ",
	]
	to_grid = [
		" cc ",
		" c  ",
		"::  ",
	]
	assert_kick()


func test_climb_0r_0() -> void:
	from_grid = [
		"    ",
		" cc ",
		" :c:",
	]
	to_grid = [
		"  c ",
		" cc ",
		" : :",
	]
	assert_kick()


func test_climb_l0_0() -> void:
	from_grid = [
		"    ",
		" cc ",
		" c::",
	]
	to_grid = [
		" cc ",
		"  c ",
		"  ::",
	]
	assert_kick()


func test_climb_l2_0() -> void:
	from_grid = [
		"    ",
		" cc ",
		":c: ",
	]
	to_grid = [
		" c  ",
		" cc ",
		": : ",
	]
	assert_kick()


## A 'snack kick' is when a C-Block rotates around a block.
func test_snack_kick_0r() -> void:
	from_grid = [
		"    ",
		" cc ",
		" :c:",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		" :c:",
		" cc ",
	]
	assert_kick()


func test_snack_kick_r2() -> void:
	from_grid = [
		"    ",
		" :c ",
		" cc:",
		"  ::",
	]
	to_grid = [
		"    ",
		"c:  ",
		"cc :",
		"  ::",
	]
	assert_kick()


func test_snack_kick_2l() -> void:
	from_grid = [
		"    ",
		" c: ",
		" cc ",
		"    ",
	]
	to_grid = [
		" cc ",
		" c: ",
		"    ",
		"    ",
	]
	assert_kick()


func test_snack_kick_l2() -> void:
	from_grid = [
		"    ",
		" cc ",
		":c: ",
		"    ",
	]
	to_grid = [
		"    ",
		"    ",
		":c: ",
		" cc ",
	]
	assert_kick()


## A ritzy kick is when the hinge of the C-Block pivots one square diagonally.
func test_ritzy_kick_2l() -> void:
	from_grid = [
		"c:: ",
		"cc  ",
		":   ",
	]
	to_grid = [
		" :: ",
		" cc ",
		":c  ",
	]
	assert_kick()


func test_ritzy_kick_l0() -> void:
	from_grid = [
		"::cc",
		"  c:",
		"    ",
	]
	to_grid = [
		"::  ",
		" cc:",
		"  c ",
	]
	assert_kick()


func test_ritzy_kick_0r() -> void:
	from_grid = [
		"   :",
		"  cc",
		" ::c",
	]
	to_grid = [
		"  c:",
		" cc ",
		" :: ",
	]
	assert_kick()


func test_ritzy_kick_r2() -> void:
	from_grid = [
		"    ",
		":c  ",
		"cc::",
	]
	to_grid = [
		" c  ",
		":cc ",
		"  ::",
	]
	assert_kick()


func test_ritzy_kick_2r() -> void:
	from_grid = [
		"    ",
		"  c:",
		"::cc",
	]
	to_grid = [
		"  c ",
		" cc:",
		"::  ",
	]
	assert_kick()


func test_ritzy_kick_l2() -> void:
	from_grid = [
		":   ",
		"cc  ",
		"c:: ",
	]
	to_grid = [
		":c  ",
		" cc ",
		" :: ",
	]
	assert_kick()


func test_ritzy_kick_0l() -> void:
	from_grid = [
		"cc::",
		":c  ",
		"    ",
	]
	to_grid = [
		"  ::",
		":cc ",
		" c  ",
	]
	assert_kick()


func test_ritzy_kick_r0() -> void:
	from_grid = [
		":::c",
		"  cc",
		"   :",
	]
	to_grid = [
		"::: ",
		" cc ",
		"  c:",
	]
	assert_kick()


## A plant kick is when the V-Block pivots around its hinge like a T-Block. This is disorienting and should be a last
## resort.
func test_plant_kick_2l() -> void:
	from_grid = [
		" c:",
		":cc",
		"    ",
	]
	to_grid = [
		"  :",
		":cc",
		" c  ",
	]
	assert_kick()


func test_plant_kick_2r() -> void:
	from_grid = [
		" c:",
		" cc",
		" : ",
	]
	to_grid = [
		" c:",
		"cc ",
		" : ",
	]
	assert_kick()


func test_plant_kick_l2() -> void:
	from_grid = [
		"   ",
		":cc",
		" c:",
	]
	to_grid = [
		" c ",
		":cc",
		"  :",
	]
	assert_kick()


func test_plant_kick_l0() -> void:
	from_grid = [
		" : ",
		" cc",
		" c:",
	]
	to_grid = [
		" : ",
		"cc ",
		" c:",
	]
	assert_kick()


func test_plant_kick_0l() -> void:
	from_grid = [
		" : ",
		"cc ",
		":c ",
	]
	to_grid = [
		" : ",
		" cc",
		":c ",
	]
	assert_kick()


func test_plant_kick_0r() -> void:
	from_grid = [
		"   ",
		"cc:",
		":c ",
	]
	to_grid = [
		" c ",
		"cc:",
		":  ",
	]
	assert_kick()


func test_plant_kick_r2() -> void:
	from_grid = [
		":c ",
		"cc ",
		" : ",
	]
	to_grid = [
		":c ",
		" cc",
		" : ",
	]
	assert_kick()


func test_plant_kick_r0() -> void:
	from_grid = [
		":c ",
		"cc:",
		"   ",
	]
	to_grid = [
		":  ",
		"cc:",
		" c ",
	]
	assert_kick()
