class_name PieceType
"""
Stores information on a piece shape. This includes information on its appearance, how it rotates, and how it 'kicks'
when it's blocked from rotating.
"""

enum Orientation {
	UNROTATED, # '0', unrotated
	CLOCKWISE, # 'R', rotated right
	FLIPPED, # '2', rotated twice
	COUNTERCLOCKWISE # 'L', rotated left
}

# string representation when debugging; 'j', 'l', etc...
var string: String

# array of vectors representing the position of used cells
var pos_arr: Array

# array of vectors representing the autotile coordinates of used cells
var color_arr: Array

# array of piece kicks to try when rotating clockwise
var cw_kicks: Array

# array of piece kicks to try when rotating counterclockwise
var ccw_kicks: Array

# maximum number of 'floor kicks', kicks which move the piece upward
var max_floor_kicks: int

func _init(init_string: String, init_pos_arr: Array, init_color_arr: Array, init_kicks: Array,
		init_max_floor_kicks := 3) -> void:
	string = init_string
	pos_arr = init_pos_arr
	color_arr = init_color_arr
	if init_kicks.size() == pos_arr.size() * 2:
		# store cw kicks and ccw kicks from input array
		cw_kicks = []
		ccw_kicks = []
		for _i in range(pos_arr.size()):
			cw_kicks.append(init_kicks[_i * 2])
			ccw_kicks.append(init_kicks[_i * 2 + 1])
	else:
		# store cw kicks from input array; calculate ccw kicks
		cw_kicks = init_kicks
		ccw_kicks = []
		for cw_kick in cw_kicks:
			var ccw_kick: Array = cw_kick.duplicate()
			# invert all kicks but the first one (the first one is the floor kick)
			for i in range(cw_kick.size()):
				ccw_kick[i] = Vector2(-cw_kick[i].x, -cw_kick[i].y)
			ccw_kicks += [ccw_kick]
	max_floor_kicks = init_max_floor_kicks


"""
Returns the position of the specified cell.
"""
func get_cell_position(orientation: int, cell_index: int) -> Vector2:
	return pos_arr[orientation][cell_index]


"""
Returns the coordinate (subtile column and row) of the autotile variation for the specified cell.
"""
func get_cell_color(orientation: int, cell_index: int) -> Vector2:
	return color_arr[orientation][cell_index]
