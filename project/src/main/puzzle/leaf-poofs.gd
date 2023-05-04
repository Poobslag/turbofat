extends Node2D
## Spawns leaf poofs when the player clears a row containing vegetables.
##
## Any occupied cell which isn't used in a box risks spawning a leaf poof. The more unused cells there are, the greater
## the chance of a poof.

@export var LeafPoofScene: PackedScene

@export var puzzle_tile_map_path: NodePath

@onready var _puzzle_tile_map: PuzzleTileMap = get_node(puzzle_tile_map_path)

## Spawns a single leaf poof near the specified cell.
func _spawn_poof(type: int, cell_x: int, cell_y: int) -> void:
	# poof can appear half-way into horizontally adjacent cells, or in the cell above this one
	var cell_offset := Vector2(randf_range(-0.5, 1.5), randf_range(-1.0, 1.0))
	var poof_position := _puzzle_tile_map.somewhere_near_cell(Vector2(cell_x, cell_y), cell_offset)
	var poof: LeafPoof = LeafPoofScene.instantiate()
	add_child(poof)
	poof.initialize(type, poof_position)


## Spawns multiple leaf poofs near vegetable cells in the specified row.
func _spawn_poofs(y: int) -> void:
	## Calculate the vegetable cells to leaf star poofs in
	var poof_columns := _veg_columns(y)
	poof_columns.shuffle()
	var poof_count := 0 if poof_columns.size() <= 3 else poof_columns.size() - 2
	poof_columns = poof_columns.slice(0, poof_count)
	
	# we split the line 3/6 or 4/5 between the two leaf varieties. 'cutoff' decides where the line is split.
	# 'cutoff_direction' decides which leaf variety is on which side
	var cutoff := randi_range(3, 5)
	var cutoff_direction := randf() < 0.5
	
	## Spawn leaf poofs
	for x in poof_columns:
		# determine the leaf type. the third leaf in each variety is spawned less frequently
		var type: int = Utils.rand_value([0, 0, 1, 1, 2])
		if x < cutoff != cutoff_direction:
			type += 3
		
		_spawn_poof(type, x, y)


func _veg_columns(y: int) -> Array:
	var veg_columns := []
	for x in range(PuzzleTileMap.COL_COUNT):
		if _puzzle_tile_map.get_cell_source_id(0, Vector2i(x, y)) in [PuzzleTileMap.TILE_VEG, PuzzleTileMap.TILE_PIECE]:
			veg_columns.append(x)
	return veg_columns


## If the specified row includes enough vegetable cells, we spawn leaf poofs nearby.
func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	_spawn_poofs(y)
