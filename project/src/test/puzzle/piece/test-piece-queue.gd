extends "res://addons/gut/test.gd"
"""
Unit test for the queue of upcoming pieces.
"""

func test_empty() -> void:
	assert_eq([0], PieceQueue.non_adjacent_indexes([], 3))


func test_nothing_matches() -> void:
	assert_eq([0, 1, 2, 3], PieceQueue.non_adjacent_indexes([1, 1, 1], 2))


func test_many_matches() -> void:
	assert_eq([0, 3, 6], PieceQueue.non_adjacent_indexes([1, 2, 1, 1, 2, 1], 2))


func test_from_index() -> void:
	assert_eq([3, 4], PieceQueue.non_adjacent_indexes([1, 2, 1, 1], 2, 3))
	assert_eq([4], PieceQueue.non_adjacent_indexes([1, 2, 1, 1], 2, 4))


func test_no_possibilities() -> void:
	assert_eq([], PieceQueue.non_adjacent_indexes([2, 1, 2], 2))
