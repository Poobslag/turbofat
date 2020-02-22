extends Node

const KICKS_J = [
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0,  2), Vector2(-1,  2)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0, -2), Vector2( 1, -2)],
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0,  2), Vector2( 1,  2)],
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0, -2), Vector2(-1, -2)]
	]

const KICKS_U = [
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0,  2), Vector2( 1,  2)],
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0, -2), Vector2(-1, -2)],
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0,  2), Vector2(-1,  2)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0, -2), Vector2( 1, -2)]
	]

const KICKS_P = [
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0, -1), Vector2( 0,  2), Vector2(-1,  2)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0, -1), Vector2( 0, -2), Vector2( 1, -2)],
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0,  1), Vector2( 0,  2), Vector2( 1,  2)],
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0,  1), Vector2( 0, -2), Vector2(-1, -2)]
	]

const KICKS_V = [
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0, -1), Vector2( 0,  2), Vector2(-1,  2)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0,  1), Vector2( 0, -2), Vector2( 1, -2)],
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0,  1), Vector2( 0, -2), Vector2( 1,  2)],
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0, -1), Vector2( 0,  2), Vector2(-1, -2)]
	]

const KICKS_NONE = [
		[],
		[],
		[],
		[]
	]

var piece_j = PieceType.new("j",
		# shape data
		[[Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(1, 2)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(2, 2)],
		[Vector2(1, 0), Vector2(1, 1), Vector2(0, 2), Vector2(1, 2)]],
		# color data
		[[Vector2(2, 3), Vector2(9, 3), Vector2(12, 3), Vector2(4, 3)],
		[Vector2(10, 3), Vector2(4, 3), Vector2(3, 3), Vector2(1, 3)],
		[Vector2(8, 3), Vector2(12, 3), Vector2(6, 3), Vector2(1, 3)],
		[Vector2(2, 3), Vector2(3, 3), Vector2(8, 3), Vector2(5, 3)]],
		KICKS_J
	)

var piece_l = PieceType.new("l",
		# shape data
		[[Vector2(2, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(1, 1), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(0, 2)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)]],
		# color data
		[[Vector2(2, 4), Vector2(8, 4), Vector2(12, 4), Vector2(5, 4)],
		[Vector2(2, 4), Vector2(3, 4), Vector2(9, 4), Vector2(4, 4)],
		[Vector2(10, 4), Vector2(12, 4), Vector2(4, 4), Vector2(1, 4)],
		[Vector2(8, 4), Vector2(6, 4), Vector2(3, 4), Vector2(1, 4)]],
		KICKS_J
	)

var piece_o = PieceType.new("o",
		# shape data
		[[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1)]],
		# color data
		[[Vector2(10, 6), Vector2(6, 6), Vector2(9, 6), Vector2(5, 6)]],
		KICKS_NONE
	)

var piece_p = PieceType.new("p",
		# shape data
		[[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(2, 0), Vector2(1, 1), Vector2(2, 1), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(0, 2)]],
		# color data
		[[Vector2(8, 3), Vector2(14, 3), Vector2(6, 3), Vector2(9, 3), Vector2(5, 3)],
		[Vector2(2, 3), Vector2(10, 3), Vector2(7, 3), Vector2(9, 3), Vector2(5, 3)],
		[Vector2(10, 3), Vector2(6, 3), Vector2(9, 3), Vector2(13, 3), Vector2(4, 3)],
		[Vector2(10, 3), Vector2(6, 3), Vector2(11, 3), Vector2(5, 3), Vector2(1, 3)]],
		KICKS_P
	)

