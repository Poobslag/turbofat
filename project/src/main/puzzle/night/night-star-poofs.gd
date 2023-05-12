class_name NightStarPoofs
extends Node2D
## Spawns star poofs when the player clears a row containing vegetables during night mode.
##
## Any occupied cell which isn't used in a box risks spawning a star poof. The more unused cells there are, the greater
## the chance of a poof.

@export var StarPoofScene: PackedScene

var source_tile_map: PuzzleTileMap

## Spawns a star poof near the specified cell.
func _spawn_poof(cell_x: int, cell_y: int) -> void:
	# poof can appear half-way into horizontally adjacent cells, or in the cell above this one
	var poof_position := source_tile_map.somewhere_near_cell(Vector2i(cell_x, cell_y))
	var star_poof: NightStarPoof = StarPoofScene.instantiate()
	add_child(star_poof)
	star_poof.position = poof_position


## Spawns multiple star poofs near vegetable cells in the specified row.
func _spawn_poofs(y: int) -> void:
	## Calculate the vegetable cells to spawn star poofs in
	var poof_columns := _veg_columns(y)
	poof_columns.shuffle()
	var poof_count := 0 if poof_columns.size() <= 3 else poof_columns.size() - 2
	poof_columns = poof_columns.slice(0, poof_count)
	
	## Spawn star poofs
	for x in poof_columns:
		_spawn_poof(x, y)


## Returns a list of columns containing pieces or vegetable blocks in the specified row.
func _veg_columns(y: int) -> Array:
	var veg_columns := []
	for x in range(PuzzleTileMap.COL_COUNT):
		if source_tile_map.get_cell(x, y) in [PuzzleTileMap.TILE_VEG, PuzzleTileMap.TILE_PIECE]:
			veg_columns.append(x)
	return veg_columns


## If the specified row includes enough vegetable cells, we spawn star poofs nearby.
func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	_spawn_poofs(y)
