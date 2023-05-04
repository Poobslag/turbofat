extends Node
## Stores information on the various piece shapes. This includes information on their appearance, how they rotate, and
## how they 'kick' when they're obstructed from rotating.

## Piece kicks for a 2 block domino piece, featured in Dr. Mario and Puyo Puyo
const KICKS_DOMINO := {
		01: [Vector2i( 1,  0), Vector2i( 0,  1), Vector2i( 1,  1)],
		12: [Vector2i(-1,  0), Vector2i( 0, -1), Vector2i(-1, -1)],
		23: [Vector2i( 1,  0), Vector2i( 0,  1), Vector2i( 1,  1)],
		30: [Vector2i(-1,  0), Vector2i( 0, -1), Vector2i(-1, -1)],
	}

const KICKS_I := {
		01: [Vector2i(-2,  0), Vector2i( 1,  0), Vector2i(-2,  1), Vector2i( 1, -2)],
		12: [Vector2i(-1,  0), Vector2i( 2,  0), Vector2i(-1, -2), Vector2i( 2,  1)],
		23: [Vector2i( 2,  0), Vector2i(-1,  0), Vector2i( 2, -1), Vector2i(-1,  2)],
		30: [Vector2i( 1,  0), Vector2i(-2,  0), Vector2i( 1,  2), Vector2i(-2, -1)],
	}

const KICKS_JLSZ := {
		01: [Vector2i( 1,  0), Vector2i(-1,  0), Vector2i(-1, -1), Vector2i( 0,  1), Vector2i( 0, -1), Vector2i(-1,  1)],
		12: [Vector2i( 1,  0), Vector2i( 1,  1), Vector2i( 1, -1), Vector2i( 0, -1), Vector2i( 0,  1), Vector2i(-1,  0),
				Vector2i( 0, -2), Vector2i( 1, -2)],
		23: [Vector2i( 1,  0), Vector2i( 1, -1), Vector2i( 1,  1), Vector2i( 0, -1), Vector2i( 0,  1), Vector2i(-1,  0),
				Vector2i( 0,  2), Vector2i( 1,  2)],
		30: [Vector2i( 1,  0), Vector2i(-1,  0), Vector2i(-1,  1), Vector2i( 0,  1), Vector2i( 0, -1), Vector2i(-1, -1)],
		
		02: [Vector2i( 0, -1)],
		13: [Vector2i( 1,  0)],
	}

const KICKS_P := {
		01: [Vector2i( 0, -1), Vector2i(-1,  0), Vector2i(-1, -1), Vector2i( 0,  1)],
		12: [Vector2i( 1,  0), Vector2i( 1, -1), Vector2i( 0, -1), Vector2i( 0,  1)],
		23: [Vector2i( 0,  1), Vector2i( 1,  0), Vector2i( 1,  1), Vector2i( 0, -1)],
		30: [Vector2i(-1,  0), Vector2i(-1,  1), Vector2i( 0,  1), Vector2i( 0, -1)],
	
		02: [Vector2i( 0, -1), Vector2i( 1, -1)],
		13: [Vector2i( 1,  0), Vector2i( 1,  1)],
	}

const KICKS_Q := {
		01: [Vector2i(-1,  0), Vector2i(-1, -1), Vector2i( 0, -1), Vector2i( 0,  1)],
		12: [Vector2i( 0, -1), Vector2i( 1,  0), Vector2i( 1, -1), Vector2i( 0,  1)],
		23: [Vector2i( 1,  0), Vector2i( 1,  1), Vector2i( 0,  1), Vector2i( 0, -1)],
		30: [Vector2i( 0,  1), Vector2i(-1,  0), Vector2i(-1,  1), Vector2i( 0, -1)],
		
		02: [Vector2i( 0, -1), Vector2i(-1, -1)],
		13: [Vector2i( 1,  0), Vector2i( 1, -1)],
	}

