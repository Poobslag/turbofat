class_name PieceType
## Stores information on a piece shape. This includes information on its appearance, how it rotates, and how it 'kicks'
## when it's obstructed from rotating.

## string representation when debugging; 'j', 'l', etc...
var string: String

## array of array of vectors representing the position of used cells
var pos_arr: Array

## array of array of vectors representing the autotile coordinates of used cells
var color_arr: Array

## dictionary of kicks to try when rotating or flipping
## key: (int) number representing the source/destination rotation.
## 	kicks[12] = piece kicks to try when rotating clockwise from orientation R to orientation 2
## 	kicks[03] = piece kicks to try when rotating counter-clockwise from orientation 0 to orientation L
## 	kicks[20] = piece kicks to try when flipping from orientation 2 to orientation 0
## values: (Array, Vector2i) kicks to try
var kicks: Dictionary

func _init(init_string: String = "", init_pos_arr: Array = [], init_color_arr: Array = [],
		init_kicks: Dictionary = {}) -> void:
	string = init_string
	pos_arr = init_pos_arr
	color_arr = init_color_arr
	
	# store kicks and create inverse kicks, if absent
	kicks = init_kicks.duplicate()
	for kick_key in kicks:
		var inverse_key: int = (kick_key % 10) * 10 + int(kick_key / 10)
		if kicks.has(kick_key) and not kicks.has(inverse_key):
			kicks[inverse_key] = []
			for kick in kicks[kick_key]:
				kicks[inverse_key].append(Vector2i(-kick.x, -kick.y))


## Populates this object from another PieceType instance.
##
## Parameters:
## 	'piece_type': The PieceType instance to copy from.
func copy_from(piece_type: PieceType) -> void:
	string = piece_type.string
	pos_arr = piece_type.pos_arr.duplicate(true)
	color_arr = piece_type.color_arr.duplicate(true)
	kicks = piece_type.kicks.duplicate(true)


## Returns the position of the specified cell.
func get_cell_position(orientation: int, cell_index: int) -> Vector2i:
	return pos_arr[orientation][cell_index]


## Returns the coordinate (subtile column and row) of the autotile variation for the specified cell.
func get_cell_color(orientation: int, cell_index: int) -> Vector2i:
	return color_arr[orientation][cell_index]


## Returns PuzzleTileMap's food color index for this piece (brown, pink, bread, white)
##
## For a null piece, this returns 0. This allows code centered around "what color should these piece crumbs be" or
## "which sprite should I show" to fail more gracefully, instead of throwing an out of bounds error.
func get_box_type() -> int:
	return color_arr[0][0].y if color_arr and color_arr[0] else 0


## Changes the PuzzleTileMap's food color index for this piece (brown, pink, bread, white)
func set_box_type(new_type: Foods.BoxType) -> void:
	for i in range(color_arr.size()):
		for j in range(color_arr[i].size()):
			color_arr[i][j].y = new_type


func _to_string() -> String:
	return string


## Returns the orientation the piece will be in if it rotates clockwise.
func get_cw_orientation(orientation: int) -> int:
	return (orientation + 1) % pos_arr.size()


## Returns the orientation the piece will be in if it rotates counter-clockwise.
func get_ccw_orientation(orientation: int) -> int:
	return wrapi(orientation - 1, 0, pos_arr.size())


## Returns the orientation the piece will be in if it rotates 180 degrees.
func get_flip_orientation(orientation: int) -> int:
	return (orientation + 2) % pos_arr.size()


func size() -> int:
	return pos_arr[0].size() if pos_arr and pos_arr[0] else 0


func is_empty() -> bool:
	return size() == 0
