class_name StarSeeds
extends Control
## Draws shadowy stars and seeds inside snack boxes and cake boxes.
##
## These star and seed sprites are referred to as 'star seeds'.

## Emitted when a star seed is eliminated, and a new piece of food should be spawned.
##
## Parameters:
## 	'cell': A Vector2 corresponding to the tilemap cell where the food should appear
##
## 	'remaining_food': The number of remaining food items for the current line clear
##
## 	'food_type': Enum from Foods.FoodType corresponding to the food to spawn
signal food_spawned(cell, remaining_food, food_type)

## Aesthetically pleasing star seed arrangements. It looks nice if they're balanced on the left and right sides.
const STAR_SEED_POSITIONS_BY_SIZE := {
	Vector2(3, 3): [
			[1, 2, 3], [1, 3, 2],
			[2, 1, 3], [2, 3, 1],
			[3, 1, 2], [3, 2, 1],
		],
	Vector2(3, 4):
		[
			[1, 2, 3, 1], [1, 3, 2, 1],
			[2, 1, 3, 2], [2, 3, 1, 2],
			[3, 1, 2, 3], [3, 2, 1, 3],
		],
	Vector2(3, 5):
		[
			[1, 2, 3, 1, 2], [1, 3, 2, 1, 3],
			[2, 1, 3, 2, 1], [2, 3, 1, 2, 3],
			[3, 1, 2, 3, 1], [3, 2, 1, 3, 2],
		],
	Vector2(4, 3):
		[
			[12, 23, 34], [12, 14, 34], [13, 24, 13], [14, 23, 14],
			[24, 13, 24], [23, 14, 23],
			[34, 23, 12], [34, 14, 12],
		],
	Vector2(5, 3):
		[
			[123, 234, 345], [123, 135, 345], [123, 125, 145], [135, 234, 135],
			[234, 135, 234],
			[345, 234, 123], [345, 135, 123], [345, 145, 125],
		],
}

## Aesthetically pleasing star seed arrangements for levels with double snacks, double cakes.
const STAR_SEED_POSITIONS_BY_SIZE_DOUBLE := {
	Vector2(3, 3): [
			[12, 13, 23], [12, 23, 13],
			[13, 12, 23], [13, 23, 12],
			[23, 12, 13], [23, 13, 12],
		],
	Vector2(3, 4):
		[
			[12, 13, 23, 12], [12, 23, 13, 12],
			[13, 12, 23, 13], [13, 23, 12, 13],
			[23, 12, 13, 23], [23, 13, 12, 23],
		],
	Vector2(3, 5):
		[
			[12, 13, 23, 12, 13], [12, 23, 13, 12, 23],
			[13, 12, 23, 13, 12], [13, 23, 12, 13, 23],
			[23, 12, 13, 23, 12], [23, 13, 12, 23, 13],
		],
	Vector2(4, 3):
		[
			[1234, 1234, 1234],
		],
	Vector2(5, 3):
		[
			[12345, 12345, 12345],
		],
}

export (NodePath) var puzzle_tile_map_path: NodePath

## key: (Vector2) playfield cell positions
## value: (StarSeed) StarSeed node contained within that cell
var _star_seeds_by_cell: Dictionary

export (PackedScene) var StarSeedScene: PackedScene

onready var _puzzle_tile_map: PuzzleTileMap = get_node(puzzle_tile_map_path)

func _ready() -> void:
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")


func get_cells_with_star_seeds() -> Array:
	return _star_seeds_by_cell.keys()


func get_star_seed(cell: Vector2) -> StarSeed:
	return _star_seeds_by_cell.get(cell)


## Detects boxes in the playfield, and places star seeds in them.
func _prepare_star_seeds_for_level() -> void:
	_clear_star_seeds()
	_add_star_seeds_for_boxes(Rect2(0, 0, PuzzleTileMap.COL_COUNT, PuzzleTileMap.ROW_COUNT))


## Detects boxes in a range of cells, and places star seeds in them.
##
## Parameters:
## 	'rect_range': Cell coordinates defining the cells to search.
func _add_star_seeds_for_boxes(rect_range: Rect2) -> void:
	for y in range(rect_range.position.y, rect_range.position.y + rect_range.size.y):
		for x in range(rect_range.position.x, rect_range.position.x + rect_range.size.x):
			var cell_contents := _puzzle_tile_map.get_cellv(Vector2(x, y))
			if cell_contents != PuzzleTileMap.TILE_BOX:
				continue
			var autotile_coord := _puzzle_tile_map.get_cell_autotile_coord(x, y)
			if PuzzleConnect.is_u(autotile_coord.x) or PuzzleConnect.is_l(autotile_coord.x):
				continue
			# upper left corner...
			var rect := Rect2(x, y, 1, 1)
			while PuzzleConnect.is_r(_puzzle_tile_map.get_cell_autotile_coord(rect.end.x - 1, y).x):
				rect.size.x += 1
			while PuzzleConnect.is_d(_puzzle_tile_map.get_cell_autotile_coord(rect.end.x - 1, rect.end.y - 1).x):
				rect.size.y += 1
			_add_star_seeds_for_box(rect, autotile_coord.y)


