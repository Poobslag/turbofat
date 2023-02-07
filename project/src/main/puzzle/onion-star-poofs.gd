class_name OnionStarPoofs
extends Node2D
## Spawns star poofs when the player clears a row containing vegetables during night mode.
##
## Any occupied cell which isn't used in a box risks spawning a star poof. The more unused cells there are, the greater
## the chance of a poof.

export (PackedScene) var StarPoofScene: PackedScene

var source_tile_map: PuzzleTileMap

## Spawns a star poof near the specified cell.
func _spawn_poof(cell_x: int, cell_y: int) -> void:
	# poof can appear half-way into horizontally adjacent cells, or in the cell above this one
	var poof_position := source_tile_map.somewhere_near_cell(Vector2(cell_x, cell_y))
	var star_poof: StarPoof = StarPoofScene.instance()
	add_child(star_poof)
	star_poof.position = poof_position


## Spawns multiple star poofs near vegetable cells in the specified row.
func _spawn_poofs(y: int, veg_columns: Array, poof_count: int) -> void:
	if poof_count <= 0:
		return
	
	veg_columns.shuffle()
	
	for i in range(poof_count):
		var x: int = veg_columns[i % veg_columns.size()]
		_spawn_poof(x, y)


func _poof_count(veg_cell_count: int) -> int:
	return int(max(veg_cell_count - 2, 0))


## If the specified row includes enough vegetable cells, we spawn star poofs nearby.
func _on_Playfield_before_line_cleared(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	var veg_columns := []
	for x in range(PuzzleTileMap.COL_COUNT):
		if source_tile_map.get_cell(x, y) in [PuzzleTileMap.TILE_VEG, PuzzleTileMap.TILE_PIECE]:
			veg_columns.append(x)
	var poof_count := _poof_count(veg_columns.size())
	_spawn_poofs(y, veg_columns, poof_count)