const KICKS_T := {
		01: [Vector2i(-1,  0), Vector2i(-1, -1), Vector2i( 0,  1), Vector2i( 0, -1)],
		12: [Vector2i( 1,  0), Vector2i( 1, -1), Vector2i( 0, -1), Vector2i(-1,  0)],
		23: [Vector2i( 1,  0), Vector2i( 1,  1), Vector2i( 0,  1), Vector2i(-1,  0)],
		30: [Vector2i(-1,  0), Vector2i(-1,  1), Vector2i( 0, -1), Vector2i( 0,  1)],
		
		02: [Vector2i( 0, -1)],
		13: [Vector2i( 1,  0)],
	}

const KICKS_U := {
		23: [Vector2i( 1,  1), Vector2i( 0,  1), Vector2i( 1,  0), Vector2i( 0,  2), Vector2i( 1, -1)],
		30: [Vector2i( 1,  0), Vector2i(-1,  0), Vector2i(-1,  1), Vector2i( 0,  1), Vector2i( 0, -1)],
		01: [Vector2i( 1,  0), Vector2i(-1,  0), Vector2i(-1, -1), Vector2i( 0,  1), Vector2i( 0, -1)],
		12: [Vector2i( 1, -1), Vector2i( 0, -1), Vector2i( 1,  0), Vector2i( 0, -2), Vector2i( 1,  1)],
		
		02: [Vector2i( 0, -1)],
		13: [Vector2i( 1,  0)],
	}

const KICKS_V := {
		# these kicks should be symmetrical over the y-axis
		01: [Vector2i( 1,  0), Vector2i(-1, -1), Vector2i( 1, -1), Vector2i( 0, -1), Vector2i( 0,  1),
				Vector2i( 0, -2)],
		10: [Vector2i( 1,  0), Vector2i(-1,  1), Vector2i( 1,  1), Vector2i( 0,  1), Vector2i( 0, -1),
				Vector2i( 0,  2)],
		
		# these kicks should be symmetrical over the x-axis
		12: [Vector2i( 0,  1), Vector2i( 1,  0), Vector2i(-1,  0), Vector2i( 1,  1), Vector2i( 1, -1),
				Vector2i( 1,  2), Vector2i( 2,  0)],
		21: [Vector2i( 0,  1), Vector2i(-1,  0), Vector2i( 1,  0), Vector2i(-1,  1), Vector2i(-1, -1),
				Vector2i(-1,  2), Vector2i(-2,  0)],
		
		# these kicks should be symmetrical over the y-axis
		23: [Vector2i(-1,  0), Vector2i( 1,  1), Vector2i(-1,  1), Vector2i( 0,  1), Vector2i( 0, -1),
				Vector2i( 0,  2)],
		32: [Vector2i(-1,  0), Vector2i( 1, -1), Vector2i(-1, -1), Vector2i( 0, -1), Vector2i( 0,  1),
				Vector2i( 0, -2)],
		
		# these kicks should be symmetrical over the x-axis
		30: [Vector2i( 0, -1), Vector2i(-1,  0), Vector2i( 1,  0), Vector2i(-1, -1), Vector2i(-1,  1),
				Vector2i(-1, -2), Vector2i(-2,  0)],
		03: [Vector2i( 0, -1), Vector2i( 1,  0), Vector2i(-1,  0), Vector2i( 1, -1), Vector2i( 1,  1),
				Vector2i( 1, -2), Vector2i( 2,  0)],
	}

const KICKS_NONE := {}

## 2 block domino piece featured in Dr. Mario and Puyo Puyo
var piece_domino := PieceType.new("d",
		# shape data
		[
			[Vector2i(0,  1), Vector2i(1, 1)],
			[Vector2i(0,  0), Vector2i(0, 1)],
			[Vector2i(0,  1), Vector2i(1, 1)],
			[Vector2i(0,  0), Vector2i(0, 1)],
		],
		# color data
		[
			[Vector2i( 8, 3), Vector2i( 4, 3)],
			[Vector2i( 2, 3), Vector2i( 1, 3)],
			[Vector2i( 8, 3), Vector2i( 4, 3)],
			[Vector2i( 2, 3), Vector2i( 1, 3)],
		],
		KICKS_DOMINO
)

