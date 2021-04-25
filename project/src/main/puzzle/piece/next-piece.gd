class_name NextPiece
"""
Contains the settings and state for an upcoming piece.
"""

# Piece shape, color, kick information
var type: PieceType

# The current orientation. For most pieces, orientation will range from
# [0, 1, 2, 3] for [unrotated, clockwise, flipped, counterclockwise].
#
# Pieces in the next queue are typically unrotated.
var orientation := 0

"""
Returns the orientation the piece will be in if it rotates clockwise.
"""
func get_cw_orientation() -> int:
	return wrapi(orientation + 1, 0, type.pos_arr.size())


"""
Returns the orientation the piece will be in if it rotates counter-clockwise.
"""
func get_ccw_orientation() -> int:
	return wrapi(orientation - 1, 0, type.pos_arr.size())


"""
Returns the orientation the piece will be in if it rotates 180 degrees.
"""
func get_flip_orientation() -> int:
	return wrapi(orientation + 2, 0, type.pos_arr.size())


func _to_string() -> String:
	return type.to_string()