## Adds star seeds for a snack box or cake box.
##
## Parameters:
## 	'rect': Cell coordinates defining the box's position and dimensions
##
## 	'box_type': Enum from Foods.BoxType defining the box's color
func _add_star_seeds_for_box(rect: Rect2, box_type: int) -> void:
	_remove_star_seeds_for_box(rect)
	var star_seed_positions := _star_seed_positions(rect, box_type)
	_spawn_star_seeds(rect, box_type, star_seed_positions)


## Clears star seeds to make room for a new snack box or cake box.
##
## Parameters:
## 	'rect': Cell coordinates defining the box's position and dimensions
func _remove_star_seeds_for_box(rect: Rect2) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			_remove_star_seed(Vector2(x, y))


## Calculates relative positions for star seeds within a snack box or cake box.
##
## Returns an array of ints representing concatenated columns within the box. For example if star seeds should be in
## the first and third column of the box the array will contain the number '13', the concatenation of the values 1 and
## 3.
##
## Parameters:
## 	'rect': Cell coordinates defining the box's position and dimensions
##
## 	'box_type': Enum from Foods.BoxType defining the box's color
##
## Returns:
## 	An array of ints representing concatenated columns within the box.
func _star_seed_positions(rect: Rect2, box_type: int) -> Array:
	var star_seed_multiplier := _star_seed_multiplier(box_type)
	var star_seed_positions: Array
	if star_seed_multiplier == 0:
		# no star_seeds
		star_seed_positions = []
		for _i in range(rect.size.y):
			star_seed_positions.append(0)
	elif star_seed_multiplier == 1 and STAR_SEED_POSITIONS_BY_SIZE.has(rect.size):
		# regular star seeds; load a random aesthetically pleasing star seed arrangement
		star_seed_positions = Utils.rand_value(STAR_SEED_POSITIONS_BY_SIZE[rect.size])
	elif star_seed_multiplier == 2 and STAR_SEED_POSITIONS_BY_SIZE_DOUBLE.has(rect.size):
		# double star seeds; load a random aesthetically pleasing star seed arrangement
		star_seed_positions = Utils.rand_value(STAR_SEED_POSITIONS_BY_SIZE_DOUBLE[rect.size])
	else:
		# create a random arrangement
		star_seed_positions = []
		var star_seed_count := min(star_seed_multiplier * max(1, rect.size.x - 2), rect.size.x)
		for _y in range(rect.size.y):
			# calculate a random set of star seed positions. the number of star seeds is two less than the width of the
			# box -- but every box will always have at least one.
			var new_positions := range(rect.size.x)
			new_positions.shuffle()
			new_positions = new_positions.slice(new_positions.size() - star_seed_count, new_positions.size())
			star_seed_positions.append(_star_seed_x_int(new_positions))
	return star_seed_positions


## Calculates and returns a multiplier for boxes which should have unusual numbers of star seeds.
##
## For most boxes this multiplier will be 1, but it could be 0 for boxes with no star seeds, or 2 for boxes with extra
## star seeds.
##
## Parameters:
## 	'box_type': Enum from Foods.BoxType defining the box's color
##
## Returns:
## 	An int multiplier in the range [0, 2] representing how many star seeds the box should have
func _star_seed_multiplier(box_type: int) -> int:
	var multiplier: float
	if Foods.is_cake_box(box_type):
		multiplier = CurrentLevel.settings.score.cake_points / float(ScoreRules.DEFAULT_CAKE_POINTS)
	else:
		multiplier = CurrentLevel.settings.score.snack_points / float(ScoreRules.DEFAULT_SNACK_POINTS)
	return int(clamp(multiplier, 0, 2))


## Spawns star seeds within a snack box or cake box.
##
## Parameters:
## 	'rect': Cell coordinates defining the box's position and dimensions
##
## 	'box_type': Enum from Foods.BoxType defining the box's color
##
## 	'star_seed_positions': An array of ints representing concatenated columns within the box.
func _spawn_star_seeds(rect: Rect2, box_type: int, star_seed_positions: Array) -> void:
	for star_seed_y in range(rect.size.y):
		for star_seed_x in _star_seed_x_array(star_seed_positions[star_seed_y]):
			var star_seed: StarSeed = StarSeedScene.instance()
			
			var cell := rect.position + Vector2(star_seed_x, star_seed_y)
			if cell.y < PuzzleTileMap.FIRST_VISIBLE_ROW:
				star_seed.visible = false
			
			var food_types: Array = Foods.FOOD_TYPES_BY_BOX_TYPES[box_type]
			
			# alternate snack foods in a horizontal stripe pattern
			star_seed.food_type = food_types[int(cell.y) % food_types.size()]
			
			star_seed.position = _puzzle_tile_map.map_to_world(cell + Vector2(0, -3))
			star_seed.position += _puzzle_tile_map.cell_size * Vector2(0.5, 0.5)
			star_seed.position *= _puzzle_tile_map.scale
			star_seed.scale = _puzzle_tile_map.scale
			star_seed.z_index = 4
			
			_add_star_seed(cell, star_seed)


