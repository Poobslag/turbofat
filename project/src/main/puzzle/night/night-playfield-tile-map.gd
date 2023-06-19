class_name NightPlayfieldTileMap
extends NightPuzzleTileMap
## Displays the playfield tile map during night mode.
##
## Many other night mode tilemaps such as the active piece, next piece and hold piece use similar logic. The playfield
## tilemap is distinct because its pieces cast an opaque vertical shadow, making gameplay more difficult.
##
## This tilemap is synchronized with the daytime tilemap, and rendered over it.

## key: (Vector2i) playfield cell containing a 'silhouette', a vertical shadow below a block.
## value: (bool) true
var _silhouettes_by_cell := {}

func _ready() -> void:
	super()
	PuzzleState.after_piece_written.connect(_on_PuzzleState_after_piece_written)
	_reset()


func _reset() -> void:
	_silhouettes_by_cell.clear()


## When assigned a tilemap, we immediately refresh our silhouettes.
##
## This allows the silhouettes to be visible when a puzzle is first loaded, so the player can't see any gaps.
func set_source_tile_map(new_source_tile_map: PuzzleTileMap) -> void:
	super.set_source_tile_map(new_source_tile_map)
	_refresh_silhouettes()


## Updates our tilemap based on the source tilemap, and based on our calculated silhouettes.
func _refresh_tiles_from_source() -> void:
	# copy data from the source tilemap
	clear()
	for cell in source_tile_map.get_used_cells(0):
		set_cell(0, cell, 0, Vector2i(15, 0))
	
	# add silhouettes
	for cell in _silhouettes_by_cell:
		if get_cell_source_id(0, cell) == -1 and _silhouettes_by_cell.get(cell, false):
			set_cell(0, cell, 0, Vector2i(15, 0))
	
	# shape tiles
	for cell in get_used_cells(0):
		var autotile_coord := Vector2i(15, 0)
		if get_cell_source_id(0, cell + Vector2i.LEFT) == -1:
			autotile_coord.x = PuzzleConnect.unset_l(autotile_coord.x)
		if get_cell_source_id(0, cell + Vector2i.UP) == -1:
			autotile_coord.x = PuzzleConnect.unset_u(autotile_coord.x)
		if get_cell_source_id(0, cell + Vector2i.RIGHT) == -1:
			autotile_coord.x = PuzzleConnect.unset_r(autotile_coord.x)
		if get_cell_source_id(0, cell + Vector2i.DOWN) == -1:
			autotile_coord.x = PuzzleConnect.unset_d(autotile_coord.x)
		if cell.y == PuzzleTileMap.ROW_COUNT - 1:
			autotile_coord.x = PuzzleConnect.set_distance(autotile_coord.x)
		set_cell(0, cell, 0, autotile_coord)


## Recalculates which cells should contain 'silhouettes', vertical shadows below blocks.
func _refresh_silhouettes() -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		for y in range(PuzzleTileMap.ROW_COUNT):
			_refresh_silhouette(Vector2i(x, y))


## Recalculates whether the specified cell should contain a 'silhouettes', a vertical shadow below blocks.
##
## This method assumes the cell above it has already been updated with a silhouette, if necessary.
func _refresh_silhouette(cell: Vector2i) -> void:
	var silhouette := false
	if source_tile_map.get_cell_source_id(0, cell) != -1:
		silhouette = false
	elif source_tile_map.get_cell_source_id(0, cell + Vector2i.UP) != -1:
		silhouette = true
	elif _silhouettes_by_cell.get(cell + Vector2i.UP, false):
		silhouette = true
	_silhouettes_by_cell[cell] = silhouette


## We only update our silhouettes after the piece is written -- not when pieces are locking into place.
##
## Updating our silhouettes too frequently results in the playfield flashing unpleasantly.
func _on_PuzzleState_after_piece_written() -> void:
	_refresh_silhouettes()


func _on_Playfield_line_erased(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	_refresh_silhouettes()


func _on_Playfield_line_deleted(_y: int) -> void:
	_refresh_silhouettes()


func _on_Playfield_line_inserted(_y: int, _tiles_key: String, _src_y: int) -> void:
	_refresh_silhouettes()


func _on_Playfield_blocks_prepared() -> void:
	_refresh_silhouettes()