var piece_i := PieceType.new("i",
		# shape data
		[
			[Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)],
			[Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)],
		],
		# color data
		[
			[Vector2i( 8, 3), Vector2i(12, 3), Vector2i(12, 3), Vector2i( 4, 3)],
			[Vector2i( 2, 3), Vector2i( 3, 3), Vector2i( 3, 3), Vector2i( 1, 3)],
			[Vector2i( 8, 3), Vector2i(12, 3), Vector2i(12, 3), Vector2i( 4, 3)],
			[Vector2i( 2, 3), Vector2i( 3, 3), Vector2i( 3, 3), Vector2i( 1, 3)],
		],
		KICKS_I
	)

var piece_j := PieceType.new("j",
		# shape data
		[
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
		],
		# color data
		[
			[Vector2i( 2, 1), Vector2i( 9, 1), Vector2i(12, 1), Vector2i( 4, 1)],
			[Vector2i(10, 1), Vector2i( 4, 1), Vector2i( 3, 1), Vector2i( 1, 1)],
			[Vector2i( 8, 1), Vector2i(12, 1), Vector2i( 6, 1), Vector2i( 1, 1)],
			[Vector2i( 2, 1), Vector2i( 3, 1), Vector2i( 8, 1), Vector2i( 5, 1)],
		],
		KICKS_JLSZ
	)

var piece_l := PieceType.new("l",
		# shape data
		[
			[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)],
		],
		# color data
		[
			[Vector2i( 2, 0), Vector2i( 8, 0), Vector2i(12, 0), Vector2i( 5, 0)],
			[Vector2i( 2, 0), Vector2i( 3, 0), Vector2i( 9, 0), Vector2i( 4, 0)],
			[Vector2i(10, 0), Vector2i(12, 0), Vector2i( 4, 0), Vector2i( 1, 0)],
			[Vector2i( 8, 0), Vector2i( 6, 0), Vector2i( 3, 0), Vector2i( 1, 0)],
		],
		KICKS_JLSZ
	)

var piece_o := PieceType.new("o",
		# shape data, four states so that the rotate button has an effect and can distinguish cw/ccw rotation
		[
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
		],
		# color data
		[
			[Vector2i(10, 3), Vector2i( 6, 3), Vector2i( 9, 3), Vector2i( 5, 3)],
			[Vector2i(10, 3), Vector2i( 6, 3), Vector2i( 9, 3), Vector2i( 5, 3)],
			[Vector2i(10, 3), Vector2i( 6, 3), Vector2i( 9, 3), Vector2i( 5, 3)],
			[Vector2i(10, 3), Vector2i( 6, 3), Vector2i( 9, 3), Vector2i( 5, 3)],
		],
		KICKS_JLSZ
	)

var piece_p := PieceType.new("p",
		# shape data
		[
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
		],
		# color data
		[
			[Vector2i( 8, 1), Vector2i(14, 1), Vector2i( 6, 1), Vector2i( 9, 1), Vector2i( 5, 1)],
			[Vector2i( 2, 1), Vector2i(10, 1), Vector2i( 7, 1), Vector2i( 9, 1), Vector2i( 5, 1)],
			[Vector2i(10, 1), Vector2i( 6, 1), Vector2i( 9, 1), Vector2i(13, 1), Vector2i( 4, 1)],
			[Vector2i(10, 1), Vector2i( 6, 1), Vector2i(11, 1), Vector2i( 5, 1), Vector2i( 1, 1)],
		],
		KICKS_P
	)

var piece_q := PieceType.new("q",
		# shape data
		[
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
		],
		# color data
		[
			[Vector2i(10, 0), Vector2i(14, 0), Vector2i( 4, 0), Vector2i( 9, 0), Vector2i( 5, 0)],
			[Vector2i(10, 0), Vector2i( 6, 0), Vector2i( 9, 0), Vector2i( 7, 0), Vector2i( 1, 0)],
			[Vector2i(10, 0), Vector2i( 6, 0), Vector2i( 8, 0), Vector2i(13, 0), Vector2i( 5, 0)],
			[Vector2i( 2, 0), Vector2i(11, 0), Vector2i( 6, 0), Vector2i( 9, 0), Vector2i( 5, 0)],
		],
		KICKS_Q
	)
	