## Converts a star seed position array into a number.
##
## StarSeed positions are stored as numbers like '235' representing the second, third and fifth horizontal position in
## a box. This method creates that kind of number from a position array like [1, 3, 4]
func _star_seed_x_array(x_int: int) -> Array:
	var x_array := []
	var x_int_tmp := x_int
	while x_int_tmp > 0:
		x_array.append(x_int_tmp % 10 - 1)
		x_int_tmp /= 10
	return x_array


## Converts a star seed position number into an array of x coordinates.
##
## Star seed positions are stored as numbers like '235' representing the second, third and fifth horizontal position in
## a box. This method converts those ints into a position array like [1, 3, 4].
func _star_seed_x_int(x_array: Array) -> int:
	var x_int := 0
	for star_seed_x in x_array:
		x_int = x_int * 10 + star_seed_x + 1
	return x_int


## Removes a star seed from a playfield cell.
func _remove_star_seed(cell: Vector2) -> void:
	if not _star_seeds_by_cell.has(cell):
		return
	
	_star_seeds_by_cell[cell].queue_free()
	_star_seeds_by_cell.erase(cell)


## Adds a star seed to a playfield cell.
func _add_star_seed(cell: Vector2, star_seed: StarSeed) -> void:
	_remove_star_seed(cell)
	_star_seeds_by_cell[cell] = star_seed
	add_child(star_seed)


## Removes all star seeds from all playfield cells.
func _clear_star_seeds() -> void:
	for star_seed in get_children():
		star_seed.queue_free()
	_star_seeds_by_cell.clear()


## Removes all star seeds from a playfield row.
func _erase_row(y: int) -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		_remove_star_seed(Vector2(x, y))


## Shifts a group of star seeds up or down.
##
## Parameters:
## 	'bottom_row': The lowest row to shift. All star seeds at or above this row will be shifted.
##
## 	'direction': The direction to shift the star seeds, such as Vector2.UP or Vector2.DOWN.
func _shift_rows(bottom_row: int, direction: Vector2) -> void:
	# First, erase and store all the old star_seeds which are shifting
	var shifted := {}
	for cell in _star_seeds_by_cell.keys():
		if cell.y > bottom_row:
			# star_seeds below the specified bottom row are left alone
			continue
		# star_seeds above the specified bottom row are shifted
		_star_seeds_by_cell[cell].position += direction * _puzzle_tile_map.cell_size * _puzzle_tile_map.scale
		if cell.y == PuzzleTileMap.FIRST_VISIBLE_ROW - 1:
			_star_seeds_by_cell[cell].visible = true
		shifted[cell + direction] = _star_seeds_by_cell[cell]
		_star_seeds_by_cell.erase(cell)
	
	# Next, write the old star_seeds in their new locations
	for cell in shifted.keys():
		_star_seeds_by_cell[cell] = shifted[cell]


func _on_Playfield_box_built(rect: Rect2, box_type: int) -> void:
	_add_star_seeds_for_box(rect, box_type)


func _on_Playfield_line_erased(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	_erase_row(y)


func _on_Playfield_line_deleted(y: int) -> void:
	# Levels with the 'FloatFall' LineClearType have rows which are deleted, but not erased. Erase any star_seeds
	_erase_row(y)
	
	# drop all star seeds above the specified row to fill the gap
	_shift_rows(y - 1, Vector2.DOWN)


func _on_Playfield_blocks_prepared() -> void:
	if not _puzzle_tile_map:
		# _ready() has not yet been called
		return
	_prepare_star_seeds_for_level()


func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	var remaining_food_for_line_clear := 0
	for x in range(PuzzleTileMap.COL_COUNT):
		if _star_seeds_by_cell.has(Vector2(x, y)):
			remaining_food_for_line_clear += 1
	
	for x in range(PuzzleTileMap.COL_COUNT):
		if _star_seeds_by_cell.has(Vector2(x, y)):
			remaining_food_for_line_clear -= 1
			
			emit_signal("food_spawned", Vector2(x, y), remaining_food_for_line_clear,
					_star_seeds_by_cell[Vector2(x, y)].food_type)


## When the player pauses, we hide the playfield so they can't cheat.
func _on_Pauser_paused_changed(value: bool) -> void:
	visible = not value


func _on_Playfield_line_inserted(y: int, _tiles_key: String, _src_y: int) -> void:
	# raise all star seeds at or above the specified row
	_shift_rows(y, Vector2.UP)
	_add_star_seeds_for_boxes(Rect2(0, y, PuzzleTileMap.COL_COUNT, 1))


func _on_Playfield_line_filled(y: int, _tiles_key: String, _src_y: int) -> void:
	_add_star_seeds_for_boxes(Rect2(0, y, PuzzleTileMap.COL_COUNT, 1))
