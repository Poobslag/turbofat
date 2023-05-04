class_name PuzzleTileMap
extends TileMap
## TileMap containing puzzle blocks such as pieces, boxes and vegetables.

enum TileSetType {
	DEFAULT,
	VEGGIE, # tileset for levels where the player can't make boxes
	DIAGRAM, # tileset for making tutorial diagrams
}

## The highest visible playfield row. Food/wobblers/vfx should not be drawn above this row.
const FIRST_VISIBLE_ROW := 3

const TILE_PIECE := 0 # part of an intact piece
const TILE_BOX := 1 # part of a snack/cake box
const TILE_VEG := 2 # vegetable created from line clears
const TILE_CORNER := 3 # inner corner of a piece for CornerMap

## playfield dimensions. the playfield extends a few rows higher than what the player can see
const ROW_COUNT := 20
const COL_COUNT := 9

## a number in the range [0, 1] which can be set to make the tilemap flash or blink.
var whiteness := 0.0 setget set_whiteness

## offset used to draw the 'ghost piece'
var ghost_shadow_offset: Vector2

## an enum from TileSetType referencing the tileset used to render blocks
var puzzle_tile_set_type: int = TileSetType.DEFAULT setget set_puzzle_tile_set_type

## fields used to roll the tilemap back to a previous state
var _saved_used_cells := []
var _saved_tiles := []
var _saved_autotile_coords := []

## tilemap which covers the corners of this tilemap
onready var corner_map: TileMap = $CornerMap
onready var _ghost_piece_shadow_map: TileMap = $GhostPieceViewport/ShadowMap
onready var _ghost_piece_corner_map: TileMap = $GhostPieceViewport/ShadowMap/CornerMap

var _puzzle_tile_sets_by_enum := {
	TileSetType.DEFAULT: preload("res://src/main/puzzle/puzzle-tile-set.tres"),
	TileSetType.VEGGIE: preload("res://src/main/puzzle/puzzle-tile-set-veggies.tres"),
	TileSetType.DIAGRAM: preload("res://src/main/puzzle/puzzle-tile-set-diagram.tres"),
}


func _ready() -> void:
	clear()


func is_cake_cell(cell: Vector2) -> bool:
	return get_cellv(cell) == TILE_BOX and Foods.is_cake_box(get_cell_autotile_coord(cell.x, cell.y).y)


func is_snack_cell(cell: Vector2) -> bool:
	return get_cellv(cell) == TILE_BOX and Foods.is_snack_box(get_cell_autotile_coord(cell.x, cell.y).y)


func set_ghost_shadow_offset(new_ghost_shadow_offset: Vector2) -> void:
	ghost_shadow_offset = new_ghost_shadow_offset


func clear() -> void:
	.clear()
	if is_inside_tree():
		corner_map.clear()


func save_state() -> void:
	_saved_used_cells.clear()
	_saved_tiles.clear()
	_saved_autotile_coords.clear()
	for cell_obj in get_used_cells():
		var cell: Vector2 = cell_obj
		_saved_used_cells.append(cell)
		_saved_tiles.append(get_cellv(cell))
		_saved_autotile_coords.append(get_cell_autotile_coord(cell.x, cell.y))


## Rolls back the piece previously written to the tilemap.
##
## Also undoes any boxes that were built and lines that were cleared.
func restore_state() -> void:
	clear()
	for i in range(_saved_used_cells.size()):
		var cell: Vector2 = _saved_used_cells[i]
		var tile: int = _saved_tiles[i]
		var autotile_coord: Vector2 = _saved_autotile_coords[i]
		set_block(cell, tile, autotile_coord)


## Assigns a block to a tilemap cell.
##
## Parameters:
## 	'pos': Position of the cell
##
## 	'tile': Tile index of the cell
##
## 	'autotile_coord': Coordinate of the autotile variation in the tileset
func set_block(pos: Vector2, tile: int, autotile_coord: Vector2 = Vector2.ZERO) -> void:
	set_cellv(pos, tile, false, false, false, autotile_coord)
	if is_inside_tree():
		corner_map.dirty = true


