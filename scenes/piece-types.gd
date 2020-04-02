extends Node
"""
Stores information on the various piece shapes. This includes information on their appearance, how they rotate, and
how they 'kick' when they're blocked from rotating.
"""

# constants used when drawing blocks which are connected to other blocks
const CONNECTED_UP = 1
const CONNECTED_DOWN = 2
const CONNECTED_LEFT = 4
const CONNECTED_RIGHT = 8

const KICKS_J = [
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0,  2), Vector2(-1,  2)],
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0, -2), Vector2( 1, -2)],
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0,  2), Vector2( 1,  2)],
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0, -2), Vector2(-1, -2)]
	]

const KICKS_U = [
		[Vector2( 1, -1), Vector2( 1, -2), Vector2( 0,  1), Vector2( 1,  1)],
		[Vector2(-1,  1), Vector2(-1,  2), Vector2( 0, -1), Vector2(-1, -1)],
		[Vector2(-1, -1), Vector2(-1, -2), Vector2( 0, -1), Vector2(-1,  1)],
		[Vector2( 1,  1), Vector2( 1,  2), Vector2( 0, -1), Vector2( 1, -1)]
	]

const KICKS_P = [
		[Vector2(-1, -1), Vector2(-1,  0), Vector2( 0, -1), Vector2( 0,  2), Vector2(-1,  2)],
		[Vector2( 1,  1), Vector2( 1,  0), Vector2( 0, -1), Vector2( 0, -2), Vector2( 1, -2)],
		[Vector2( 1, -1), Vector2( 1,  0), Vector2( 0,  1), Vector2( 0,  2), Vector2( 1,  2)],
		[Vector2(-1,  1), Vector2(-1,  0), Vector2( 0,  1), Vector2( 0, -2), Vector2(-1, -2)]
	]

const KICKS_V = [
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0, -1), Vector2( 0, -2)], # 0 -> R
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0, -1), Vector2( 0, -2)], # R -> 0
		
		[Vector2( 1,  0), Vector2( 1,  1), Vector2( 0,  1), Vector2( 0, -2)], # R -> 2
		[Vector2(-1,  0), Vector2(-1, -1), Vector2( 0,  1), Vector2( 0, -1), Vector2( 0, -2)], # 2 -> R
		
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0,  1), Vector2( 0, -2)], # 2 -> L
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0, -1), Vector2( 0, -2)], # L -> 2
		
		[Vector2(-1,  0), Vector2(-1,  1), Vector2( 0, -1), Vector2( 0, -2)], # L -> 0
		[Vector2( 1,  0), Vector2( 1, -1), Vector2( 0,  1), Vector2( 0, -1), Vector2( 0, -2)], # 0 -> L
	]

const KICKS_NONE = [
		[],
		[],
		[],
		[]
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
		KICKS_J
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
		KICKS_J
	)

var piece_o := PieceType.new("o",
		# shape data, two states so that the rotation button has an effect
		[[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(2, 1)]],
		# color data
		[[Vector2(10, 3), Vector2(6, 3), Vector2(9, 3), Vector2(5, 3)],
		[Vector2(10, 3), Vector2(6, 3), Vector2(9, 3), Vector2(5, 3)]],
		KICKS_NONE
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
		KICKS_P
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
		KICKS_P
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
		KICKS_J
	)

var piece_u := PieceType.new("u",
		# shape data
		[[Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(0, 1), Vector2(2, 1)],
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2), Vector2(0, 2)],
		[Vector2(0, 0), Vector2(2, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)],
		[Vector2(1, 0), Vector2(2, 0), Vector2(1, 1), Vector2(1, 2), Vector2(2, 2)]],
		# color data
		[[Vector2(10, 2), Vector2(12, 2), Vector2(6, 2), Vector2(1, 2), Vector2(1, 2)],
		[Vector2(8, 2), Vector2(6, 2), Vector2(3, 2), Vector2(5, 2), Vector2(8, 2)],
		[Vector2(2, 2), Vector2(2, 2), Vector2(9, 2), Vector2(12, 2), Vector2(5, 2)],
		[Vector2(10, 2), Vector2(4, 2), Vector2(3, 2), Vector2(9, 2), Vector2(4, 2)]],
		KICKS_U,
		3 # u-piece allows additional floor kicks because it kicks the floor twice if you rotate it four times
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
		KICKS_V
	)

var piece_null := PieceType.new("_", [[]], [[]], KICKS_NONE)
var all_types := [piece_j, piece_l, piece_o, piece_p, piece_q, piece_t, piece_u, piece_v];
