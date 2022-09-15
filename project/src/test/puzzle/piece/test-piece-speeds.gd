extends "res://addons/gut/test.gd"

## This matrix is generated in a complex way, so we test its contents.
func test_speed_id_matrix() -> void:
	assert_eq(PieceSpeeds.speed_id_matrix, [
		["T"],
		["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
		["A0", "A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "AA", "AB", "AC", "AD", "AE", "AF"],
		["F0", "F1", "FA", "FB", "FC", "FD", "FE", "FF", "FFF"],
	])