## Creates a snack box or cake box.
func build_box(rect: Rect2, box_type: int) -> void:
	for curr_x in range(rect.position.x, rect.end.x):
		for curr_y in range (rect.position.y, rect.end.y):
			var autotile_coord := Vector2(15, box_type)
			
			if curr_x == rect.position.x:
				autotile_coord.x = PuzzleConnect.unset_dirs(autotile_coord.x, PuzzleConnect.LEFT)
			if curr_x == rect.end.x - 1:
				autotile_coord.x = PuzzleConnect.unset_dirs(autotile_coord.x, PuzzleConnect.RIGHT)
			if curr_y == rect.position.y:
				autotile_coord.x = PuzzleConnect.unset_dirs(autotile_coord.x, PuzzleConnect.UP)
			if curr_y == rect.end.y - 1:
				autotile_coord.x = PuzzleConnect.unset_dirs(autotile_coord.x, PuzzleConnect.DOWN)
			
			set_block(Vector2(curr_x, curr_y), TILE_BOX, autotile_coord)


## Deletes the row at the specified location, lowering all higher rows to fill the gap.
func delete_row(y: int) -> void:
	erase_row(y)
	shift_rows(y - 1, Vector2.DOWN)


## Erases the block from the specified cell, disconnecting any neighboring cells.
func erase_cell(pos: Vector2) -> void:
	if get_cellv(pos) == INVALID_CELL:
		return
	
	set_block(pos, INVALID_CELL)
	_disconnect_from_empty_cells(pos + Vector2.UP)
	_disconnect_from_empty_cells(pos + Vector2.DOWN)
	_disconnect_from_empty_cells(pos + Vector2.LEFT)
	_disconnect_from_empty_cells(pos + Vector2.RIGHT)


## Inserts a blank row at the specified location, raising all higher rows to make room.
func insert_row(y: int) -> void:
	shift_rows(y, Vector2.UP)
	_disconnect_from_empty_rows(y - 1)
	_disconnect_from_empty_rows(y + 1)


## Deletes the specified row in the tilemap, dropping all higher rows down to fill the gap.
func delete_rows(rows: Array) -> void:
	# sort to avoid edge cases with row indexes changing during deletion
	var rows_to_delete := rows.duplicate()
	rows_to_delete.sort()
	for y in rows:
		delete_row(y)


## Returns 'true' if the specified cell is within the playfield bounds and does not contain a block.
func is_cell_empty(pos: Vector2) -> bool:
	return Rect2(0, 0, COL_COUNT, ROW_COUNT).has_point(pos) and get_cellv(pos) == INVALID_CELL


## Returns 'true' if the specified cell is outside the playfield bounds or contains a block.
func is_cell_obstructed(pos: Vector2) -> bool:
	return not is_cell_empty(pos)


## Returns true if the specified row has no empty cells.
func row_is_full(y: int) -> bool:
	var row_is_full := true
	for x in range(COL_COUNT):
		if is_cell_empty(Vector2(x, y)):
			row_is_full = false
			break
	return row_is_full


## Returns true if the specified row has only empty cells.
func row_is_empty(y: int) -> bool:
	var row_is_empty := true
	for x in range(COL_COUNT):
		if not is_cell_empty(Vector2(x, y)):
			row_is_empty = false
			break
	return row_is_empty


## Erases all cells in the specified row.
func erase_row(y: int) -> void:
	for x in range(COL_COUNT):
		set_block(Vector2(x, y), INVALID_CELL)
	_disconnect_from_empty_rows(y - 1)
	_disconnect_from_empty_rows(y + 1)


## Sets the whiteness property to make the tilemap flash or blink.
func set_whiteness(new_whiteness: float) -> void:
	if whiteness == new_whiteness:
		return
	whiteness = new_whiteness
	material.set_shader_param("mix_color", Utils.to_transparent(Color.white, whiteness))
	corner_map.material.set_shader_param("mix_color", Utils.to_transparent(Color.white, whiteness))


## Returns a position randomly near a cell.
##
## This is useful when we want visual effects to appear somewhere within the cell at (3, 6) with random variation.
##
## Parameters:
## 	'cell_pos': Grid-based coordinates of a cell in the tilemap.
##
## 	'cell_offset': (Optional) Grid-based coordinates of the random offset to apply. If unspecified, the coordinate
## 		will be randomly offset by a value in the range [(0, 0), (1, 1)]
func somewhere_near_cell(cell_pos: Vector2, cell_offset: Vector2 = Vector2.ZERO) -> Vector2:
	if cell_offset == Vector2.ZERO:
		cell_offset = Vector2(randf(), randf())
	return (cell_pos + cell_offset) * cell_size * scale


