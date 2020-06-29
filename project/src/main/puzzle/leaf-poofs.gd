extends Node2D
"""
Spawns leaf poofs when the player clears a row containing vegetables.

Any occupied cell which isn't used in a box risks spawning a leaf poof. The more unused cells there are, the greater
the chance of a poof.
"""

# The maximum number of leaves we can display at once
const LEAF_POOL_SIZE := 50

onready var LeafPoofScene := preload("res://src/main/puzzle/LeafPoof.tscn")

export (NodePath) var _puzzle_tile_map_path: NodePath

# The pool of leaf poofs we're able to spawn. Some of these may be active but most will be inactive (process=false)
var _poofs: Array

# The index of the next leaf poof to spawn from the pool
var _poof_index := 0

onready var _puzzle_tile_map: PuzzleTileMap = get_node(_puzzle_tile_map_path)

func _ready() -> void:
	for _i in range(LEAF_POOL_SIZE):
		var poof: LeafPoof = LeafPoofScene.instance()
		add_child(poof)
		_poofs.append(poof)


"""
Spawns a single leaf poof near the specified cell.
"""
func _spawn_poof(type: int, cell_x: int, cell_y: int) -> void:
	# poof can appear half-way into horizontally adjacent cells, or in the cell above this one
	var poof_position := Vector2(cell_x + rand_range(-0.5, 1.5), cell_y + rand_range(-1.0, 1.0))
	poof_position *= _puzzle_tile_map.cell_size * _puzzle_tile_map.scale
	var poof: LeafPoof = _poofs[_poof_index]
	_poof_index = (_poof_index + 1) % _poofs.size()
	poof.initialize(type, poof_position)


"""
Spawns multiple leaf poofs near vegetable cells in the specified row.
"""
func _spawn_poofs(y: int, veg_columns: Array, poof_count: int) -> void:
	if poof_count <= 0:
		return
	
	# we split the line 3/6 or 4/5 between the two leaf varieties. 'cutoff' decides where the line is split.
	# 'cutoff_direction' decides which leaf variety is on which side
	var cutoff := int(rand_range(3, 6))
	var cutoff_direction := randf() < 0.5
	
	veg_columns.shuffle()
	for i in range(poof_count):
		var x: int = veg_columns[i % veg_columns.size()]
		
		# determine the leaf type. the third leaf in each variety is spawned less frequently
		var type: int = [0, 0, 1, 1, 2][randi() % 5]
		if x < cutoff != cutoff_direction:
			type += 3
		
		_spawn_poof(type, x, y)


func _poof_count(veg_cell_count: int) -> int:
	var poof_count := 0
	match veg_cell_count:
		3: poof_count = 1
		4: poof_count = 2
		5: poof_count = 3
		6: poof_count = 4
		7, 8, 9: poof_count = 8
	return poof_count


"""
If the specified row includes enough vegetable cells, we spawn leaf poofs nearby.
"""
func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	var veg_columns := []
	for x in range(PuzzleTileMap.COL_COUNT):
		if _puzzle_tile_map.get_cell(x, y) in [PuzzleTileMap.TILE_VEG, PuzzleTileMap.TILE_PIECE]:
			veg_columns.append(x)
	var poof_count := _poof_count(veg_columns.size())
	_spawn_poofs(y, veg_columns, poof_count)
