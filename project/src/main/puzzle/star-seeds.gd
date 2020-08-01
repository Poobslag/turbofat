extends Control
"""
Draws shadowy stars and seeds inside snack boxes and cake boxes.

These star and seed sprites are referred to as 'wobblers'.
"""

signal food_spawned(cell, food_type)

# Aesthetically pleasing wobbler arrangements. It looks nice if they're balanced on the left and right sides.
const WOBBLER_POSITIONS_BY_SIZE := {
	Vector2(3, 3): [
			[0, 1, 2], [0, 2, 1],
			[1, 0, 2], [1, 2, 0],
			[2, 0, 1], [2, 1, 0],
		],
	Vector2(3, 4):
		[
			[0, 1, 2, 0], [0, 2, 1, 0],
			[1, 0, 2, 1], [1, 2, 0, 1],
			[2, 0, 1, 2], [2, 1, 0, 2],
		],
	Vector2(3, 5):
		[
			[0, 1, 2, 0, 1], [0, 2, 1, 0, 2],
			[1, 0, 2, 1, 0], [1, 2, 0, 1, 2],
			[2, 0, 1, 2, 0], [2, 1, 0, 2, 1],
		],
	Vector2(4, 3):
		[
			[0, 1, 3], [0, 2, 3], [0, 3, 1], [0, 3, 2],
			[1, 0, 3], [1, 3, 0],
			[2, 0, 3], [2, 3, 0],
			[3, 0, 1], [3, 0, 2], [3, 1, 0], [3, 2, 0],
		],
	Vector2(5, 3):
		[
			[0, 2, 4], [0, 4, 2],
			[1, 2, 3], [1, 3, 2],
			[2, 0, 4], [2, 1, 3], [2, 3, 1], [2, 4, 0],
			[3, 1, 2], [3, 2, 1],
			[4, 0, 2], [4, 2, 0],
		],
}

export (NodePath) var _puzzle_tile_map_path: NodePath

# key: Vector2 playfield cell positions
# value: Wobbler node contained within that cell
var _wobblers_by_cell: Dictionary

onready var StarScene := preload("res://src/main/puzzle/Star.tscn")
onready var SeedScene := preload("res://src/main/puzzle/Seed.tscn")
onready var _puzzle_tile_map: PuzzleTileMap = get_node(_puzzle_tile_map_path)


"""
Detects boxes in the playfield, and places wobblers in them.
"""
func _prepare_wobblers_for_scenario() -> void:
	_clear_wobblers()
	for x in range(PuzzleTileMap.COL_COUNT):
		for y in range(PuzzleTileMap.ROW_COUNT):
			var cell_contents := _puzzle_tile_map.get_cellv(Vector2(x, y))
			if cell_contents != PuzzleTileMap.TILE_BOX:
				continue
			var autotile_coord := _puzzle_tile_map.get_cell_autotile_coord(x, y)
			if Connect.is_u(autotile_coord.x) or Connect.is_l(autotile_coord.x):
				continue
			# upper left corner...
			var rect := Rect2(x, y, 1, 1)
			while(Connect.is_r(_puzzle_tile_map.get_cell_autotile_coord(rect.end.x - 1, y).x)):
				rect.size.x += 1
			while(Connect.is_d(_puzzle_tile_map.get_cell_autotile_coord(rect.end.x - 1, rect.end.y - 1).x)):
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
			wobbler_positions.append(randi() % int(rect.size.x))
	
	for wobbler_y in range(rect.size.y):
		var wobbler: Wobbler
		if PuzzleTileMap.is_cake_box(color_int):
			wobbler = StarScene.instance()
		else:
			wobbler = SeedScene.instance()
		
		var cell := rect.position + Vector2(wobbler_positions[wobbler_y], wobbler_y)
		if cell.y < PuzzleTileMap.FIRST_VISIBLE_ROW:
			wobbler.visible = false
		match(color_int):
			PuzzleTileMap.BoxColorInt.BROWN: wobbler.food_type = 0 + int(cell.y) % 2
			PuzzleTileMap.BoxColorInt.PINK: wobbler.food_type = 2 + int(cell.y) % 2
			PuzzleTileMap.BoxColorInt.BREAD: wobbler.food_type = 4 + int(cell.y) % 2
			PuzzleTileMap.BoxColorInt.WHITE: wobbler.food_type = 6 + int(cell.y) % 2
			PuzzleTileMap.BoxColorInt.CAKE: wobbler.food_type = 8
		wobbler.position = _puzzle_tile_map.map_to_world(cell + Vector2(0, -3))
		wobbler.position += _puzzle_tile_map.cell_size * Vector2(0.5, 0.5)
		wobbler.position *= _puzzle_tile_map.scale
		wobbler.base_scale = _puzzle_tile_map.scale * Vector2(0.5, 0.5)
		wobbler.z_index = 2
		_add_wobbler(cell, wobbler)


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
	
	_prepare_wobblers_for_scenario()


func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		if _wobblers_by_cell.has(Vector2(x, y)):
			emit_signal("food_spawned", Vector2(x, y), _wobblers_by_cell[Vector2(x, y)].food_type)
