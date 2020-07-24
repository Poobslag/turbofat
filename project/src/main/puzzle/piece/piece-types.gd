extends Node
"""
Stores information on the various piece shapes. This includes information on their appearance, how they rotate, and
how they 'kick' when they're blocked from rotating.
"""

const KICKS_J := [
		[Vector2(-1,  0), Vector2( 1,  0), Vector2(-1, -1), Vector2( 0,  1), Vector2( 0, -1), Vector2(-1,  1)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 1, -1), Vector2( 0, -1), Vector2( 0,  1), Vector2(-1,  0),
				Vector2( 0, -2), Vector2( 1, -2)],
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 1,  1), Vector2( 0, -1), Vector2( 0,  1), Vector2(-1,  0),
				Vector2( 0,  2), Vector2( 1,  2)],
		[Vector2(-1,  0), Vector2( 1,  0), Vector2(-1,  1), Vector2( 0,  1), Vector2( 0, -1), Vector2(-1, -1)],
	]


const KICKS_L := [
		[Vector2(-1,  0), Vector2( 1,  0), Vector2(-1, -1), Vector2( 0,  1), Vector2( 0, -1), Vector2(-1,  1)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 1, -1), Vector2( 0, -1), Vector2( 0,  1), Vector2(-1,  0),
				Vector2( 0, -2), Vector2( 1, -2)],
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 1,  1), Vector2( 0, -1), Vector2( 0,  1), Vector2(-1,  0),
				Vector2( 0,  2), Vector2( 1,  2)],
		[Vector2(-1,  0), Vector2( 1,  0), Vector2(-1,  1), Vector2( 0, -1), Vector2( 0, -1), Vector2(-1, -1)],
	]


const KICKS_T := [
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0,  1), Vector2( 0, -1)],
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0, -1), Vector2(-1,  0)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0,  1), Vector2(-1,  0)],
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0, -1), Vector2( 0,  1)],
	]


const KICKS_U := [
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0, -1), Vector2( 1,  1), Vector2( 0,  1), Vector2( 1, -2)],
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0, -1), Vector2(-1, -1), Vector2( 0,  1), Vector2(-1,  2)],
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0,  1), Vector2(-1,  1), Vector2( 0, -1), Vector2(-1, -2)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0,  1), Vector2( 1, -1), Vector2( 0, -1), Vector2( 1,  2)],
	]

const KICKS_P := [
		[Vector2( 0, -1), Vector2(-1, -1), Vector2( 0,  1), Vector2(-1,  0)],
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0, -1), Vector2( 0,  1)],
		[Vector2( 0,  1), Vector2( 1,  1), Vector2( 0, -1), Vector2( 1,  0)],
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0,  1), Vector2( 0, -1)],
	]

const KICKS_Q := [
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0, -1), Vector2( 0,  1)],
		[Vector2( 0, -1), Vector2( 1, -1), Vector2( 0,  1), Vector2( 1,  0)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0,  1), Vector2( 0, -1)],
		[Vector2( 0,  1), Vector2(-1,  1), Vector2( 0, -1), Vector2(-1,  0)],
	]

const KICKS_V := [
		# these kicks should be symmetrical over the y-axis
		[Vector2(-1,  0), Vector2( 1,  1), Vector2(-1,  1), Vector2( 0,  1), Vector2( 0, -1),
				Vector2( 0,  2)], # 0 -> R
		[Vector2(-1,  0), Vector2( 1, -1), Vector2(-1, -1), Vector2( 0, -1), Vector2( 0,  1),
				Vector2( 0, -2)], # R -> 0
		
		# these kicks should be symmetrical over the x-axis
		[Vector2( 1,  0), Vector2(-1,  0), Vector2( 0, -1), Vector2(-1, -1), Vector2(-1,  1),
				Vector2(-1, -2), Vector2(-2,  0)], # R -> 2
		[Vector2(-1,  0), Vector2( 1,  0), Vector2( 0, -1), Vector2( 1, -1), Vector2( 1,  1),
				Vector2( 1, -2), Vector2( 2,  0)], # 2 -> R

		# these kicks should be symmetrical over the y-axis
		[Vector2( 1,  0), Vector2(-1, -1), Vector2( 1, -1), Vector2( 0, -1), Vector2( 0,  1),
				Vector2( 0, -2)], # 2 -> L
		[Vector2( 1,  0), Vector2(-1,  1), Vector2( 1,  1), Vector2( 0,  1), Vector2( 0, -1),
				Vector2( 0,  2)], # L -> 2
		
		# these kicks should be symmetrical over the x-axis
		[Vector2(-1,  0), Vector2( 1,  0), Vector2( 0,  1), Vector2( 1,  1), Vector2( 1, -1),
				Vector2( 1,  2), Vector2( 2,  0)], # L -> 0
		[Vector2( 1,  0), Vector2(-1,  0), Vector2( 0,  1), Vector2(-1,  1), Vector2(-1, -1),
				Vector2(-1,  2), Vector2(-2,  0)], # 0 -> L
	]

const KICKS_NONE := [
		[],
		[],
		[],
		[],
	]

