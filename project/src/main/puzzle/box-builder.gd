class_name BoxBuilder
extends Node
"""
Builds boxes in a tilemap as new pieces are placed.
"""

# emitted after all boxes are built, when the builder stops processing and passes control back to the playfield
signal after_boxes_built

# emitted when a new box is built
signal box_built(rect, color_int)

export (NodePath) var tile_map_path: NodePath

# remaining frames to wait for making the current box
var remaining_box_build_frames := 0

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)

func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	remaining_box_build_frames -= 1
	if remaining_box_build_frames <= 0:
		# stop processing if we're done building boxes
		set_physics_process(false)
		emit_signal("after_boxes_built")


"""
Builds a box with the specified location and size.

Boxes are built when the player forms a 3x3, 3x4, 3x5 rectangle from intact pieces.
"""
func build_box(rect: Rect2, color_int: int) -> void:
	# set at least 1 box build frame; processing occurs when the frame goes from 1 -> 0
	remaining_box_build_frames = max(1, PieceSpeeds.current_speed.box_delay)
	_tile_map.build_box(rect, color_int)
	emit_signal("box_built", rect, color_int)


"""
Creates a new integer matrix of the same dimensions as the playfield.
"""
func _int_matrix() -> Array:
	var matrix := []
	for y in range(PuzzleTileMap.ROW_COUNT):
		matrix.append([])
		for _x in range(PuzzleTileMap.COL_COUNT):
			matrix[y].resize(PuzzleTileMap.COL_COUNT)
	return matrix


"""
Calculates the possible locations for a (width x height) rectangle in the playfield, given an integer matrix with the
possible locations for a (1 x height) rectangle in the playfield. These rectangles must consist of dropped pieces which
haven't been split apart by lines. They can't consist of any empty cells or any previously built boxes.
"""
func _filled_rectangles(db: Array, box_height: int) -> Array:
	var dt := _int_matrix()
	for y in range(PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			if db[y][x] >= box_height:
				dt[y][x] = 1 if x == 0 else dt[y][x - 1] + 1
			else:
				dt[y][x] = 0
	return dt


"""
Calculates the possible locations for a (1 x height) rectangle in the playfield, capable of being a part of a 3x3,
3x4, or 3x5 'box'. These rectangles must consist of dropped pieces which haven't been split apart by lines. They can't
consist of any empty cells or any previously built boxes.
"""
func _filled_columns() -> Array:
	var db := _int_matrix()
	for y in range(PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			var piece_color: int = _tile_map.get_cell(x, y)
			if piece_color == -1:
				# empty space
				db[y][x] = 0
			elif piece_color == 1:
				# box
				db[y][x] = 0
			elif piece_color == 2:
				# vegetable
				db[y][x] = 0
			else:
				db[y][x] = 1 if y == 0 else db[y - 1][x] + 1
	return db


"""
Builds any possible 3x3, 3x4 or 3x5 'boxes' in the playfield, returning 'true' if a box was built.
"""
func process_boxes() -> bool:
	# Calculate the possible locations for a (w x h) rectangle in the playfield
	var db := _filled_columns()
	var dt3 := _filled_rectangles(db, 3)
	var dt4 := _filled_rectangles(db, 4)
	var dt5 := _filled_rectangles(db, 5)
	
	for y in range(PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			if dt5[y][x] >= 3 and _process_box(x, y, 3, 5): return true
			if dt4[y][x] >= 3 and _process_box(x, y, 3, 4): return true
			if dt3[y][x] >= 3 and _process_box(x, y, 3, 3): return true
			if dt3[y][x] >= 4 and _process_box(x, y, 4, 3): return true
			if dt3[y][x] >= 5 and _process_box(x, y, 5, 3): return true
	return false


"""
Checks whether the specified rectangle represents an enclosed box. An enclosed box must not connect to any pieces
outside the box.

It's assumed the rectangle's coordinates contain only dropped pieces which haven't been split apart by lines, and
no empty/vegetable/box cells.
"""
func _process_box(end_x: int, end_y: int, width: int, height: int) -> bool:
	var start_x := end_x - (width - 1)
	var start_y := end_y - (height - 1)
	for x in range(start_x, end_x + 1):
		if Connect.is_u(_tile_map.get_cell_autotile_coord(x, start_y).x):
			return false
		if Connect.is_d(_tile_map.get_cell_autotile_coord(x, end_y).x):
			return false
	for y in range(start_y, end_y + 1):
		if Connect.is_l(_tile_map.get_cell_autotile_coord(start_x, y).x):
			return false
		if Connect.is_r(_tile_map.get_cell_autotile_coord(end_x, y).x):
			return false
	
	var color_int: int
	if width == 3 and height == 3:
		color_int = _tile_map.get_cell_autotile_coord(start_x, start_y).y
	else:
		color_int = PuzzleTileMap.BoxColorInt.CAKE
	build_box(Rect2(start_x, start_y, width, height), color_int)
	
	return true