## Updates our tile set and the tileset of the corner map.
##
## Parameters:
## 	'new_puzzle_tile_set_type': an enum from TileSetType referencing the tileset used to render blocks
func set_puzzle_tile_set_type(new_puzzle_tile_set_type: int) -> void:
	puzzle_tile_set_type = new_puzzle_tile_set_type
	tile_set = _puzzle_tile_sets_by_enum[new_puzzle_tile_set_type]
	corner_map.tile_set = _puzzle_tile_sets_by_enum[new_puzzle_tile_set_type]
	
	_ghost_piece_shadow_map.tile_set = _puzzle_tile_sets_by_enum[new_puzzle_tile_set_type]
	_ghost_piece_corner_map.tile_set = _puzzle_tile_sets_by_enum[new_puzzle_tile_set_type]


## Shifts a group of rows up or down.
##
## Parameters:
## 	'bottom_row': The lowest row to shift. All rows at or above this row will be shifted.
##
## 	'direction': The direction to shift the rows, such as Vector2.UP or Vector2.DOWN.
func shift_rows(bottom_row: int, direction: Vector2) -> void:
	# First, erase and store all the old cells which are shifting
	var piece_colors_to_set := {}
	var autotile_coords_to_set := {}
	for cell in get_used_cells():
		if cell.y > bottom_row:
			# cells below the specified bottom row are left alone
			continue
		# cells at or above the specified bottom row are shifted
		var piece_color: int = get_cellv(cell)
		var autotile_coord: Vector2 = get_cell_autotile_coord(cell.x, cell.y)
		piece_colors_to_set[cell + direction] = piece_color
		autotile_coords_to_set[cell + direction] = autotile_coord
		set_block(cell, INVALID_CELL)
	
	# Next, write the old cells in their new locations
	for cell in piece_colors_to_set:
		set_block(cell, piece_colors_to_set[cell], autotile_coords_to_set[cell])


## Returns the PuzzleTileMap's contents as a multi-row string.
##
## This string can be displayed (preferably using a fixed-width font) which helps in debugging.
func contents_as_string() -> String:
	var str_rows := []
	for y in range(get_used_rect().position.y, get_used_rect().position.y + get_used_rect().size.y):
		str_rows.append("")
		for x in range(get_used_rect().position.x, get_used_rect().position.x + get_used_rect().size.x):
			var cell_str: String = "."
			match get_cell(x, y):
				INVALID_CELL: cell_str = "."
				TILE_PIECE: cell_str = "u"
				TILE_BOX: cell_str = "w"
				TILE_VEG: cell_str = "v"
				_: cell_str = "?"
			str_rows[str_rows.size() - 1] += cell_str
	
	var result := ""
	for str_row in str_rows:
		if result:
			result += "\n"
		result += str_row
	return result


## Returns crumb colors for the specified cell.
##
## If the cell contains a normal piece, the resulting list will only have a single item. If the cell contains a cake
## box, the resulting list will have a few items based on the cake ingredients.
##
## Parameters:
## 	'cell_pos': An (x, y) position in the TileMap
##
## Returns:
## 	An array of Color instances corresponding to crumb colors when the specified cell is destroyed.
func crumb_colors_for_cell(cell_pos: Vector2) -> Array:
	var result := []
	var autotile_coord := get_cell_autotile_coord(cell_pos.x, cell_pos.y)
	
	var cellv := get_cellv(cell_pos)
	match cellv:
		TILE_PIECE, TILE_CORNER:
			match puzzle_tile_set_type:
				TileSetType.DEFAULT, TileSetType.DIAGRAM:
					result = [Foods.COLORS_ALL[int(autotile_coord.y)]]
				TileSetType.VEGGIE:
					result = [Foods.COLORS_VEG_ALL[int(autotile_coord.y)]]
		TILE_BOX:
			result = Foods.COLORS_BY_BOX_TYPES[int(autotile_coord.y)]
		TILE_VEG:
			result = [Foods.COLOR_VEGETABLE]
	
	return result


## Disconnects a row from any empty neighbors.
##
## Disconnected boxes have their connections updated. Disconnected pieces are converted to vegetable blocks.
func _disconnect_from_empty_rows(y: int) -> void:
	for x in range(COL_COUNT):
		var pos := Vector2(x, y)
		_disconnect_from_empty_cells(pos)


## Disconnects a cell from any empty neighbors.
##
## Disconnected boxes have their connections updated. Disconnected pieces are converted to vegetable blocks.
func _disconnect_from_empty_cells(pos: Vector2) -> void:
	match get_cellv(pos):
		TILE_PIECE:
			_convert_piece_if_broken(pos)
		TILE_BOX:
			_disconnect_box_from_empty_neighbors(pos)


