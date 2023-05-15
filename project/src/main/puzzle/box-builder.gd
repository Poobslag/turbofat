class_name BoxBuilder
extends Node
## Builds boxes in a tilemap as new pieces are placed.

## emitted after all boxes are built, when the builder stops processing and passes control back to the playfield
signal after_boxes_built

## emitted when a new box is built
signal box_built(rect, box_type)

export (NodePath) var tile_map_path: NodePath

## remaining frames to wait for making the current box
var remaining_box_build_frames := 0

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)

## Maps 'ingredient strings' to box colors. This lets us calculate which snack/cake tiles should be used for a box with
## certain pieces.
##
## An ingredient string looks like 's13'. It starts with an 's' for a 3x3 or 4x3 box, and 'l' for a 5x3 box. It ends
## with the box's piece color ints in ascending numerical order (brown=0, pink=1...). For example 's13' is a 4x3 box
## with pink and white pieces, where 'l123' is a 5x3 box with pink, bread and white pieces. 's0' is a 3x3 box with
## brown pieces.
##
## key: (string) Ingredient string describing the box's size and color
## value: (int) Enum from Foods.BoxType for the resulting snack/cake
const BOX_TYPES_BY_INGREDIENTS := {
	# 3x3
	"s0": Foods.BoxType.BROWN,
	"s1": Foods.BoxType.PINK,
	"s2": Foods.BoxType.BREAD,
	"s3": Foods.BoxType.WHITE,
	
	# 4x3
	"s013": Foods.BoxType.CAKE_JLO,
	"s02": Foods.BoxType.CAKE_LTT,
	"s03": Foods.BoxType.CAKE_LLO,
	"s12": Foods.BoxType.CAKE_JTT,
	"s13": Foods.BoxType.CAKE_JJO,
	
	# 5x3
	"l013": Foods.BoxType.CAKE_PQV,
	"l023": Foods.BoxType.CAKE_QUV,
	"l123": Foods.BoxType.CAKE_PUV,
	
	# nonstandard recipes
	"s01": Foods.BoxType.CAKE_JLO,
	"s012": Foods.BoxType.CAKE_JLO,
	"s0123": Foods.BoxType.CAKE_JLO,
	"s023": Foods.BoxType.CAKE_LTT,
	"s123": Foods.BoxType.CAKE_JTT,
	"s23": Foods.BoxType.CAKE_JLO,
	"l0": Foods.BoxType.BROWN,
	"l01": Foods.BoxType.CAKE_PQV,
	"l012": Foods.BoxType.CAKE_PQV,
	"l0123": Foods.BoxType.CAKE_PQV,
	"l02": Foods.BoxType.CAKE_QUV,
	"l03": Foods.BoxType.CAKE_QUV,
	"l1": Foods.BoxType.PINK,
	"l12": Foods.BoxType.CAKE_PUV,
	"l13": Foods.BoxType.CAKE_PUV,
	"l2": Foods.BoxType.BREAD,
	"l23": Foods.BoxType.CAKE_PQV,
	"l3": Foods.BoxType.WHITE,
}

func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	remaining_box_build_frames -= 1
	if remaining_box_build_frames <= 0:
		# stop processing if we're done building boxes
		emit_signal("after_boxes_built")
		
		# setting physics_process to 'false' causes 'Playfield.is_building_boxes()' to return false, so we make sure to
		# assign this after all signals are fired.
		set_physics_process(false)


## Builds a box with the specified location and size.
##
## Boxes are built when the player forms a 3x3, 3x4, 3x5 rectangle from intact pieces.
func build_box(rect: Rect2, box_type: int) -> void:
	# set at least 1 box build frame; processing occurs when the frame goes from 1 -> 0
	remaining_box_build_frames = max(1, PieceSpeeds.current_speed.box_delay)
	_tile_map.build_box(rect, box_type)
	CurrentLevel.settings.triggers.run_triggers(LevelTrigger.BOX_BUILT, {"type": box_type})
	emit_signal("box_built", rect, box_type)


## Creates a new integer matrix of the same dimensions as the playfield.
func _int_matrix() -> Array:
	var matrix := []
	for y in range(PuzzleTileMap.ROW_COUNT):
		matrix.append([])
		for _x in range(PuzzleTileMap.COL_COUNT):
			matrix[y].resize(PuzzleTileMap.COL_COUNT)
	return matrix