var piece_j := PieceType.new("j",
		# shape data
		[[Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(1, 2)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(2, 2)],
		[Vector2(1, 0), Vector2(1, 1), Vector2(0, 2), Vector2(1, 2)]],
		# color data
		[[Vector2(2, 0), Vector2(9, 0), Vector2(12, 0), Vector2(4, 0)],
		[Vector2(10, 0), Vector2(4, 0), Vector2(3, 0), Vector2(1, 0)],
		[Vector2(8, 0), Vector2(12, 0), Vector2(6, 0), Vector2(1, 0)],
		[Vector2(2, 0), Vector2(3, 0), Vector2(8, 0), Vector2(5, 0)]],
		KICKS_J,
		[Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	)

var piece_l := PieceType.new("l",
		# shape data
		[[Vector2(2, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(1, 1), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(0, 2)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)]],
		# color data
		[[Vector2(2, 1), Vector2(8, 1), Vector2(12, 1), Vector2(5, 1)],
		[Vector2(2, 1), Vector2(3, 1), Vector2(9, 1), Vector2(4, 1)],
		[Vector2(10, 1), Vector2(12, 1), Vector2(4, 1), Vector2(1, 1)],
		[Vector2(8, 1), Vector2(6, 1), Vector2(3, 1), Vector2(1, 1)]],
		KICKS_L,
		[Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	)

var piece_o := PieceType.new("o",
		# shape data, two states so that the rotate button has an effect
		[[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1)]],
		# color data
		[[Vector2(10, 3), Vector2(6, 3), Vector2(9, 3), Vector2(5, 3)],
		[Vector2(10, 3), Vector2(6, 3), Vector2(9, 3), Vector2(5, 3)]],
		KICKS_NONE,
		[Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	)

var piece_p := PieceType.new("p",
		# shape data
		[[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(2, 0), Vector2(1, 1), Vector2(2, 1), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(0, 2)]],
		# color data
		[[Vector2(8, 0), Vector2(14, 0), Vector2(6, 0), Vector2(9, 0), Vector2(5, 0)],
		[Vector2(2, 0), Vector2(10, 0), Vector2(7, 0), Vector2(9, 0), Vector2(5, 0)],
		[Vector2(10, 0), Vector2(6, 0), Vector2(9, 0), Vector2(13, 0), Vector2(4, 0)],
		[Vector2(10, 0), Vector2(6, 0), Vector2(11, 0), Vector2(5, 0), Vector2(1, 0)]],
		KICKS_P,
		[Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	)

var piece_q := PieceType.new("q",
		# shape data
		[[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1), Vector2(1, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1), Vector2(2, 2)],
		[Vector2(1, 1), Vector2(2, 1), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(0, 2), Vector2(1, 2)]],
		# color data
		[[Vector2(10, 1), Vector2(14, 1), Vector2(4, 1), Vector2(9, 1), Vector2(5, 1)],
		[Vector2(10, 1), Vector2(6, 1), Vector2(9, 1), Vector2(7, 1), Vector2(1, 1)],
		[Vector2(10, 1), Vector2(6, 1), Vector2(8, 1), Vector2(13, 1), Vector2(5, 1)],
		[Vector2(2, 1), Vector2(11, 1), Vector2(6, 1), Vector2(9, 1), Vector2(5, 1)]],
		KICKS_Q,
		[Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	)

var piece_t := PieceType.new("t",
		# shape data
		[[Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(1, 1), Vector2(2, 1), Vector2(1, 2)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(1, 2)],
		[Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 2)]],
		# color data
		[[Vector2(2, 2), Vector2(8, 2), Vector2(13, 2), Vector2(4, 2)],
		[Vector2(2, 2), Vector2(11, 2), Vector2(4, 2), Vector2(1, 2)],
		[Vector2(8, 2), Vector2(14, 2), Vector2(4, 2), Vector2(1, 2)],
		[Vector2(2, 2), Vector2(8, 2), Vector2(7, 2), Vector2(1, 2)]],
		KICKS_T,
		[Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	)

var piece_u := PieceType.new("u",
		# shape data
		[[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1), Vector2(2, 1)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 2), Vector2(1, 2)],
		[Vector2(0, 0), Vector2(2, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(1, 2), Vector2(2, 2)]],
		# color data
		[[Vector2(10, 2), Vector2(12, 2), Vector2(6, 2), Vector2(1, 2), Vector2(1, 2)],
		[Vector2(8, 2), Vector2(6, 2), Vector2(3, 2), Vector2(8, 2), Vector2(5, 2)],
		[Vector2(2, 2), Vector2(2, 2), Vector2(9, 2), Vector2(12, 2), Vector2(5, 2)],
		[Vector2(10, 2), Vector2(4, 2), Vector2(3, 2), Vector2(9, 2), Vector2(4, 2)]],
		KICKS_U,
		[Vector2(0, 0), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0)],
		5 # u-piece allows additional floor kicks because it kicks the floor twice if you rotate it four times
	)

var piece_v := PieceType.new("v",
		# shape data
		[[Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1), Vector2(0, 2)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(2, 1), Vector2(2, 2)],
		[Vector2(2, 0), Vector2(2, 1), Vector2(0, 2), Vector2(1, 2), Vector2(2, 2)]],
		# color data
		[[Vector2(2, 3), Vector2(3, 3), Vector2(9, 3), Vector2(12, 3), Vector2(4, 3)],
		[Vector2(10, 3), Vector2(12, 3), Vector2(4, 3), Vector2(3, 3), Vector2(1, 3)],
		[Vector2(8, 3), Vector2(12, 3), Vector2(6, 3), Vector2(3, 3), Vector2(1, 3)],
		[Vector2(2, 3), Vector2(3, 3), Vector2(8, 3), Vector2(12, 3), Vector2(5, 3)]],
		KICKS_V,
		[Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	)

var piece_null := PieceType.new("_", [[]], [[]], KICKS_NONE, [])
var all_types := [piece_j, piece_l, piece_o, piece_p, piece_q, piece_t, piece_u, piece_v];
