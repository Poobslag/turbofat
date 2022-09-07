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

var _puzzle_tile_sets_by_enum := {
	TileSetType.DEFAULT: load("res://src/main/puzzle/puzzle-tile-set.tres"),
	TileSetType.VEGGIE: load("res://src/main/puzzle/puzzle-tile-set-veggies.tres"),
	TileSetType.DIAGRAM: load("res://src/main/puzzle/puzzle-tile-set-diagram.tres"),
}


func _ready() -> void:
	clear()


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
			set_block(Vector2(curr_x, curr_y), TILE_BOX, Vector2(15, box_type))
	
	# top/bottom edge
	for curr_x in range(rect.position.x, rect.end.x):
		_disconnect_block(Vector2(curr_x, rect.position.y), PuzzleConnect.UP)
		_disconnect_block(Vector2(curr_x, rect.end.y - 1), PuzzleConnect.DOWN)
	
	# left/right edge
	for curr_y in range(rect.position.y, rect.end.y):
		_disconnect_block(Vector2(rect.position.x, curr_y), PuzzleConnect.LEFT)
		_disconnect_block(Vector2(rect.end.x - 1, curr_y), PuzzleConnect.RIGHT)


## Deletes the row at the specified location, lowering all higher rows to fill the gap.
func delete_row(y: int) -> void:
	erase_playfield_row(y)
	_shift_rows(y - 1, Vector2.DOWN)


## Inserts a blank row at the specified location, raising all higher rows to make room.
func insert_row(y: int) -> void:
	_shift_rows(y, Vector2.UP)


## Deletes the specified row in the tilemap, dropping all higher rows down to fill the gap.
func delete_rows(rows: Array) -> void:
	# sort to avoid edge cases with row indexes changing during deletion
	var rows_to_delete := rows.duplicate()
	rows_to_delete.sort()
	for y in rows:
		delete_row(y)


## Returns 'true' if the specified cell is within the playfield bounds and does not contain a block.
func is_cell_empty(pos: Vector2) -> bool:
	return Rect2(0, 0, COL_COUNT, ROW_COUNT).has_point(pos) and get_cellv(pos) == -1


## Returns 'true' if the specified cell is outside the playfield bounds or contains a block.
func is_cell_obstructed(pos: Vector2) -> bool:
	return not is_cell_empty(pos)


## Returns true if the specified row has no empty cells.
func playfield_row_is_full(y: int) -> bool:
	var row_is_full := true
	for x in range(COL_COUNT):
		if is_cell_empty(Vector2(x, y)):
			row_is_full = false
			break
	return row_is_full


## Returns true if the specified row has only empty cells.
func playfield_row_is_empty(y: int) -> bool:
	var row_is_empty := true
	for x in range(COL_COUNT):
		if not is_cell_empty(Vector2(x, y)):
			row_is_empty = false
			break
	return row_is_empty


## Erases all cells in the specified row.
func erase_playfield_row(y: int) -> void:
	for x in range(COL_COUNT):
		if get_cellv(Vector2(x, y)) == 0:
			_convert_piece_to_veg(Vector2(x, y))
		elif get_cellv(Vector2(x, y)) == 1:
			_disconnect_box(Vector2(x, y))
		
		set_block(Vector2(x, y), -1)

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
	if not cell_offset:
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


## Deconstructs the piece at the specified location into vegetable blocks.
func _convert_piece_to_veg(pos: Vector2) -> void:
	# store connections
	var old_autotile_coord: Vector2 = get_cell_autotile_coord(pos.x, pos.y)
	
	# convert to vegetable. there are four kinds of vegetables
	var vegetable_type := int(old_autotile_coord.y) % 4
	set_block(pos, TILE_VEG, Vector2(randi() % 18, vegetable_type))
	
	# recurse to neighboring connected cells
	if get_cellv(pos + Vector2.UP) == 0 and PuzzleConnect.is_u(old_autotile_coord.x):
		_convert_piece_to_veg(pos + Vector2.UP)
	if get_cellv(pos + Vector2.DOWN) == 0 and PuzzleConnect.is_d(old_autotile_coord.x):
		_convert_piece_to_veg(pos + Vector2.DOWN)
	if get_cellv(pos + Vector2.LEFT) == 0 and PuzzleConnect.is_l(old_autotile_coord.x):
		_convert_piece_to_veg(pos + Vector2.LEFT)
	if get_cellv(pos + Vector2.RIGHT) == 0 and PuzzleConnect.is_r(old_autotile_coord.x):
		_convert_piece_to_veg(pos + Vector2.RIGHT)


## Disconnects the specified block, which is a part of a box, from the boxes above and below it.
##
## When clearing a line which contains a box, parts of the box can stay behind. We want to redraw those boxes so that
## they don't look chopped-off, and so that the player can still tell they're worth bonus points, so we turn them into
## smaller 2x3 and 1x3 boxes.
##
## If we didn't perform this step, the chopped-off bottom of a bread box would still just look like bread. This way,
## the bottom of a bread box looks like a delicious goopy snack and the player can tell it's special.
func _disconnect_box(pos: Vector2) -> void:
	if get_cellv(pos + Vector2.UP) == TILE_BOX:
		_disconnect_block(pos + Vector2.UP, PuzzleConnect.DOWN)
	if get_cellv(pos + Vector2.DOWN) == TILE_BOX:
		_disconnect_block(pos + Vector2.DOWN, PuzzleConnect.UP)


## Disconnects a block from its surrounding directions.
##
## Parameters:
## 	'dir_mask': Directions to be disconnected. Defaults to 15 which disconnects it from all four directions.
func _disconnect_block(pos: Vector2, dir_mask: int = 15) -> void:
	if get_cellv(pos) == TileMap.INVALID_CELL:
		# empty cell; nothing to disconnect
		return
	var autotile_coord := get_cell_autotile_coord(pos.x, pos.y)
	autotile_coord.x = PuzzleConnect.unset_dirs(autotile_coord.x, dir_mask)
	set_block(pos, get_cellv(pos), autotile_coord)


## Shifts a group of rows up or down.
##
## Parameters:
## 	'bottom_row': The lowest row to shift. All rows at or above this row will be shifted.
##
## 	'direction': The direction to shift the rows, such as Vector2.UP or Vector2.DOWN.
func _shift_rows(bottom_row: int, direction: Vector2) -> void:
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
		set_block(cell, -1)
	
	# Next, write the old cells in their new locations
	for cell in piece_colors_to_set:
		set_block(cell, piece_colors_to_set[cell], autotile_coords_to_set[cell])


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