## Calculates the possible locations for a (width x height) rectangle in the playfield, given an integer matrix with
## the possible locations for a (1 x height) rectangle in the playfield. These rectangles must consist of dropped
## pieces which haven't been split apart by lines. They can't consist of any empty cells or any previously built boxes.
func _filled_rectangles(db: Array, box_height: int) -> Array:
	var dt := _int_matrix()
	for y in range(PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			if db[y][x] >= box_height:
				dt[y][x] = 1 if x == 0 else dt[y][x - 1] + 1
			else:
				dt[y][x] = 0
	return dt


## Calculates the possible locations for a (1 x height) rectangle in the playfield, capable of being a part of a 3x3,
## 3x4, or 3x5 'box'. These rectangles must consist of dropped pieces which haven't been split apart by lines. They
## can't consist of any empty cells or any previously built boxes.
func _filled_columns() -> Array:
	var db := _int_matrix()
	for y in range(PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			var piece_color: int = _tile_map.get_cell(x, y)
			match piece_color:
				-1:
					# empty space
					db[y][x] = 0
				1:
					# box
					db[y][x] = 0
				2:
					# vegetable
					db[y][x] = 0
				_:
					db[y][x] = 1 if y == 0 else db[y - 1][x] + 1
	return db


## Builds any possible 3x3, 3x4 or 3x5 'boxes' in the playfield, returning 'true' if a box was built.
func process_boxes() -> bool:
	if CurrentLevel.settings.other.tile_set == PuzzleTileMap.TileSetType.VEGGIE:
		# veggie blocks cannot make boxes
		return false
	
	# Calculate the possible locations for a (w x h) rectangle in the playfield
	var db := _filled_columns()
	var dt3 := _filled_rectangles(db, 3)
	var dt4 := _filled_rectangles(db, 4)
	var dt5 := _filled_rectangles(db, 5)
	
	for hi_y in range(PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			# Process boxes from bottom to top, to hopefully match a typical player's intent. If multiple boxes can
			# be made, it's better to leave an incomplete box at the top of the playfield rather than being buried at
			# the bottom.
			
			# If multiple boxes can be made at the same height, we prioritize larger horizontal boxes. They're worth
			# more points.
			var lo_y := PuzzleTileMap.ROW_COUNT - hi_y - 1
			if dt3[lo_y][x] >= 5 and _process_box(x, lo_y, 5, 3): return true
			if dt5[lo_y][x] >= 3 and _process_box(x, lo_y, 3, 5): return true
			if dt3[lo_y][x] >= 4 and _process_box(x, lo_y, 4, 3): return true
			if dt4[lo_y][x] >= 3 and _process_box(x, lo_y, 3, 4): return true
			if dt3[lo_y][x] >= 3 and _process_box(x, lo_y, 3, 3): return true
	return false


## Calculates an 'ingredient string' for a specific box.
##
## An ingredient string looks like 's13'. It starts with an 's' for a 3x3 or 4x3 box, and 'l' for a 5x3 box. It ends
## with the box's piece color ints in ascending numerical order (brown=0, pink=1...). For example 's13' is a 4x3 box
## with pink and white pieces, where 'l123' is a 5x3 box with pink, bread and white pieces. 's0' is a 3x3 box with
## brown pieces.
##
## Parameters:
## 	'width': The box width
##
## 	'height': The box height
##
## 	'piece_box_types': An array of ints corresponding to different piece colors (brown=0, pink=1...)
func _box_ingredients(width: int, height: int, piece_box_types: Array) -> String:
	piece_box_types.sort()
	var result := "s" if width <= 4 and height <= 4 else "l"
	for piece_box_type in piece_box_types:
		result += str(piece_box_type)
	return result


## Checks whether the specified rectangle represents an enclosed box. An enclosed box must not connect to any pieces
## outside the box.
##
## It's assumed the rectangle's coordinates contain only dropped pieces which haven't been split apart by lines, and
## no empty/vegetable/box cells.
func _process_box(end_x: int, end_y: int, width: int, height: int) -> bool:
	var start_x := end_x - (width - 1)
	var start_y := end_y - (height - 1)
	for x in range(start_x, end_x + 1):
		if PuzzleConnect.is_u(_tile_map.get_cell_autotile_coord(x, start_y).x):
			return false
		if PuzzleConnect.is_d(_tile_map.get_cell_autotile_coord(x, end_y).x):
			return false
	for y in range(start_y, end_y + 1):
		if PuzzleConnect.is_l(_tile_map.get_cell_autotile_coord(start_x, y).x):
			return false
		if PuzzleConnect.is_r(_tile_map.get_cell_autotile_coord(end_x, y).x):
			return false
	
	# calculate the ingredient string for the box
	var piece_box_types_dict := {}
	for x in range(start_x, end_x + 1):
		for y in range(start_y, end_y + 1):
			piece_box_types_dict[_tile_map.get_cell_autotile_coord(x, y).y] = true
	var ingredients := _box_ingredients(width, height, piece_box_types_dict.keys())
	
	var box_type: int = BOX_TYPES_BY_INGREDIENTS.get(ingredients, Foods.BoxType.BROWN)
	
	build_box(Rect2(start_x, start_y, width, height), box_type)
	
	return true
