class_name ActivePiece
"""
Contains the settings and state for the currently active piece.
"""

var pos := Vector2(3, 3)

# The current rotational state.
# For most pieces, this will range from [0, 1, 2, 3] for [unrotated, clockwise, flipped, counterclockwise]
var rotation := 0

# Amount of accumulated gravity for this piece. When this number reaches 256, the piece will move down one row
var gravity := 0

# Number of frames this piece has been locked into the playfield, or '0' if the piece is not locked
var lock := 0

# Number of 'lock resets' which have been applied to this piece
var lock_resets := 0

# Number of 'floor kicks' which have been applied to this piece
var floor_kicks := 0

# Number of frames to wait before spawning the piece after this one
var spawn_delay := 0

# Piece shape, color, kick information
var type: PieceType

func _init(piece_type: PieceType) -> void:
	setType(piece_type)


func setType(new_type: PieceType) -> void:
	type = new_type
	rotation %= type.pos_arr.size()


"""
Returns the rotational state the piece will be in if it rotates clockwise.
"""
func cw_rotation(in_rotation := -1) -> int:
	if in_rotation == -1:
		in_rotation = rotation
	return (in_rotation + 1) % type.pos_arr.size()


"""
Returns the rotational state the piece will be in if it rotates 180 degrees.
"""
func flip_rotation(in_rotation := -1) -> int:
	if in_rotation == -1:
		in_rotation = rotation
	return (in_rotation + 2) % type.pos_arr.size()


"""
Returns the rotational state the piece will be in if it rotates counter-clockwise.
"""
func ccw_rotation(in_rotation := -1) -> int:
	if in_rotation == -1:
		in_rotation = rotation
	return (in_rotation + 3) % type.pos_arr.size()