var piece_q = PieceType.new("q",
		# shape data
		[[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1), Vector2(1, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1), Vector2(2, 2)],
		[Vector2(1, 1), Vector2(2, 1), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(0, 2), Vector2(1, 2)]],
		# color data
		[[Vector2(10, 4), Vector2(14, 4), Vector2(4, 4), Vector2(9, 4), Vector2(5, 4)],
		[Vector2(10, 4), Vector2(6, 4), Vector2(9, 4), Vector2(7, 4), Vector2(1, 4)],
		[Vector2(10, 4), Vector2(6, 4), Vector2(8, 4), Vector2(13, 4), Vector2(5, 4)],
		[Vector2(2, 4), Vector2(11, 4), Vector2(6, 4), Vector2(9, 4), Vector2(5, 4)]],
		KICKS_P
	)

var piece_t = PieceType.new("t",
		# shape data
		[[Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(1, 1), Vector2(2, 1), Vector2(1, 2)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(1, 2)],
		[Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 2)]],
		# color data
		[[Vector2(2, 8), Vector2(8, 8), Vector2(13, 8), Vector2(4, 8)],
		[Vector2(2, 8), Vector2(11, 8), Vector2(4, 8), Vector2(1, 8)],
		[Vector2(8, 8), Vector2(14, 8), Vector2(4, 8), Vector2(1, 8)],
		[Vector2(2, 8), Vector2(8, 8), Vector2(7, 8), Vector2(1, 8)]],
		KICKS_J
	)

var piece_u = PieceType.new("u",
		# shape data
		[[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1), Vector2(2, 1)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2), Vector2(0, 2)],
		[Vector2(0, 0), Vector2(2, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(1, 2), Vector2(2, 2)]],
		# color data
		[[Vector2(10, 8), Vector2(12, 8), Vector2(6, 8), Vector2(1, 8), Vector2(1, 8)],
		[Vector2(8, 8), Vector2(6, 8), Vector2(3, 8), Vector2(5, 8), Vector2(8, 8)],
		[Vector2(2, 8), Vector2(2, 8), Vector2(9, 8), Vector2(12, 8), Vector2(5, 8)],
		[Vector2(10, 8), Vector2(4, 8), Vector2(3, 8), Vector2(9, 8), Vector2(4, 8)]],
		KICKS_U,
		2 # u-piece allows more floor kicks, because it kicks the floor twice if you rotate it four times
	)

var piece_v = PieceType.new("v",
		# shape data
		[[Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1), Vector2(0, 2)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(2, 1), Vector2(2, 2)],
		[Vector2(2, 0), Vector2(2, 1), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)]],
		# color data
		[[Vector2(2, 6), Vector2(3, 6), Vector2(9, 6), Vector2(12, 6), Vector2(4, 6)],
		[Vector2(10, 6), Vector2(12, 6), Vector2(4, 6), Vector2(3, 6), Vector2(1, 6)],
		[Vector2(8, 6), Vector2(12, 6), Vector2(6, 6), Vector2(3, 6), Vector2(1, 6)],
		[Vector2(2, 6), Vector2(3, 6), Vector2(8, 6), Vector2(12, 6), Vector2(5, 6)]],
		KICKS_V
	)

var piece_null = PieceType.new("_", [[]], [[]], KICKS_NONE)
var all_types = [piece_j, piece_l, piece_o, piece_p, piece_q, piece_t, piece_u, piece_v];

func is_null(piece_type):
	return piece_type.pos_arr[0].size() == 0

class PieceType:
	#string representation when debugging; 'j', 'l', etc...
	var string
	
	var pos_arr
	var color_arr
	
	var cw_kicks
	var ccw_kicks
	var max_floor_kicks
	
	func _init(init_string, init_pos_arr, init_color_arr, init_cw_kicks, init_max_floor_kicks = 1):
		string = init_string
		pos_arr = init_pos_arr
		color_arr = init_color_arr
		cw_kicks = init_cw_kicks
		ccw_kicks = []
		for cw_kick in cw_kicks:
			var ccw_kick = cw_kick.duplicate()
			# invert all kicks but the first one (the first one is the floor kick)
			for i in range(0, cw_kick.size()):
				ccw_kick[i] = Vector2(-cw_kick[i].x, -cw_kick[i].y)
			ccw_kicks += [ccw_kick]
		max_floor_kicks = init_max_floor_kicks
