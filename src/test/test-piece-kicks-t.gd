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
	_assert_kick()


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
	_assert_kick()


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
	_assert_kick()


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
	_assert_kick()


func test_triple_cw() -> void:
	from_grid = [
		"    ",
		":t  ",
		"ttt ",
		" :::",
		"  ::",
		" :::",
	]
	to_grid = [
		"    ",
		":   ",
		"    ",
		"t:::",
		"tt::",
		"t:::",
	]
	_assert_kick()


func test_triple_ccw() -> void:
	from_grid = [
		"    ",
		"  t:",
		" ttt",
		"::: ",
		"::  ",
		"::: ",
	]
	to_grid = [
		"    ",
		"   :",
		"    ",
		":::t",
		"::tt",
		":::t",
	]
	_assert_kick()
