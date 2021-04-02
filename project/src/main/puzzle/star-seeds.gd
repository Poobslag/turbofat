extends Control
"""
Draws shadowy stars and seeds inside snack boxes and cake boxes.

These star and seed sprites are referred to as 'wobblers'.
"""

"""
Emitted when a star seed is eliminated, and a new piece of food should be spawned.

Parameters:
	'cell': A Vector2 corresponding to the tilemap cell where the food should appear
	
	'remaining_food': The number of remaining food items for the current set of line clears
	
	'food_type': A BoxColorInt value corresponding to the food which should appear
"""
signal food_spawned(cell, remaining_food, food_type)

# Aesthetically pleasing wobbler arrangements. It looks nice if they're balanced on the left and right sides.
const WOBBLER_POSITIONS_BY_SIZE := {
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

export (NodePath) var _puzzle_tile_map_path: NodePath

# key: Vector2 playfield cell positions
# value: Wobbler node contained within that cell
var _wobblers_by_cell: Dictionary

# the number of remaining food items to spawn for the current sequence of line clears
var _remaining_food_for_line_clears := 0

export (PackedScene) var StarScene: PackedScene
export (PackedScene) var SeedScene: PackedScene

onready var _puzzle_tile_map: PuzzleTileMap = get_node(_puzzle_tile_map_path)

func _ready() -> void:
	Pauser.connect("paused_changed", self, "_on_Pauser_paused_changed")


"""
Detects boxes in the playfield, and places wobblers in them.
"""
func _prepare_wobblers_for_level() -> void:
	_clear_wobblers()
	for x in range(PuzzleTileMap.COL_COUNT):
		for y in range(PuzzleTileMap.ROW_COUNT):
			var cell_contents := _puzzle_tile_map.get_cellv(Vector2(x, y))
			if cell_contents != PuzzleTileMap.TILE_BOX:
				continue
			var autotile_coord := _puzzle_tile_map.get_cell_autotile_coord(x, y)
			if PuzzleConnect.is_u(autotile_coord.x) or PuzzleConnect.is_l(autotile_coord.x):
				continue
			# upper left corner...
			var rect := Rect2(x, y, 1, 1)
			while(PuzzleConnect.is_r(_puzzle_tile_map.get_cell_autotile_coord(rect.end.x - 1, y).x)):
				rect.size.x += 1
			while(PuzzleConnect.is_d(_puzzle_tile_map.get_cell_autotile_coord(rect.end.x - 1, rect.end.y - 1).x)):
				rect.size.y += 1
			_add_wobblers_for_box(rect, autotile_coord.y)


"""
Adds wobblers for a snack box or cake box.
"""
func _add_wobblers_for_box(rect: Rect2, color_int: int) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			_remove_wobbler(Vector2(x, y))
	
	var wobbler_positions: Array
	if WOBBLER_POSITIONS_BY_SIZE.has(rect.size):
		# load one of the random aesthetically pleasing wobbler arrangements
		wobbler_positions = Utils.rand_value(WOBBLER_POSITIONS_BY_SIZE[rect.size])
	else:
		# create a random arrangement
		wobbler_positions = []
		for _y in range(rect.size.y):
			# calculate a random set of wobbler positions. the number of wobblers is two less than the width of the
			# box -- but every box will always have at least one.
			var new_positions := range(0, rect.size.x)
			new_positions.shuffle()
			new_positions = new_positions.slice(min(2, new_positions.size() - 1), new_positions.size())
			
			wobbler_positions.append(_wobbler_x_int(new_positions))
	
	for wobbler_y in range(rect.size.y):
		for wobbler_x in _wobbler_x_array(wobbler_positions[wobbler_y]):
			var wobbler: Wobbler
			if PuzzleTileMap.is_cake_box(color_int):
				wobbler = StarScene.instance()
			else:
				wobbler = SeedScene.instance()
			
			var cell := rect.position + Vector2(wobbler_x, wobbler_y)
			if cell.y < PuzzleTileMap.FIRST_VISIBLE_ROW:
				wobbler.visible = false
			match(color_int):
				PuzzleTileMap.BoxColorInt.BROWN: wobbler.food_type = 0 + int(cell.y) % 2
				PuzzleTileMap.BoxColorInt.PINK: wobbler.food_type = 2 + int(cell.y) % 2
				PuzzleTileMap.BoxColorInt.BREAD: wobbler.food_type = 4 + int(cell.y) % 2
				PuzzleTileMap.BoxColorInt.WHITE: wobbler.food_type = 6 + int(cell.y) % 2
				PuzzleTileMap.BoxColorInt.CAKE_JJO: wobbler.food_type = 8
				PuzzleTileMap.BoxColorInt.CAKE_JLO: wobbler.food_type = 9
				PuzzleTileMap.BoxColorInt.CAKE_JTT: wobbler.food_type = 10
				PuzzleTileMap.BoxColorInt.CAKE_LLO: wobbler.food_type = 11
				PuzzleTileMap.BoxColorInt.CAKE_LTT: wobbler.food_type = 12
				PuzzleTileMap.BoxColorInt.CAKE_PQV: wobbler.food_type = 13
				PuzzleTileMap.BoxColorInt.CAKE_PUV: wobbler.food_type = 14
				PuzzleTileMap.BoxColorInt.CAKE_QUV: wobbler.food_type = 15
			wobbler.position = _puzzle_tile_map.map_to_world(cell + Vector2(0, -3))
			wobbler.position += _puzzle_tile_map.cell_size * Vector2(0.5, 0.5)
			wobbler.position *= _puzzle_tile_map.scale
			wobbler.base_scale = _puzzle_tile_map.scale * Vector2(0.5, 0.5)
			wobbler.z_index = 2
			_add_wobbler(cell, wobbler)


"""
Converts a wobbler position array into a number.

Wobbler positions are stored as numbers like '235' representing the second, third and fifth horizontal position in a
box. This method creates that kind of number from a position array like [1, 3, 4]
"""
func _wobbler_x_array(x_int: int) -> Array:
	var x_array := []
	var x_int_tmp := x_int
	while x_int_tmp > 0:
		x_array.append(x_int_tmp % 10 - 1)
		x_int_tmp /= 10
	return x_array


"""
Converts a wobbler position number into an array of x coordinates.

Wobbler positions are stored as numbers like '235' representing the second, third and fifth horizontal position in a
box. This method converts those ints into a position array like [1, 3, 4].
"""
func _wobbler_x_int(x_array: Array) -> int:
	var x_int := 0
	for wobbler_x in x_array:
		x_int = x_int * 10 + wobbler_x + 1
	return x_int


"""
Removes a wobbler from a playfield cell.
"""
func _remove_wobbler(cell: Vector2) -> void:
	if not _wobblers_by_cell.has(cell):
		return
	
	_wobblers_by_cell[cell].queue_free()
	_wobblers_by_cell.erase(cell)


"""
Adds a wobbler to a playfield cell.
"""
func _add_wobbler(cell: Vector2, wobbler: Wobbler) -> void:
	_remove_wobbler(cell)
	_wobblers_by_cell[cell] = wobbler
	add_child(wobbler)


"""
Removes all wobblers from all playfield cells.
"""
func _clear_wobblers() -> void:
	for wobbler in get_children():
		wobbler.queue_free()
	_wobblers_by_cell.clear()


"""
Removes all wobblers from a playfield row.
"""
func _erase_row(y: int) -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		_remove_wobbler(Vector2(x, y))


"""
Removes all wobblers from the specified playfield row, dropping all higher wobblers down to fill the gap.
"""
func _delete_row(y: int) -> void:
	var shifted := {}
	for cell in _wobblers_by_cell.keys():
		if cell.y > y:
			# wobblers below the deleted row are left alone
			continue
		if cell.y < y:
			# wobblers above the deleted row are shifted
			_wobblers_by_cell[cell].position += \
					Vector2(0, _puzzle_tile_map.cell_size.y) * _puzzle_tile_map.scale
			if cell.y == PuzzleTileMap.FIRST_VISIBLE_ROW - 1:
				_wobblers_by_cell[cell].visible = true
			shifted[cell + Vector2.DOWN] = _wobblers_by_cell[cell]
		_wobblers_by_cell.erase(cell)
	
	for cell in shifted.keys():
		_wobblers_by_cell[cell] = shifted[cell]


func _on_Playfield_box_built(rect: Rect2, color_int: int) -> void:
	_add_wobblers_for_box(rect, color_int)


func _on_Playfield_line_erased(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	_erase_row(y)


func _on_Playfield_lines_deleted(lines: Array) -> void:
	for y in lines:
		_delete_row(y)


func _on_Playfield_blocks_prepared() -> void:
	if not _puzzle_tile_map:
		# _ready() has not yet been called
		return
	_prepare_wobblers_for_level()


func _on_Playfield_line_clears_scheduled(ys: Array) -> void:
	_remaining_food_for_line_clears = 0
	for y in ys:
		for x in range(PuzzleTileMap.COL_COUNT):
			if _wobblers_by_cell.has(Vector2(x, y)):
				_remaining_food_for_line_clears += 1


func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		if _wobblers_by_cell.has(Vector2(x, y)):
			_remaining_food_for_line_clears -= 1
			
			emit_signal("food_spawned", Vector2(x, y), _remaining_food_for_line_clears,
					_wobblers_by_cell[Vector2(x, y)].food_type)


func _on_Pauser_paused_changed(value: bool) -> void:
	visible = !value