var piece_s := PieceType.new("s",
		# shape data
		[
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)],
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		],
		# color data
		[
			[Vector2i(10, 2), Vector2i( 4, 2), Vector2i( 8, 2), Vector2i( 5, 2)],
			[Vector2i( 2, 2), Vector2i( 9, 2), Vector2i( 6, 2), Vector2i( 1, 2)],
			[Vector2i(10, 2), Vector2i( 4, 2), Vector2i( 8, 2), Vector2i( 5, 2)],
			[Vector2i( 2, 2), Vector2i( 9, 2), Vector2i( 6, 2), Vector2i( 1, 2)],
		],
		KICKS_JLSZ
	)

var piece_t := PieceType.new("t",
		# shape data
		[
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		],
		# color data
		[
			[Vector2i( 2, 2), Vector2i( 8, 2), Vector2i(13, 2), Vector2i( 4, 2)],
			[Vector2i( 2, 2), Vector2i(11, 2), Vector2i( 4, 2), Vector2i( 1, 2)],
			[Vector2i( 8, 2), Vector2i(14, 2), Vector2i( 4, 2), Vector2i( 1, 2)],
			[Vector2i( 2, 2), Vector2i( 8, 2), Vector2i( 7, 2), Vector2i( 1, 2)],
		],
		KICKS_T
	)

var piece_u := PieceType.new("u",
		# shape data
		[
			[Vector2i(0,  0), Vector2i(2,  0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1,  0), Vector2i(2,  0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0,  1), Vector2i(1,  1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(2, 2)],
			[Vector2i(0,  0), Vector2i(1,  0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
		],
		# color data
		[
			[Vector2i( 2, 2), Vector2i( 2, 2), Vector2i( 9, 2), Vector2i(12, 2), Vector2i( 5, 2)],
			[Vector2i(10, 2), Vector2i( 4, 2), Vector2i( 3, 2), Vector2i( 9, 2), Vector2i( 4, 2)],
			[Vector2i(10, 2), Vector2i(12, 2), Vector2i( 6, 2), Vector2i( 1, 2), Vector2i( 1, 2)],
			[Vector2i( 8, 2), Vector2i( 6, 2), Vector2i( 3, 2), Vector2i( 8, 2), Vector2i( 5, 2)],
		],
		KICKS_U
	)

var piece_v := PieceType.new("v",
		# shape data
		[
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2)],
			[Vector2i(2, 0), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(0, 2)],
		],
		# color data
		[
			[Vector2i( 8, 3), Vector2i(12, 3), Vector2i( 6, 3), Vector2i( 3, 3), Vector2i( 1, 3)],
			[Vector2i( 2, 3), Vector2i( 3, 3), Vector2i( 8, 3), Vector2i(12, 3), Vector2i( 5, 3)],
			[Vector2i( 2, 3), Vector2i( 3, 3), Vector2i( 9, 3), Vector2i(12, 3), Vector2i( 4, 3)],
			[Vector2i(10, 3), Vector2i(12, 3), Vector2i( 4, 3), Vector2i( 3, 3), Vector2i( 1, 3)],
		],
		KICKS_V
	)

var piece_z := PieceType.new("z",
		# shape data
		[
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
			[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
		],
		# color data
		[
			[Vector2i( 8, 2), Vector2i( 6, 2), Vector2i( 9, 2), Vector2i( 4, 2)],
			[Vector2i( 2, 2), Vector2i(10, 2), Vector2i( 5, 2), Vector2i( 1, 2)],
			[Vector2i( 8, 2), Vector2i( 6, 2), Vector2i( 9, 2), Vector2i( 4, 2)],
			[Vector2i( 2, 2), Vector2i(10, 2), Vector2i( 5, 2), Vector2i( 1, 2)],
		],
		KICKS_JLSZ
	)

var piece_null := PieceType.new("_", [[]], [[]], KICKS_NONE)
var default_types := [piece_j, piece_l, piece_o, piece_p, piece_q, piece_t, piece_u, piece_v];

var pieces_by_string := {
	"d": piece_domino,
	"i": piece_i,
	"j": piece_j,
	"l": piece_l,
	"o": piece_o,
	"p": piece_p,
	"q": piece_q,
	"s": piece_s,
	"t": piece_t,
	"u": piece_u,
	"v": piece_v,
	"z": piece_z,
}
