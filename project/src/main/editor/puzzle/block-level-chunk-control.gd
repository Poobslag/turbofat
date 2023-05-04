class_name BlockLevelChunkControl
extends Control
## UI component for a draggable chunk of level editor data made up of playfield blocks.

func _ready() -> void:
	_refresh_tile_map()
	_refresh_scale()


func _get_drag_data(_pos: Vector2) -> Variant:
	var data: BlockLevelChunk = BlockLevelChunk.new()
	for cell in $TileMap.get_used_cells(0):
		var tile: int = $TileMap.get_cell_source_id(0, cell)
		var autotile_coord: Vector2i = $TileMap.get_cell_atlas_coords(0, cell)
		data.set_block(cell, tile, autotile_coord)
	_refresh_tile_map()
	return data


## Calculates the extents of the tilemap's used cells.
func _tile_map_extents() -> Rect2i:
	var size := Rect2i(Vector2i.ZERO, Vector2i.ZERO)
	if $TileMap.get_used_cells(0):
		size.position = $TileMap.get_used_cells(0)[0]
		for cell in $TileMap.get_used_cells(0):
			size = size.expand(cell)
	return size


## Overridden by child classes, which use this method to populate the contents of the tilemap.
func _refresh_tile_map() -> void:
	pass


## Refreshes the scale to ensure the contents of the tilemap fit inside an item in the palette.
func _refresh_scale() -> void:
	var size := _tile_map_extents()
	$TileMap.scale.x = 1.00 / (1 + max(size.end.x, size.end.y))
	$TileMap.scale.y = 1.00 / (1 + max(size.end.x, size.end.y))