## Deconstructs the specified block, which is part of a piece, if it has been 'broken'.
##
## A 'broken piece' is a piece where some of the adjacent cells making up the piece have been moved, transformed or
## erased. We don't allow partial pieces in the playfield -- pieces either remain whole, or we turn them into
## veggies.
##
## This method recurses to adjacent cells to ensure the entire piece is converted to veggies.
func _convert_piece_if_broken(pos: Vector2) -> void:
	# store connections
	var old_autotile_coord: Vector2 = get_cell_autotile_coord(pos.x, pos.y)
	
	var should_convert := false
	if PuzzleConnect.is_u(old_autotile_coord.x) and get_cellv(pos + Vector2.UP) != TILE_PIECE:
		should_convert = true
	if PuzzleConnect.is_d(old_autotile_coord.x) and get_cellv(pos + Vector2.DOWN) != TILE_PIECE:
		should_convert = true
	if PuzzleConnect.is_l(old_autotile_coord.x) and get_cellv(pos + Vector2.LEFT) != TILE_PIECE:
		should_convert = true
	if PuzzleConnect.is_r(old_autotile_coord.x) and get_cellv(pos + Vector2.RIGHT) != TILE_PIECE:
		should_convert = true
	
	if should_convert:
		# convert to vegetable. there are four kinds of vegetables
		var vegetable_type := int(old_autotile_coord.y) % 4
		set_block(pos, TILE_VEG, Vector2(randi() % 18, vegetable_type))
		
		# recurse to neighboring connected cells
		if PuzzleConnect.is_u(old_autotile_coord.x) and get_cellv(pos + Vector2.UP) == TILE_PIECE:
			_convert_piece_if_broken(pos + Vector2.UP)
		if PuzzleConnect.is_d(old_autotile_coord.x) and get_cellv(pos + Vector2.DOWN) == TILE_PIECE:
			_convert_piece_if_broken(pos + Vector2.DOWN)
		if PuzzleConnect.is_l(old_autotile_coord.x) and get_cellv(pos + Vector2.LEFT) == TILE_PIECE:
			_convert_piece_if_broken(pos + Vector2.LEFT)
		if PuzzleConnect.is_r(old_autotile_coord.x) and get_cellv(pos + Vector2.RIGHT) == TILE_PIECE:
			_convert_piece_if_broken(pos + Vector2.RIGHT)


## Disconnects the specified block, which is a part of a box, from any empty neighbors.
##
## When clearing a line which contains a box, parts of the box can stay behind. We want to redraw those boxes so that
## they don't look chopped-off, and so that the player can still tell they're worth bonus points, so we turn them into
## smaller 2x3 and 1x3 boxes.
##
## If we didn't perform this step, the chopped-off bottom of a bread box would still just look like bread. This way,
## the bottom of a bread box looks like a delicious goopy snack and the player can tell it's special.
func _disconnect_box_from_empty_neighbors(pos: Vector2) -> void:
	if get_cellv(pos + Vector2.UP) == TileMap.INVALID_CELL:
		_disconnect_block(pos, PuzzleConnect.UP)
	if get_cellv(pos + Vector2.DOWN) == TileMap.INVALID_CELL:
		_disconnect_block(pos, PuzzleConnect.DOWN)
	if get_cellv(pos + Vector2.LEFT) == TileMap.INVALID_CELL:
		_disconnect_block(pos, PuzzleConnect.LEFT)
	if get_cellv(pos + Vector2.RIGHT) == TileMap.INVALID_CELL:
		_disconnect_block(pos, PuzzleConnect.RIGHT)


## Disconnects a block from its specified neighbors.
##
## Parameters:
## 	'dir_mask': (Optional) Neighboring directions to be disconnected. Defaults to 15 which disconnects it from all
## 		four directions.
func _disconnect_block(pos: Vector2, dir_mask: int = 15) -> void:
	if not get_cellv(pos) in [TILE_PIECE, TILE_BOX]:
		# only boxes/pieces have connections between blocks
		return
	var autotile_coord := get_cell_autotile_coord(pos.x, pos.y)
	autotile_coord.x = PuzzleConnect.unset_dirs(autotile_coord.x, dir_mask)
	set_block(pos, get_cellv(pos), autotile_coord)


## Returns 'true' if the specified array contains a cake box type.
##
## There are eight cake box colors; one for each combination of three pieces which forms a rectangle.
static func has_cake_box(box_types: Array) -> bool:
	var result := false
	for box_type in box_types:
		if Foods.is_cake_box(box_type):
			result = true
			break
	return result


## Returns a random autotile coordinate for a vegetable tile.
static func random_veg_autotile_coord() -> Vector2:
	return Vector2(randi() % 18, randi() % 4)
